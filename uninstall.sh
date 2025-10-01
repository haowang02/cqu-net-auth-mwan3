#!/bin/bash

echo "开始卸载 mwan3 认证脚本..."

echo "停止 mwan3_auth 服务..."
/etc/init.d/mwan3_auth stop
if [ $? -eq 0 ]; then
    echo "✓ mwan3_auth 服务已停止"
else
    echo "⚠ mwan3_auth 服务停止失败或服务未运行"
fi

echo "禁用 mwan3_auth 服务..."
/etc/init.d/mwan3_auth disable
if [ $? -eq 0 ]; then
    echo "✓ mwan3_auth 服务已禁用"
else
    echo "⚠ mwan3_auth 服务禁用失败或服务已禁用"
fi

echo "删除安装文件..."
if [ -f /usr/bin/mwan3_auth ]; then
    rm /usr/bin/mwan3_auth
    echo "✓ 已删除 /usr/bin/mwan3_auth"
else
    echo "⚠ /usr/bin/mwan3_auth 不存在"
fi

if [ -f /usr/bin/mwan3_status ]; then
    rm /usr/bin/mwan3_status
    echo "✓ 已删除 /usr/bin/mwan3_status"
else
    echo "⚠ /usr/bin/mwan3_status 不存在"
fi

if [ -f /usr/bin/curl_auth ]; then
    rm /usr/bin/curl_auth
    echo "✓ 已删除 /usr/bin/curl_auth"
else
    echo "⚠ /usr/bin/curl_auth 不存在"
fi

if [ -f /etc/init.d/mwan3_auth ]; then
    rm /etc/init.d/mwan3_auth
    echo "✓ 已删除 /etc/init.d/mwan3_auth"
else
    echo "⚠ /etc/init.d/mwan3_auth 不存在"
fi

if [ -f /var/run/mwan3_auth.pid ]; then
    rm /var/run/mwan3_auth.pid
    echo "✓ 已删除 /var/run/mwan3_auth.pid"
else
    echo "⚠ /var/run/mwan3_auth.pid 不存在"
fi

if [ -f /tmp/log/mwan3_auth.log ]; then
    rm /tmp/log/mwan3_auth.log
    echo "✓ 已删除 /tmp/log/mwan3_auth.log"
else
    echo "⚠ /tmp/log/mwan3_auth.log 不存在"
fi

echo "卸载完成！mwan3 认证脚本已成功卸载。"