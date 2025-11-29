#!/bin/bash
# 修复 Docker 网络路由被 Tailscale 劫持的问题
# 从 Tailscale 路由表中删除 172.16.0.0/12 路由，避免与 Docker 网络 172.18.0.0/16 冲突

# 检查路由是否存在
if ip route show table 52 | grep -q "172.16.0.0/12"; then
    echo "删除 Tailscale 路由表中的 172.16.0.0/12 路由..."
    ip route del 172.16.0.0/12 dev tailscale0 table 52 2>/dev/null || true
    echo "路由已删除"
else
    echo "172.16.0.0/12 路由不存在，无需删除"
fi

# 验证 Docker 网络路由
echo "当前到 Docker 容器的路由："
ip route get 172.18.0.4

