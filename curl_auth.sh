#!/bin/bash

# 使用 curl 认证校园网
# 用法: ./curl_auth.sh <username> <password> [term_type(pc|mobile)]

# 检查参数
if [ $# -lt 2 ]; then
    echo "用法: $0 <username> <password> [term_type(pc|mobile)]"
    exit 1
fi

USERNAME="$1"
PASSWORD="$2"
TERM_TYPE="${3:-pc}"

# 执行认证
do_authentication() {
    status_url="http://10.254.7.4/drcom/chkstatus?callback=dr1002&jsVersion=4.X&v=5505&lang=zh"
    local response=$(curl -s "$status_url" 2>/dev/null)
    
    # 检查是否包含有效的响应
    if ! echo "$response" | grep -q 'dr1002('; then
        echo "错误: 获取状态信息失败"
        exit 1
    fi
    
    # 从响应中提取v46ip字段
    local v46ip=$(echo "$response" | sed -n 's/.*"v46ip":"\([^"]*\)".*/\1/p')
    
    if [ -z "$v46ip" ]; then
        echo "错误: 无法获取IP地址"
        exit 1
    fi
    
    echo "开始认证 (IP地址: $v46ip, 用户名: $USERNAME, 终端类型: $TERM_TYPE)..."
    
    local login_url
    if [ "$TERM_TYPE" = "mobile" ]; then
        login_url="http://10.254.7.4:801/eportal/portal/login?callback=dr1005&login_method=1&user_account=%2C1%2C$USERNAME&user_password=$PASSWORD&wlan_user_ip=$v46ip&wlan_user_ipv6=&wlan_user_mac=&wlan_ac_ip=&wlan_ac_name=&ua=Mozilla%2F5.0%20(Linux%3B%20Android%208.0.0%3B%20SM-G955U%20Build%2FR16NW)%20AppleWebKit%2F537.36%20(KHTML%2C%20like%20Gecko)%20Chrome%2F134.0.0.0%20Mobile%20Safari%2F537.36%20Edg%2F134.0.0.0&term_type=2&jsVersion=4.2&terminal_type=2&lang=zh-cn&v=9451&lang=zh"
    else
        login_url="http://10.254.7.4:801/eportal/portal/login?callback=dr1004&login_method=1&user_account=%2C0%2C$USERNAME&user_password=$PASSWORD&wlan_user_ip=$v46ip&wlan_user_ipv6=&wlan_user_mac=&wlan_ac_ip=&wlan_ac_name=&ua=Mozilla%2F5.0%20(Windows%20NT%2010.0%3B%20Win64%3B%20x64)%20AppleWebKit%2F537.36%20(KHTML%2C%20like%20Gecko)%20Chrome%2F134.0.0.0%20Safari%2F537.36%20Edg%2F134.0.0.0&term_type=1&jsVersion=4.2&terminal_type=1&lang=zh-cn&v=9875&lang=zh"
    fi
    
    local response=$(curl -s "$login_url")
    local json_response=$(echo "$response" | grep -o '{.*}')
    
    if [ -n "$json_response" ]; then
        if echo "$json_response" | grep -q '"result":1'; then
            echo "认证成功! 响应: $json_response"
        else
            echo "认证失败! 响应: $json_response"
            exit 1
        fi
    else
        echo "错误: 未知响应: $response"
        exit 1
    fi
}

do_authentication "$ip_addr"