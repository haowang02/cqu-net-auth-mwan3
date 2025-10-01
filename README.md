# CQU网络认证 - MWAN3版

重庆大学校园网 OpenWrt 多WAN自动认证脚本。

## 功能特性

- 🔄 **多WAN认证**: 支持同时管理多个网络接口的认证
- 🚀 **自动重连**: 检测接口离线状态，自动进行重新认证
- 📱 **设备类型支持**: 支持PC和移动设备两种认证模式
- 🔧 **手动认证**: 提供独立的curl认证工具

## 文件说明

- `mwan3_auth.sh` - 主认证守护进程
- `mwan3_status.sh` - 状态查询工具
- `curl_auth.sh` - 独立的curl认证工具
- `install.sh` - 安装脚本
- `uninstall.sh` - 卸载脚本
- `mwan3_auth.init` - OpenWrt系统服务配置

## 安装

### ⚠️ 重要：配置认证信息

编辑 `mwan3_auth.sh` 文件，找到配置数组部分，按照以下格式修改：

```bash
# 认证信息 mwan3_name:interface:username:password:term_type
declare -a INTERFACE_CONFIGS=(
    "wan1:eth0:2025xxxx:password:mobile"
    "wan2:eth1:2025xxxx:password:mobile"
    "wan3:eth2:2025xxxx:password:pc"
    "wan4:eth3:2025xxxx:password:pc"
)
```

**配置说明：**
- `mwan3_name`: MWAN3接口名称（如 wan1, wan2 等）
- `interface`: 物理网络接口名称（如 eth0, eth1 等）
- `username`: 校园网账号
- `password`: 校园网密码
- `term_type`: 终端类型，可选值（校园网目前支持2个PC和一个Mobile同时在线）：
  - `mobile`: 移动设备
  - `pc`: PC设备

### 其他配置项

您还可以根据需要调整以下参数：

```bash
# 检查间隔时间（秒）
CHECK_INTERVAL=10

# 日志文件路径
LOGFILE="/tmp/log/mwan3_auth.log"
```

### 安装

1. 将修改配置后的所有文件上传到 OpenWrt 路由器
2. 运行安装脚本：
```bash
chmod +x install.sh
./install.sh
```


## 使用方法

### mwan3_auth - 自动认证服务

认证服务会在系统启动时自动启动，您也可以手动控制：

```bash
# 启动服务
/etc/init.d/mwan3_auth start

# 停止服务
/etc/init.d/mwan3_auth stop

# 重启服务
/etc/init.d/mwan3_auth restart

# 查看服务状态
/etc/init.d/mwan3_auth status

# 启用开机自启动
/etc/init.d/mwan3_auth enable

# 禁用开机自启动
/etc/init.d/mwan3_auth disable
```

**日志查看：**
```bash
cat /tmp/log/mwan3_auth.log
```

### mwan3_status - 状态查询工具

查看所有MWAN3接口的连接状态和认证信息：

```bash
mwan3_status
```

### curl_auth - 手动认证工具

用于手动进行单次认证，适用于测试或临时认证：

```bash
# 基本用法
curl_auth <学号> <密码> [终端类型]

# 通过 mwan3 指定认证 wan2
mwan3 use wan2 curl_auth <学号> <密码> [终端类型]
```

## 卸载

```bash
chmod +x uninstall.sh
./uninstall.sh
```