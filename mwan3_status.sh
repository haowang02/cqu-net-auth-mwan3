#!/bin/bash

# 状态查询URL
STATUS_URL="http://10.254.7.4/drcom/chkstatus?callback=dr1002&jsVersion=4.X&v=5505&lang=zh"

# 获取所有mwan3接口
get_mwan3_interfaces() {
    mwan3 interfaces | grep "interface " | awk '{print $2}'
}

# 解析JSON响应中的字段
parse_json_field() {
    local json="$1"
    local field="$2"
    
    # 提取包含dr1002回调的行，移除回调函数包装，只保留JSON部分，然后使用jq解析
    echo "$json" | grep 'dr1002(' | sed 's/.*dr1002(\(.*\)).*/\1/' | jq -r ".$field // \"N/A\""
}

main() {
    # 先打印 Interface status
    mwan3 interfaces
    
    # 再打印 Authentication status
    echo "Authentication status:"
    
    # 遍历所有接口
    local interfaces=$(get_mwan3_interfaces)
    for interface in $interfaces; do
        # 获取状态信息
        local response=$(mwan3 use "$interface" curl -s "$STATUS_URL" 2>/dev/null)
        
        if [ -z "$response" ]; then
            printf "%s\t查询失败\tN/A\tN/A\tN/A\n" "$interface"
            continue
        fi
        
        # 转换编码从GBK到UTF-8
        local utf8_response=$(echo "$response" | iconv -f GBK -t UTF-8 2>/dev/null)
        if [ $? -ne 0 ]; then
            utf8_response="$response"
        fi
        
        # 检查是否包含有效的JSON响应
        if ! echo "$utf8_response" | grep -q 'dr1002('; then
            printf "%s\t查询失败\tN/A\tN/A\tN/A\n" "$interface"
            continue
        fi
        
        # 提取各个字段
        local result=$(parse_json_field "$utf8_response" "result")
        local nid=$(parse_json_field "$utf8_response" "NID")
        local uid=$(parse_json_field "$utf8_response" "uid")
        local v4ip=$(parse_json_field "$utf8_response" "v4ip")
        
        # 认证状态
        local auth_status="未认证"
        if [ "$result" = "1" ]; then
            auth_status="已认证"
        fi
        
        # 输出格式化行（不包含物理接口名称）
        printf "%s\t%s\t%s\t%s\t%s\n" "$interface" "$auth_status" "$nid" "$uid" "$v4ip"
    done
}

# 执行主函数
main "$@"