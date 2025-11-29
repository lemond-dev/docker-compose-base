# Docker Services 使用文档

本文档说明如何使用 Docker Compose 管理 Redis、MySQL 8 和 RabbitMQ 服务。

## ⚙️ 首次配置

**重要**：在启动服务前，请先配置环境变量！

1. 复制环境变量模板：
   ```bash
   cp .env.example .env
   ```

2. 编辑 `.env` 文件，设置你的密码：
   ```bash
   vi .env  # 或使用其他编辑器
   ```

3. **注意**：`.env` 文件包含敏感信息，已被添加到 `.gitignore`，不会被提交到版本控制系统。

## 📋 服务列表

| 服务 | 版本 | 端口 | 管理界面 |
|------|------|------|---------|
| Redis | 7.2 | 127.0.0.1:6379 | - |
| MySQL | 8.0 | 127.0.0.1:3306 | - |
| RabbitMQ | 3.12 | 127.0.0.1:5672 | http://127.0.0.1:15672 |

## 🔐 密码配置

所有密码都通过 `.env` 文件配置，默认密码如下：

- **Redis 密码** (`REDIS_PASSWORD`): `Pass@2024Srv`
- **MySQL Root 密码** (`MYSQL_ROOT_PASSWORD`): `Pass@2024Srv`
- **RabbitMQ 用户名** (`RABBITMQ_DEFAULT_USER`): `admin`
- **RabbitMQ 密码** (`RABBITMQ_DEFAULT_PASS`): `Pass@2024Srv`

**重要提示**：
1. 生产环境请立即修改 `.env` 文件中的默认密码！
2. `.env` 文件已被添加到 `.gitignore`，不会被提交到 Git
3. 使用 `.env.example` 作为模板创建你自己的 `.env` 文件

## 📁 目录结构

```
Services/
├── docker-compose.yml       # Docker Compose 配置文件
├── .env                     # 环境变量配置（敏感信息，不提交到 Git）
├── .env.example             # 环境变量模板
├── .gitignore              # Git 忽略文件配置
├── README.md               # 使用文档（本文件）
├── TROUBLESHOOTING.md      # 故障排查文档
├── fix-docker-routes.sh    # Docker 路由修复脚本
├── test-docker-services.sh # 服务测试脚本
└── data/                   # 数据持久化目录（不提交到 Git）
    ├── .gitkeep            # 保留目录结构
    ├── redis/              # Redis 数据
    ├── mysql/              # MySQL 数据
    └── rabbitmq/           # RabbitMQ 数据
```

## 🚀 快速开始

### 1. 创建数据目录

```bash
mkdir -p data/{redis,mysql,rabbitmq}
```

### 2. 启动所有服务

```bash
# 后台启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f
```

### 3. 验证服务状态

```bash
# 检查所有服务健康状态
docker-compose ps

# 查看特定服务日志
docker-compose logs redis
docker-compose logs mysql
docker-compose logs rabbitmq
```

## 📝 常用命令

### 服务管理

```bash
# 启动所有服务
docker-compose up -d

# 停止所有服务
docker-compose stop

# 停止并删除容器（数据保留）
docker-compose down

# 停止并删除容器及数据卷（数据会丢失！）
docker-compose down -v

# 重启所有服务
docker-compose restart

# 重启单个服务
docker-compose restart redis
docker-compose restart mysql
docker-compose restart rabbitmq

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f [service_name]
```

### 进入容器

```bash
# 进入 Redis 容器
docker exec -it redis-server sh

# 进入 MySQL 容器
docker exec -it mysql-server bash

# 进入 RabbitMQ 容器
docker exec -it rabbitmq-server sh
```

## 🔧 服务连接方式

### Redis 连接

**命令行连接：**
```bash
# 使用 redis-cli 连接（密码在 .env 文件中配置）
redis-cli -h 127.0.0.1 -p 6379 -a 你的密码

# 或者先进入容器再连接
docker exec -it redis-server redis-cli -a 你的密码
```

**应用程序连接示例（Python）：**
```python
import redis
import os

r = redis.Redis(
    host='127.0.0.1',
    port=6379,
    password=os.getenv('REDIS_PASSWORD'),  # 从环境变量读取
    decode_responses=True
)

# 测试连接
r.ping()
```

**应用程序连接示例（Java/Spring Boot）：**
```yaml
spring:
  redis:
    host: 127.0.0.1
    port: 6379
    password: ${REDIS_PASSWORD}  # 从环境变量读取
```

### MySQL 连接

**命令行连接：**
```bash
# 使用 mysql 客户端连接（密码在 .env 文件中配置）
mysql -h 127.0.0.1 -P 3306 -uroot -p你的密码

# 或者使用 Docker 容器内的 mysql 客户端
docker exec -it mysql-server mysql -uroot -p你的密码
```

**应用程序连接示例（Python）：**
```python
import pymysql
import os

connection = pymysql.connect(
    host='127.0.0.1',
    port=3306,
    user='root',
    password=os.getenv('MYSQL_ROOT_PASSWORD'),  # 从环境变量读取
    charset='utf8mb4'
)
```

**应用程序连接示例（Java/Spring Boot）：**
```yaml
spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/your_database?useUnicode=true&characterEncoding=utf8mb4&serverTimezone=Asia/Shanghai
    username: root
    password: ${MYSQL_ROOT_PASSWORD}  # 从环境变量读取
```

### RabbitMQ 连接

**管理界面访问：**
```
URL: http://127.0.0.1:15672
用户名: admin（或 .env 中配置的用户名）
密码: 你的密码（在 .env 文件中配置）
```

