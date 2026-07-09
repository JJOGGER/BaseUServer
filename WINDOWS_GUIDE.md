# Windows 系统快速启动指南

## 🖥️ Windows 环境说明

本项目已针对 Windows 系统进行优化，提供了便捷的批处理脚本。

## ⚡ 快速开始（三步启动）

### 第一步：安装依赖

确保已安装以下软件：

1. **Java 17+** 
   - 下载：https://www.oracle.com/java/technologies/downloads/#java17
   - 验证：`java -version`

2. **MySQL 8.0+**
   - 下载：https://dev.mysql.com/downloads/mysql/
   - 启动MySQL服务

3. **Redis** (可选)
   - 下载：https://github.com/tporadowski/redis/releases
   - 或使用Docker：`docker run -d -p 6379:6379 redis:7-alpine`

4. **Maven 3.8+** (可选，使用IDE自带的也可以)
   - 下载：https://maven.apache.org/download.cgi

### 第二步：配置环境

**方式一：使用配置助手（推荐）**

双击运行 `env-setup.bat`，按提示输入配置：

```bash
env-setup.bat
```

程序会自动生成配置文件。

**方式二：手动配置**

编辑 `src\main\resources\application-dev.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/baseu?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false&allowPublicKeyRetrieval=true
    username: root
    password: 你的MySQL密码  # 修改这里
  
  data:
    redis:
      host: localhost
      port: 6379
```

### 第三步：启动项目

双击运行 `start.bat`，选择启动方式：

```bash
start.bat
```

选项说明：
- **选项1 - Maven启动**：开发环境推荐，支持热重载
- **选项2 - JAR包启动**：生产环境推荐，性能更好
- **选项3 - Docker启动**：容器化部署
- **选项4 - 生产环境**：切换到生产配置启动

## 📋 详细步骤

### 1. 环境配置详解

#### 开发环境配置

```batch
# 运行配置助手
env-setup.bat

# 选择 1) 开发环境
# 按提示输入：
MySQL地址: localhost
MySQL端口: 3306
数据库名: baseu
数据库用户名: root
数据库密码: [你的密码]
Redis地址: localhost
Redis端口: 6379
```

配置完成后，自动生成 `application-dev.yml`

#### 生产环境配置

```batch
# 运行配置助手
env-setup.bat

# 选择 2) 生产环境
# 会生成 .env 文件模板，手动编辑：
```

编辑 `.env` 文件：
```properties
# MySQL配置
DB_HOST=your-production-mysql-host
DB_PORT=3306
DB_NAME=baseu
DB_USERNAME=baseu
DB_PASSWORD=your-secure-password

# Redis配置
REDIS_HOST=your-production-redis-host
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password

# JWT配置
JWT_SECRET=your-random-256-bit-secret-key
```

### 2. 启动方式详解

#### 方式一：Maven 启动（推荐开发）

```batch
# 直接运行
start.bat
# 选择 1

# 或者在命令行
mvn spring-boot:run -Dspring.profiles.active=dev
```

**优点**：
- ✅ 支持代码热重载
- ✅ 无需打包
- ✅ 适合开发调试

#### 方式二：JAR 包启动

```batch
# 直接运行
start.bat
# 选择 2

# 或者在命令行
# 1. 打包
mvn clean package -DskipTests

# 2. 运行
java -jar target\baseu-server-1.0.0.jar --spring.profiles.active=dev
```

**优点**：
- ✅ 性能更好
- ✅ 更接近生产环境
- ✅ 可以独立运行

#### 方式三：Docker 启动

```batch
# 直接运行
start.bat
# 选择 3

# 或者在命令行
docker-compose up -d
```

**优点**：
- ✅ 一键启动所有服务（MySQL + Redis + App）
- ✅ 环境隔离
- ✅ 便于部署

### 3. 验证启动成功

启动成功后，会看到类似输出：

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
```

访问 Swagger 文档测试接口：
http://localhost:8080/swagger-ui.html

## 🔧 常见问题解决

### 问题1：数据库连接失败

**错误信息**：
```
Communications link failure
```

**解决方案**：
1. 确认MySQL服务已启动
   ```batch
   # 查看MySQL服务状态
   sc query MySQL80
   
   # 启动MySQL服务
   net start MySQL80
   ```

2. 检查密码是否正确（`application-dev.yml`）

3. **不需要手动创建数据库**，项目会自动创建！

### 问题2：端口被占用

**错误信息**：
```
Port 8080 was already in use
```

**解决方案**：

**方式一：修改端口**

编辑 `application-dev.yml`：
```yaml
server:
  port: 8081  # 改为其他端口
```

**方式二：关闭占用端口的程序**
```batch
# 查找占用8080端口的程序
netstat -ano | findstr :8080

