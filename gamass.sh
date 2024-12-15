#!/bin/bash

# Shadowsocks 批量配置脚本
# 请确保已安装 shadowsocks-libev

# 配置文件目录
CONFIG_DIR="/etc/shadowsocks"
mkdir -p $CONFIG_DIR

# 检查是否安装 Shadowsocks
if ! command -v ss-server &> /dev/null; then
    echo "未检测到 Shadowsocks，请先安装 shadowsocks-libev。"
    exit 1
fi

# 配置参数
PASSWORD="gama"  # 设置统一的密码
METHOD="aes-256-gcm"      # 加密方式
PORT_START=36009           # 起始端口
PORT_COUNT=1             # 要配置的端口数量
IP_LIST=("192.168.1.1" "192.168.1.2")  # 替换为你的多IP地址列表

# 批量生成配置
for IP in "${IP_LIST[@]}"; do
    for ((i=0; i<PORT_COUNT; i++)); do
        PORT=$((PORT_START + i))
        CONFIG_FILE="$CONFIG_DIR/ss-$IP-$PORT.json"

        # 生成配置文件
        cat > $CONFIG_FILE <<EOF
{
    "server": "$IP",
    "server_port": $PORT,
    "password": "$PASSWORD",
    "method": "$METHOD",
    "timeout": 300,
    "fast_open": true
}
EOF

        echo "生成配置文件: $CONFIG_FILE"

        # 启动 Shadowsocks 服务
        nohup ss-server -c $CONFIG_FILE &> /var/log/ss-$IP-$PORT.log &
        echo "启动 Shadowsocks 服务: $IP:$PORT"
    done
done

echo "所有 Shadowsocks 服务已启动。"
