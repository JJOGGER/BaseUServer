# 快速启动指南

## ⚡ 超快启动（推荐）

### Windows 用户

**三步启动，无需手动创建数据库！**

```batch
# 1. 配置环境（自动生成配置文件）
env-setup.bat

# 2. 启动服务（数据库自动创建）
start.bat

# 3. 访问 http://localhost:8080/swagger-ui.html
```

✅ **数据库自动创建** - 无需手动执行SQL  
✅ **环境自动识别** - 开发/生产环境自动切换  
✅ **一键启动** - 双击即可运行

详细说明请查看：**[WINDOWS_GUIDE.md](WINDOWS_GUIDE.md)**

---

### Linux/Mac 用户

```bash
# 1. 配置环境
编辑 src/main/resources/application-dev.yml

# 2. 启动服务
./start.sh

# 3. 访问 http://localhost:8080/swagger-ui.html
```

---

## 📋 详细步骤

### 前置准备

确保已安装以下软件：

- **JDK 17+**
- **MySQL 8.0+** （只需启动，无需创建数据库）
- **Redis 7.0+** （可选）
- **Maven 3.8+** （可选，IDE自带也可以）

### 第一步：~~创建数据库~~（已自动化！）

**✨ 新功能：无需手动创建数据库！**

项目启动时会自动检查并创建数据库。您只需：
1. 启动 MySQL 服务
2. 确保用户名密码正确

数据库会自动创建并执行迁移脚本！

### 第二步：配置项目

#### Windows 用户（推荐）

**方式一：使用配置助手**
```batch
env-setup.bat
```
按提示输入配置，自动生成配置文件。

**方式二：手动配置**
编辑 `src\main\resources\application-dev.yml`：
```yaml
spring:
  datasource:
    username: root
    password: your_password  # 修改为你的MySQL密码
```

#### Linux/Mac 用户

编辑 `src/main/resources/application-dev.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/baseu?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
    username: root
    password: your_password  # 修改为你的MySQL密码
  
  data:
    redis:
      host: localhost
      port: 6379
      password: # 如果Redis有密码，在这里填写

jwt:
  secret: dev-secret-key-for-development  # 生产环境必须修改
```

### 第三步：启动服务

#### Windows 用户（推荐）

**双击运行 `start.bat`**，选择启动方式：

```batch
start.bat
```

- 选项1：Maven启动（开发推荐）
- 选项2：JAR包启动（生产推荐）
- 选项3：Docker启动
- 选项4：生产环境启动

#### Linux/Mac 用户

**方式一：使用Maven（推荐开发环境）**

```bash
mvn spring-boot:run -Dspring.profiles.active=dev
```

**方式二：打包后运行**

```bash
mvn clean package -DskipTests
java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=dev
```

**方式三：使用启动脚本**

```bash
chmod +x start.sh
./start.sh
```

## 第四步：验证服务

### 查看启动信息

启动成功后，会显示：

```
========================================
   BaseU Server (开发环境) 启动成功！
========================================
环境: development
配置: dev

访问地址:
------------------------------------------
本地: http://localhost:8080/
外部: http://192.168.1.100:8080/

API文档:
------------------------------------------
Swagger: http://localhost:8080/swagger-ui.html

========================================
✅ 数据库 baseu 已存在
✅ Flyway 迁移完成
```

### 访问Swagger API文档

打开浏览器访问：http://localhost:8080/swagger-ui.html

### 测试接口

#### 1. 发送验证码

```bash
curl -X POST http://localhost:8080/api/auth/send-code \
  -H "Content-Type: application/json" \
  -d '{
    "target": "test@example.com",
    "type": 1
  }'
```

#### 2. 用户注册

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test1234",
    "verificationCode": "123456",
    "countryCode": "CN",
    "dialCode": "+86"
  }'
```

#### 3. 用户登录

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "account": "test@example.com",
    "password": "Test1234"
  }'
```

