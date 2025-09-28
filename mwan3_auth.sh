#!/bin/bash

# 认证信息 mwan3_name:interface:username:password:term_type
declare -a INTERFACE_CONFIGS=(
    "wan1:eth0:2025xxxx:password:mobile"
    "wan2:eth1:2025xxxx:password:mobile"
    "wan3:eth2:2025xxxx:password:pc"
    "wan4:eth3:2025xxxx:password:pc"
)
# 触发共享上网后的禁止登录倒计时
declare -A BAN_TIMERS=()
# 检查间隔时间
CHECK_INTERVAL=10
# 日志文件路径
LOGFILE="/tmp/log/mwan3_auth.log"
mkdir -p "$(dirname "$LOGFILE")"


log() {
    local level="$1"
    local mwan3_name="$2"
    local message="$3"

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_message="[$timestamp] [$mwan3_name] [$level] $message"
    
    echo -e "$log_message"
    # 如果不是调试信息，还需要写入日志文件
    if [ "$level" != "DBG" ]; then
        echo "$log_message" >> "$LOGFILE"
    fi
}

do_authentication() {
    local mwan3_name="$1"
    local interface="$2"
    local username="$3"
    local password="$4"
    local term_type="$5"

    local mac_addr=$(cat /sys/class/net/$interface/address)
    local ip_addr=$(ifconfig $interface | grep 'inet ' | awk '{print $2}' | sed 's/addr://')

    local login_url
    if [ "$term_type" = "mobile" ]; then
        login_url="http://10.254.7.4:801/eportal/portal/login?callback=dr1005&login_method=1&user_account=%2C1%2C$username&user_password=$password&wlan_user_ip=$ip_addr&wlan_user_ipv6=&wlan_user_mac=$mac_addr&wlan_ac_ip=&wlan_ac_name=&ua=Mozilla%2F5.0%20(Linux%3B%20Android%208.0.0%3B%20SM-G955U%20Build%2FR16NW)%20AppleWebKit%2F537.36%20(KHTML%2C%20like%20Gecko)%20Chrome%2F134.0.0.0%20Mobile%20Safari%2F537.36%20Edg%2F134.0.0.0&term_type=2&jsVersion=4.2&terminal_type=2&lang=zh-cn&v=9451&lang=zh"
    else
        login_url="http://10.254.7.4:801/eportal/portal/login?callback=dr1004&login_method=1&user_account=%2C0%2C$username&user_password=$password&wlan_user_ip=$ip_addr&wlan_user_ipv6=&wlan_user_mac=$mac_addr&wlan_ac_ip=&wlan_ac_name=&ua=Mozilla%2F5.0%20(Windows%20NT%2010.0%3B%20Win64%3B%20x64)%20AppleWebKit%2F537.36%20(KHTML%2C%20like%20Gecko)%20Chrome%2F134.0.0.0%20Safari%2F537.36%20Edg%2F134.0.0.0&term_type=1&jsVersion=4.2&terminal_type=1&lang=zh-cn&v=9875&lang=zh"
    fi
    
    local response=$(mwan3 use $mwan3_name curl -s "$login_url")
    local json_response=$(echo "$response" | grep -o '{.*}')
    
    if [ -n "$json_response" ]; then
        if echo "$json_response" | grep -q '"result":1'; then
            log "INF" "$mwan3_name" "Login successful! Response: $json_response"
        else
            log "WAR" "$mwan3_name" "Login failed! Response: $json_response"
            
            # 检查是否被检测到共享上网
            if echo "$response" | grep -q "等待5分钟即可正常使用"; then
                log "WAR" "$mwan3_name" "Waiting 5 minutes ..."
                BAN_TIMERS["$mwan3_name"]=300
            fi
        fi
    else
        log "ERR" "$mwan3_name" "Unknown response: $response"
    fi
}

main() {
    log "INF" "DAEMON" "Starting authentication daemon (PID: $$)"
    
    for config in "${INTERFACE_CONFIGS[@]}"; do
        IFS=':' read -r mwan3_name interface username password term_type <<< "$config"
        BAN_TIMERS["$mwan3_name"]=0
    done
    
    while true; do
        for mwan3_name in "${!BAN_TIMERS[@]}"; do
            local current_timer="${BAN_TIMERS[$mwan3_name]}"
            if [ "$current_timer" -gt 0 ]; then
                local new_timer=$((current_timer - CHECK_INTERVAL))
                if [ "$new_timer" -lt 0 ]; then
                    new_timer=0
                fi
                BAN_TIMERS["$mwan3_name"]="$new_timer"
            fi
        done

        local interface_status=$(mwan3 interfaces 2>/dev/null)
        for config in "${INTERFACE_CONFIGS[@]}"; do
            IFS=':' read -r mwan3_name interface username password term_type <<< "$config"
            
            if echo "$interface_status" | grep -qw "interface $mwan3_name is offline"; then
                # 禁止登录倒计时大于0，跳过登录
                if [ "${BAN_TIMERS[$mwan3_name]}" -gt 0 ]; then
                    continue
                fi
                
                do_authentication "$mwan3_name" "$interface" "$username" "$password" "$term_type"
            fi
        done

        sleep $CHECK_INTERVAL
    done
}

cleanup_and_exit() {
    log "INF" "DAEMON" "Received termination signal, shutting down..."
    exit 0
}

trap cleanup_and_exit INT TERM
main
