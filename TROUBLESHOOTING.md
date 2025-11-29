# Docker 服务故障排查

## 问题描述

Docker 容器端口无法从宿主机访问，表现为：
- `docker ps` 显示端口正常映射
- `netstat`/`ss` 显示端口正在监听
- 但 `curl` 或其他客户端连接超时

## 根本原因

**Tailscale 路由劫持了 Docker 网络流量**

Tailscale 在路由表 52 中配置了 `172.16.0.0/12` 的路由，这个范围包含了 Docker 默认使用的 `172.18.0.0/16` 网段。由于路由策略规则，Tailscale 路由表的优先级高于主路由表，导致所有发往 Docker 容器的流量都被路由到 Tailscale 接口，而不是 Docker 网桥。

## 诊断步骤

1. **检查路由**：
   ```bash
   ip route get 172.18.0.4  # 应该走 br-xxx (Docker 网桥)，而不是 tailscale0
   ```

2. **检查路由表 52**：
   ```bash
   ip route show table 52 | grep 172.16
   ```

3. **检查路由策略**：
   ```bash
   ip rule show  # 查看路由表优先级
   ```

4. **测试连通性**：
   ```bash
   ping 172.18.0.4  # Docker 容器 IP
   ```

## 解决方案

### 临时修复（立即生效）

```bash
sudo ip route del 172.16.0.0/12 dev tailscale0 table 52
```

### 永久修复（已配置）

已创建 systemd 服务 `fix-docker-routes.service`，在系统启动时自动删除冲突的 Tailscale 路由。

**服务文件位置**：
- 脚本：`/home/ec2-user/Services/fix-docker-routes.sh`
- 服务：`/etc/systemd/system/fix-docker-routes.service`

**管理命令**：
```bash
# 查看服务状态
sudo systemctl status fix-docker-routes.service

# 手动运行修复
sudo /home/ec2-user/Services/fix-docker-routes.sh

# 禁用服务（如果不需要）
sudo systemctl disable fix-docker-routes.service
```

## 验证修复

```bash
# 1. 检查路由
ip route get 172.18.0.4

# 2. 测试 RabbitMQ
curl http://127.0.0.1:15672/

# 3. 测试 MySQL
mysqladmin -h 127.0.0.1 -u root -pPass@2024Srv ping

# 4. 测试 Redis
redis-cli -h 127.0.0.1 -p 6379 -a Pass@2024Srv ping
```

## 服务访问信息

### RabbitMQ
- AMQP 端口：`127.0.0.1:5672`
- 管理界面：`http://127.0.0.1:15672/`
- 用户名：`admin`
- 密码：`Pass@2024Srv`

### MySQL
- 端口：`127.0.0.1:3306`
- 用户：`root`
- 密码：`Pass@2024Srv`

### Redis
- 端口：`127.0.0.1:6379`
- 密码：`Pass@2024Srv`

## 注意事项

1. **不建议删除整个 172.16.0.0/12 路由**，如果 Tailscale 网络中确实有使用这个段的设备，删除后会影响访问
2. **更好的长期解决方案**是修改 Docker 网络配置，使用不与 Tailscale 冲突的网段（如 `10.x.x.x`）
3. 如果 Tailscale 配置更新后路由恢复，可能需要重新运行修复脚本

## 相关链接

- [Tailscale Routing Documentation](https://tailscale.com/kb/1019/subnets/)
- [Docker Network Documentation](https://docs.docker.com/network/)
- [Linux IP Route Documentation](https://man7.org/linux/man-pages/man8/ip-route.8.html)

