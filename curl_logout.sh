#!/bin/bash

# 使用 curl 注销校园网
# 用法: mwan3 use [wan1|wan2|wan3|wan4] ./curl_logout.sh

# 执行注销
do_logout() {
    status_url="http://10.254.7.4/drcom/chkstatus?callback=dr1002&jsVersion=4.X&v=5505&lang=zh"
    local response=$(curl -s "$status_url" 2>/dev/null)
    response=$(echo "$response" | iconv -f GBK -t UTF-8 2>/dev/null)
    
    # 检查是否包含有效的响应
    if ! echo "$response" | grep -q 'dr1002('; then
        echo "错误: 获取状态信息失败"
        exit 1
    fi
    
    # 从响应中提取v46ip字段
    local v46ip=$(echo "$response" | sed -n 's/.*"v46ip":"\([^"]*\)".*/\1/p')
    # 从响应中提取uid字段
    local uid=$(echo "$response" | sed -n 's/.*"uid":"\([^"]*\)".*/\1/p')
    
    if [ -z "$v46ip" ]; then
        echo "错误: 无法获取端口IP地址"
        exit 1
    fi
    
    if [ -z "$uid" ]; then
        echo "错误: 无法获取认证账户"
        exit 1
    fi
    
    echo "开始注销 (IP地址: $v46ip, 认证账户: $uid)..."
    
    local logout_url="http://10.254.7.4:801/eportal/portal/mac/unbind?callback=dr1002&user_account=$uid&wlan_user_mac=000000000000&wlan_user_ip=$v46ip&jsVersion=4.2&v=6024&lang=zh"
    curl -s "$logout_url"
}

do_logout