**应用程序连接示例（Python）：**
```python
import pika
import os

credentials = pika.PlainCredentials(
    os.getenv('RABBITMQ_DEFAULT_USER', 'admin'),  # 从环境变量读取
    os.getenv('RABBITMQ_DEFAULT_PASS')
)
parameters = pika.ConnectionParameters(
    host='127.0.0.1',
    port=5672,
    credentials=credentials
)
connection = pika.BlockingConnection(parameters)
channel = connection.channel()
```

**应用程序连接示例（Java/Spring Boot）：**
```yaml
spring:
  rabbitmq:
    host: 127.0.0.1
    port: 5672
    username: ${RABBITMQ_DEFAULT_USER}  # 从环境变量读取
    password: ${RABBITMQ_DEFAULT_PASS}
```

## 🔒 修改密码

**推荐方法**：通过 `.env` 文件修改密码

1. 编辑 `.env` 文件：
   ```bash
   vi .env
   ```

2. 修改对应的密码变量：
   ```bash
   REDIS_PASSWORD=你的新密码
   MYSQL_ROOT_PASSWORD=你的新密码
   RABBITMQ_DEFAULT_PASS=你的新密码
   ```

3. 重启服务使更改生效：
   ```bash
   docker-compose down
   docker-compose up -d
   ```

**注意**：首次启动后修改密码需要额外步骤：

### 修改 MySQL 密码（已运行的容器）

1. 进入 MySQL 容器：
   ```bash
   docker exec -it mysql-server mysql -uroot -p旧密码
   ```

2. 执行 SQL 命令：
   ```sql
   ALTER USER 'root'@'%' IDENTIFIED BY '新密码';
   FLUSH PRIVILEGES;
   ```

3. 修改 `.env` 文件中的 `MYSQL_ROOT_PASSWORD`

4. 重启服务：
   ```bash
   docker-compose restart mysql
   ```

### 修改 RabbitMQ 密码（已运行的容器）

1. 进入 RabbitMQ 容器：
   ```bash
   docker exec -it rabbitmq-server sh
   ```

2. 执行命令：
   ```bash
   rabbitmqctl change_password admin 新密码
   ```

3. 修改 `.env` 文件中的 `RABBITMQ_DEFAULT_PASS`

4. 重启服务：
   ```bash
   docker-compose restart rabbitmq
   ```

## 🔍 健康检查

所有服务都配置了健康检查，可以通过以下命令查看：

```bash
docker-compose ps
```

健康状态说明：
- `healthy`: 服务运行正常
- `unhealthy`: 服务运行异常
- `starting`: 服务正在启动中

## 📊 数据备份

### Redis 数据备份

```bash
# 加载环境变量
source .env

# 备份 RDB 文件
docker exec redis-server redis-cli -a $REDIS_PASSWORD BGSAVE
cp data/redis/dump.rdb data/redis/dump.rdb.backup.$(date +%Y%m%d)
```

### MySQL 数据备份

```bash
# 加载环境变量
source .env

# 备份所有数据库
docker exec mysql-server mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --all-databases > backup_$(date +%Y%m%d).sql

# 备份指定数据库
docker exec mysql-server mysqldump -uroot -p$MYSQL_ROOT_PASSWORD database_name > database_backup_$(date +%Y%m%d).sql
```

### RabbitMQ 数据备份

```bash
# 导出配置和定义
docker exec rabbitmq-server rabbitmqctl export_definitions /tmp/rabbitmq_definitions.json
docker cp rabbitmq-server:/tmp/rabbitmq_definitions.json ./rabbitmq_backup_$(date +%Y%m%d).json
```

## 🔧 故障排查

### 服务无法启动

1. 检查端口是否被占用：
   ```bash
   netstat -tuln | grep -E '6379|3306|5672|15672'
   ```

2. 查看容器日志：
   ```bash
   docker-compose logs [service_name]
   ```

3. 检查数据目录权限：
   ```bash
   ls -la data/
   ```

### 连接被拒绝

由于所有服务都绑定到 `127.0.0.1`，只能从本机访问。如果需要从其他机器访问，需要修改 `docker-compose.yml` 中的端口映射：

```yaml
# 从这样（只允许本机访问）
ports:
  - "127.0.0.1:6379:6379"

# 改为这样（允许所有网络接口访问，不安全！）
ports:
  - "6379:6379"
```

### 数据丢失

确保 `data/` 目录下的数据没有被删除。如果执行了 `docker-compose down -v`，数据卷会被删除。

## ⚠️ 安全建议

1. **立即修改默认密码**：生产环境必须使用强密码（在 `.env` 文件中配置）
2. **保护 `.env` 文件**：
   - `.env` 文件已被添加到 `.gitignore`，确保不会提交到版本控制
   - 设置适当的文件权限：`chmod 600 .env`
   - 不要在公共场合分享 `.env` 文件内容
3. **限制网络访问**：当前配置已限制只能本机访问（127.0.0.1）
4. **定期备份数据**：建议设置定时任务自动备份
5. **设置防火墙规则**：即使端口绑定到 127.0.0.1，也建议配置防火墙
6. **定期更新镜像**：及时更新 Docker 镜像以获取安全补丁
7. **使用强密码**：密码应包含大小写字母、数字和特殊字符，长度至少 16 位

## 📚 参考文档

- [Redis 官方文档](https://redis.io/documentation)
- [MySQL 8.0 官方文档](https://dev.mysql.com/doc/refman/8.0/en/)
- [RabbitMQ 官方文档](https://www.rabbitmq.com/documentation.html)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 📝 版本信息

- Docker Compose 文件版本: 3.8
- Redis: 7.2-alpine
- MySQL: 8.0
- RabbitMQ: 3.12-management-alpine

---

**最后更新**: 2025-11-29

