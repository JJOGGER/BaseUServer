# BaseU Server

BaseU 数字资产管理平台服务端

## 项目简介

BaseU 是一个数字资产管理平台，提供用户注册、登录、充值、转账等核心功能。

### 核心功能

- ✅ 用户认证：注册、登录、登出、Token刷新
- ✅ 账户管理：用户信息管理、密码修改
- ✅ 充值功能：充值订单创建、充值记录查询
- ✅ 交易功能：交易记录查询
- ✅ 验证码：邮箱/短信验证码发送

## 技术栈

- **Java 17**
- **Spring Boot 3.2.0**
- **Spring Security + JWT**
- **MySQL 8.0+**
- **MyBatis Plus 3.5.4**
- **Redis 7.0+**
- **Flyway** (数据库迁移)
- **Swagger/OpenAPI** (API文档)

## ⚡ 快速开始

### 环境要求

- JDK 17+
- MySQL 8.0+（**无需手动创建数据库**）
- Redis 7.0+（可选）
- Maven 3.8+（可选）

### 🎯 三步启动

#### Windows 用户（推荐）

```batch
# 1. 配置环境（可选，或手动编辑配置文件）
env-setup.bat

# 2. 启动服务（数据库自动创建）
start.bat

# 3. 访问 http://localhost:8080/swagger-ui.html
```

✨ **新功能**：
- ✅ **数据库自动创建** - 无需手动执行SQL
- ✅ **环境自动区分** - 开发/生产环境清晰分离
- ✅ **Windows优化** - 专属批处理脚本

详见：[WINDOWS_GUIDE.md](WINDOWS_GUIDE.md)

#### Linux/Mac 用户

1. **克隆项目**
```bash
git clone https://github.com/your-org/baseu-server.git
cd baseu-server
```

2. **~~创建数据库~~（已自动化）**

✨ **数据库会在首次启动时自动创建**，只需确保MySQL已启动！

3. **配置数据库连接**

编辑 `src/main/resources/application-dev.yml`:
```yaml
spring:
  datasource:
    username: root
    password: your_password  # 修改密码
```

4. **运行项目**
```bash
# 开发环境
mvn spring-boot:run -Dspring.profiles.active=dev

# 或使用启动脚本
chmod +x start.sh
./start.sh
```

5. **访问API文档**

启动成功后访问: http://localhost:8080/swagger-ui.html

## 数据库迁移

项目使用Flyway进行数据库版本管理，启动时会自动执行迁移脚本。

### Flyway命令

```bash
# 查看迁移状态
mvn flyway:info

# 执行迁移
mvn flyway:migrate

# 验证迁移
mvn flyway:validate

# 清理数据库（慎用！仅开发环境）
mvn flyway:clean
```

## API接口

### 认证接口

- `POST /api/auth/send-code` - 发送验证码
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/refresh-token` - 刷新Token

### 用户接口

- `GET /api/user/info` - 获取用户信息
- `PUT /api/user/password` - 修改密码

### 充值接口

- `POST /api/recharge/create` - 创建充值订单
- `GET /api/recharge/list` - 查询充值记录

### 交易接口

- `GET /api/transaction/list` - 查询交易记录

详细API文档请访问Swagger UI。

## Docker部署

### 构建镜像

```bash
mvn clean package -DskipTests
docker build -t baseu-server:1.0.0 .
```

### 使用Docker Compose

```bash
docker-compose up -d
```

## 项目结构

```
baseu-server/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/zero/baseu/
│   │   │       ├── BaseUApplication.java
│   │   │       ├── config/              # 配置类
│   │   │       ├── controller/          # 控制器
│   │   │       ├── service/             # 服务层
│   │   │       ├── mapper/              # 数据访问层
│   │   │       ├── entity/              # 实体类
│   │   │       ├── dto/                 # 数据传输对象
│   │   │       ├── security/            # 安全相关
│   │   │       ├── common/              # 公共类
│   │   │       └── util/                # 工具类
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-prod.yml
│   │       ├── mapper/                  # MyBatis XML
│   │       └── db/migration/            # Flyway迁移脚本
│   └── test/
└── pom.xml
```

## ⚙️ 配置说明

### 环境配置

#### 开发环境（dev）

配置文件：`src/main/resources/application-dev.yml`

```yaml
spring:
  datasource:
    username: root
    password: root  # 修改为你的密码

jwt:
  secret: dev-secret-key-for-development
```

#### 生产环境（prod）

使用环境变量（`.env`文件）：

```properties
DB_HOST=your-mysql-host
DB_PASSWORD=your-secure-password
REDIS_HOST=your-redis-host
JWT_SECRET=your-random-256-bit-secret
```

### 环境切换

**Windows**:
```batch
start.bat  # 选择对应环境
```

**Linux/Mac**:
```bash
# 开发环境
mvn spring-boot:run -Dspring.profiles.active=dev

# 生产环境  
java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=prod
```

## 开发指南

### 添加新接口

1. 在 `entity/` 创建实体类
2. 在 `mapper/` 创建Mapper接口和XML
3. 在 `service/` 创建Service接口和实现
4. 在 `controller/` 创建Controller
5. 编写测试用例

### 数据库迁移

在 `src/main/resources/db/migration/` 目录下创建新的迁移脚本：

格式：`V{版本号}__{描述}.sql`

示例：`V4__add_user_avatar.sql`

## 安全性

- 密码使用BCrypt加盐哈希存储
- API使用JWT Token认证
- 支持接口限流（防止暴力攻击）
- 敏感信息脱敏处理
- SQL注入防护（MyBatis Plus参数化查询）

## 测试

```bash
# 运行测试
mvn test

# 跳过测试打包
mvn clean package -DskipTests
```

## 常见问题

### 1. 数据库连接失败

检查MySQL是否启动，用户名密码是否正确。

### 2. Redis连接失败

检查Redis是否启动，端口是否正确。

### 3. JWT Token过期

Token默认有效期2小时，使用refresh-token刷新。

## 许可证

MIT License

## 联系方式

- 作者：Zero Team
- 邮箱：team@baseu.com
- 文档：详见 `SERVER_DEVELOPMENT_GUIDE.md`

---

**版本**: 1.0.0  
**最后更新**: 2024-01-01

