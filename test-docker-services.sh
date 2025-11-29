#!/bin/bash
echo "=========================================="
echo "🔍 Docker 服务连通性测试"
echo "=========================================="
echo ""

echo "1️⃣  检查路由配置..."
ROUTE=$(ip route get 172.18.0.4 2>/dev/null | head -1)
if echo "$ROUTE" | grep -q "br-"; then
    echo "   ✅ 路由正确：$ROUTE"
else
    echo "   ❌ 路由错误：$ROUTE"
fi
echo ""

echo "2️⃣  测试容器网络连通性..."
if ping -c 1 -W 1 172.18.0.4 >/dev/null 2>&1; then
    echo "   ✅ 可以 ping 通 RabbitMQ 容器"
else
    echo "   ❌ 无法 ping 通 RabbitMQ 容器"
fi
echo ""

echo "3️⃣  测试 RabbitMQ 管理界面 (15672)..."
if curl -s -m 2 http://127.0.0.1:15672/ | grep -q "RabbitMQ"; then
    echo "   ✅ RabbitMQ 管理界面可访问"
    echo "      URL: http://127.0.0.1:15672/"
    echo "      用户: admin / Pass@2024Srv"
else
    echo "   ❌ RabbitMQ 管理界面不可访问"
fi
echo ""

echo "4️⃣  测试 RabbitMQ AMQP (5672)..."
if timeout 1 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/5672' 2>/dev/null; then
    echo "   ✅ RabbitMQ AMQP 端口可访问"
else
    echo "   ❌ RabbitMQ AMQP 端口不可访问"
fi
echo ""

echo "5️⃣  测试 MySQL (3306)..."
if timeout 1 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/3306' 2>/dev/null; then
    echo "   ✅ MySQL 端口可访问"
else
    echo "   ❌ MySQL 端口不可访问"
fi
echo ""

echo "6️⃣  测试 Redis (6379)..."
if timeout 1 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/6379' 2>/dev/null; then
    echo "   ✅ Redis 端口可访问"
else
    echo "   ❌ Redis 端口不可访问"
fi
echo ""

echo "=========================================="
echo "✅ 所有测试完成！"
echo "=========================================="