响应示例：
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "userId": 1,
    "username": "test",
    "email": "test@example.com",
    "token": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "expiresIn": 7200
  },
  "timestamp": 1699000000000
}
```

#### 4. 获取用户信息（需要Token）

```bash
curl -X GET http://localhost:8080/api/user/info \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## 🐳 使用Docker部署

### Windows 用户

```batch
# 方式一：使用启动脚本
start.bat
# 选择 3) Docker启动

# 方式二：命令行
docker-compose up -d
```

### Linux/Mac 用户

**1. 创建环境变量文件**

```bash
cp .env.example .env
```

编辑 `.env` 文件，设置密码和密钥。

**2. 启动Docker容器**

```bash
docker-compose up -d
```

**3. 查看日志**

```bash
docker-compose logs -f app
```

**4. 停止服务**

```bash
docker-compose down
```

## 🔄 数据库迁移（自动）

项目使用Flyway进行数据库版本管理，**首次启动时会自动执行**：

1. ✅ **自动创建数据库** - 检测到数据库不存在时自动创建
2. ✅ **自动执行迁移** - 依次执行以下SQL脚本：
   - `V1__init_database.sql` - 初始化数据库（用户表、账户表、验证码表）
   - `V2__add_user_country.sql` - 添加国家代码字段
   - `V3__add_recharge_table.sql` - 添加充值和交易表

**您无需手动操作，一切都是自动的！**

## ❓ 常见问题

### 1. 数据库自动创建失败

**问题**：提示 "数据库初始化失败"

**解决**：
1. 确认MySQL服务已启动
2. 检查用户名和密码是否正确
3. 确认MySQL用户有创建数据库的权限：
   ```sql
   GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost';
   FLUSH PRIVILEGES;
   ```

### 2. 端口占用

**问题**：`Port 8080 was already in use`

**解决**：修改 `application-dev.yml` 中的端口：
```yaml
server:
  port: 8081
```

### 3. 环境配置混淆

**开发环境**：
- 配置文件：`application-dev.yml`
- 启动命令：`-Dspring.profiles.active=dev`
- 标识：启动时显示 "开发环境"

**生产环境**：
- 配置方式：环境变量（`.env`文件）
- 启动命令：`-Dspring.profiles.active=prod`
- 标识：启动时显示 "生产环境"

### 4. Windows下脚本无法运行

**问题**：双击 `.bat` 文件闪退

**解决**：
1. 右键 → 以管理员身份运行
2. 或在命令提示符中运行：
   ```batch
   cd G:\code\BaseUServer
   start.bat
   ```

### 5. Redis连接失败（可选服务）

**解决**：Redis是可选的，如果暂时不需要，可以：
1. 使用Docker快速启动：`docker run -d -p 6379:6379 redis:7-alpine`
2. 或暂时禁用Redis相关功能

## 📚 下一步

- **Windows用户**：查看 [WINDOWS_GUIDE.md](WINDOWS_GUIDE.md) 了解更多Windows专属功能
- **API文档**：http://localhost:8080/swagger-ui.html
- **开发指南**：`SERVER_DEVELOPMENT_GUIDE.md`
- **项目说明**：`README.md`

## 🎯 环境切换

### 开发环境 → 生产环境

**Windows**:
```batch
start.bat
# 选择 4) 切换到生产环境启动
```

**Linux/Mac**:
```bash
java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=prod
```

### 环境对比

| 特性 | 开发环境 (dev) | 生产环境 (prod) |
|------|---------------|----------------|
| 配置方式 | 配置文件 | 环境变量 |
| 日志级别 | DEBUG | INFO |
| 数据库创建 | ✅ 自动 | ✅ 自动 |
| 环境标识 | "开发环境" | "生产环境" |
| JWT密钥 | 默认密钥 | 必须配置 |

## 💡 技术支持

如有问题，请查看：
- **Windows指南**：`WINDOWS_GUIDE.md`（Windows用户必读）
- **API文档**：http://localhost:8080/swagger-ui.html
- **开发文档**：`SERVER_DEVELOPMENT_GUIDE.md`
- **项目总结**：`PROJECT_SUMMARY.md`

---

**祝你使用愉快！** 🎉