# 关闭进程（替换PID为实际的进程ID）
taskkill /F /PID 进程ID
```

### 问题3：Redis连接失败

**错误信息**：
```
Unable to connect to Redis
```

**解决方案**：

**方式一：安装Redis**
```batch
# 使用Docker运行Redis（推荐）
docker run -d -p 6379:6379 --name baseu-redis redis:7-alpine
```

**方式二：禁用Redis（测试用）**

暂时注释掉Redis相关代码，或使用内存缓存替代。

### 问题4：Maven命令不识别

**错误信息**：
```
'mvn' 不是内部或外部命令
```

**解决方案**：

**方式一：使用IDE**
- IDEA：右键项目 → Run 'BaseUApplication'
- Eclipse：右键项目 → Run As → Spring Boot App

**方式二：安装Maven**
1. 下载：https://maven.apache.org/download.cgi
2. 配置环境变量 `MAVEN_HOME`
3. 添加 `%MAVEN_HOME%\bin` 到 `PATH`

**方式三：使用Maven Wrapper**
```batch
mvnw.cmd spring-boot:run
```

### 问题5：Flyway迁移失败

**解决方案**：

项目会自动创建数据库，但如果迁移失败，可以手动重置：

```sql
# 连接MySQL
mysql -u root -p

# 删除并重建数据库
DROP DATABASE IF EXISTS baseu;
CREATE DATABASE baseu DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 退出
exit;
```

然后重新启动项目，Flyway会自动执行迁移。

## 🚀 开发环境 vs 生产环境

### 开发环境 (dev)

```batch
# 启动开发环境
start.bat
# 选择 1 或 2
```

**特点**：
- 数据库：本地MySQL
- Redis：本地Redis
- 日志级别：DEBUG
- 自动重载：支持
- 数据库：自动创建

**配置文件**：`application-dev.yml`

### 生产环境 (prod)

```batch
# 启动生产环境
start.bat
# 选择 4
```

**特点**：
- 数据库：通过环境变量配置
- Redis：通过环境变量配置
- 日志级别：INFO
- 安全增强：JWT密钥必须配置
- 数据库：自动创建

**配置方式**：环境变量（`.env` 文件）

## 📝 环境切换

### 方式一：使用启动脚本

```batch
start.bat
# 选择对应的环境选项
```

### 方式二：命令行指定

```batch
# 开发环境
mvn spring-boot:run -Dspring.profiles.active=dev

# 生产环境
java -jar target\baseu-server-1.0.0.jar --spring.profiles.active=prod
```

### 方式三：IDE配置

**IDEA**：
1. Run → Edit Configurations
2. Active profiles: `dev` 或 `prod`

**Eclipse**：
1. Run Configurations
2. Arguments → Program arguments: `--spring.profiles.active=dev`

## 💡 开发技巧

### 1. 热重载（开发环境）

使用Maven启动支持热重载：
```batch
mvn spring-boot:run -Dspring.profiles.active=dev
```

修改代码后自动重启。

### 2. 查看日志

日志文件位置：
- 开发环境：`logs\baseu-dev.log`
- 生产环境：`logs\baseu.log`

实时查看日志：
```batch
# PowerShell
Get-Content logs\baseu-dev.log -Wait -Tail 50

# 或使用工具
notepad++ logs\baseu-dev.log
```

### 3. 调试端口

添加调试端口启动：
```batch
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar target\baseu-server-1.0.0.jar
```

然后在IDE中连接远程调试（端口5005）。

## 📦 打包部署

### Windows 服务器部署

```batch
# 1. 打包
mvn clean package -DskipTests

# 2. 上传JAR到服务器
# target\baseu-server-1.0.0.jar

# 3. 配置环境变量
set DB_HOST=your-db-host
set DB_PASSWORD=your-password
set REDIS_HOST=your-redis-host
set JWT_SECRET=your-secret

# 4. 运行
java -jar baseu-server-1.0.0.jar --spring.profiles.active=prod
```

### 后台运行（Windows Service）

使用 NSSM 创建Windows服务：
```batch
# 下载 NSSM: https://nssm.cc/download

# 安装服务
nssm install BaseUServer "C:\Program Files\Java\jdk-17\bin\java.exe" "-jar C:\app\baseu-server-1.0.0.jar --spring.profiles.active=prod"

# 启动服务
nssm start BaseUServer
```

## 🔍 测试接口

### 使用 curl（需要安装Git）

```batch
# 1. 发送验证码
curl -X POST http://localhost:8080/api/auth/send-code ^
  -H "Content-Type: application/json" ^
  -d "{\"target\":\"test@example.com\",\"type\":1}"

# 2. 用户注册
curl -X POST http://localhost:8080/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"Test1234\",\"verificationCode\":\"123456\"}"
```

### 使用 Postman

1. 访问 Swagger：http://localhost:8080/swagger-ui.html
2. 测试各个接口

## 📞 技术支持

- **Swagger文档**：http://localhost:8080/swagger-ui.html
- **开发文档**：`SERVER_DEVELOPMENT_GUIDE.md`
- **快速启动**：`QUICKSTART.md`

---

**祝你开发愉快！** 🎉

