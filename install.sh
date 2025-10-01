#!/bin/bash

echo "开始安装 mwan3 认证脚本..."

echo "复制 mwan3_auth.sh 到 /usr/bin/..."
cp mwan3_auth.sh /usr/bin/mwan3_auth && chmod +x /usr/bin/mwan3_auth
if [ $? -eq 0 ]; then
    echo "✓ mwan3_auth.sh 安装成功"
else
    echo "✗ mwan3_auth.sh 安装失败"
    exit 1
fi

echo "复制 mwan3_status.sh 到 /usr/bin/..."
cp mwan3_status.sh /usr/bin/mwan3_status && chmod +x /usr/bin/mwan3_status
if [ $? -eq 0 ]; then
    echo "✓ mwan3_status.sh 安装成功"
else
    echo "✗ mwan3_status.sh 安装失败"
    exit 1
fi

echo "复制 curl_auth.sh 到 /usr/bin/..."
cp curl_auth.sh /usr/bin/curl_auth && chmod +x /usr/bin/curl_auth
if [ $? -eq 0 ]; then
    echo "✓ curl_auth.sh 安装成功"
else
    echo "✗ curl_auth.sh 安装失败"
    exit 1
fi

echo "复制 mwan3_auth.init 到 /etc/init.d/..."
cp mwan3_auth.init /etc/init.d/mwan3_auth && chmod +x /etc/init.d/mwan3_auth
if [ $? -eq 0 ]; then
    echo "✓ mwan3_auth.init 安装成功"
else
    echo "✗ mwan3_auth.init 安装失败"
    exit 1
fi

echo "启用 mwan3_auth 服务..."
/etc/init.d/mwan3_auth enable
if [ $? -eq 0 ]; then
    echo "✓ mwan3_auth 服务启用成功"
else
    echo "✗ mwan3_auth 服务启用失败"
    exit 1
fi

echo "启动 mwan3_auth 服务..."
/etc/init.d/mwan3_auth start
if [ $? -eq 0 ]; then
    echo "✓ mwan3_auth 服务启动成功"
else
    echo "✗ mwan3_auth 服务启动失败"
    exit 1
fi

echo "安装完成！mwan3 认证脚本已成功安装并启动。"