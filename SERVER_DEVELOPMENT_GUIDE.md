# BaseU 服务端开发文档

## 目录
- [1. 项目概述](#1-项目概述)
- [2. 技术栈](#2-技术栈)
- [3. 项目结构](#3-项目结构)
- [4. 数据库设计](#4-数据库设计)
- [5. API接口设计](#5-api接口设计)
- [6. 安全性设计](#6-安全性设计)
- [7. 数据库迁移](#7-数据库迁移)
- [8. 部署说明](#8-部署说明)

---

## 1. 项目概述

BaseU 是一个数字资产管理平台，提供用户注册、登录、充值、转账等核心功能。

### 1.1 核心功能模块
- **用户认证模块**：注册、登录、登出、密码找回
- **账户管理模块**：用户信息管理、安全设置
- **充值模块**：充值申请、充值记录、充值审核
- **交易模块**：转账、交易记录查询
- **验证码模块**：短信验证码、邮箱验证码

---

## 2. 技术栈

### 2.1 后端框架
```xml
<!-- Spring Boot 3.x -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
    <version>3.2.0</version>
</dependency>

<!-- Spring Security + JWT -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.11.5</version>
</dependency>

<!-- MySQL + MyBatis Plus -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.5.4</version>
</dependency>

<!-- Redis 缓存 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- Flyway 数据库迁移 -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
    <version>9.22.0</version>
</dependency>
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-mysql</artifactId>
    <version>9.22.0</version>
</dependency>

<!-- 验证码服务 -->
<dependency>
    <groupId>com.aliyun</groupId>
    <artifactId>dysmsapi20170525</artifactId>
    <version>2.0.24</version>
</dependency>

<!-- 工具类 -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.30</version>
</dependency>
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.8.23</version>
</dependency>
```

### 2.2 数据库
- **MySQL 8.0+**：主数据库
- **Redis 7.0+**：缓存、Session存储

---

## 3. 项目结构

```
baseu-server/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── zero/
│   │   │           └── baseu/
│   │   │               ├── BaseUApplication.java
│   │   │               ├── config/                    # 配置类
│   │   │               │   ├── SecurityConfig.java
│   │   │               │   ├── RedisConfig.java
│   │   │               │   ├── SwaggerConfig.java
│   │   │               │   └── WebMvcConfig.java
│   │   │               ├── controller/                # 控制器层
│   │   │               │   ├── AuthController.java
│   │   │               │   ├── UserController.java
│   │   │               │   ├── RechargeController.java
│   │   │               │   └── TransactionController.java
│   │   │               ├── service/                   # 服务层
│   │   │               │   ├── IUserService.java
│   │   │               │   ├── IAuthService.java
│   │   │               │   ├── IRechargeService.java
│   │   │               │   ├── ITransactionService.java
│   │   │               │   ├── ISmsService.java
│   │   │               │   └── impl/
│   │   │               │       ├── UserServiceImpl.java
│   │   │               │       ├── AuthServiceImpl.java
│   │   │               │       ├── RechargeServiceImpl.java
│   │   │               │       ├── TransactionServiceImpl.java
│   │   │               │       └── SmsServiceImpl.java
│   │   │               ├── mapper/                    # 数据访问层
│   │   │               │   ├── UserMapper.java
│   │   │               │   ├── RechargeMapper.java
│   │   │               │   └── TransactionMapper.java
│   │   │               ├── entity/                    # 实体类
│   │   │               │   ├── User.java
│   │   │               │   ├── Recharge.java
│   │   │               │   ├── Transaction.java
│   │   │               │   └── UserAccount.java
│   │   │               ├── dto/                       # 数据传输对象
│   │   │               │   ├── request/
│   │   │               │   │   ├── LoginRequest.java
│   │   │               │   │   ├── RegisterRequest.java
│   │   │               │   │   ├── RechargeRequest.java
│   │   │               │   │   └── SendCodeRequest.java
│   │   │               │   └── response/
│   │   │               │       ├── LoginResponse.java
│   │   │               │       ├── UserInfoResponse.java
│   │   │               │       └── RechargeResponse.java
│   │   │               ├── security/                  # 安全相关
│   │   │               │   ├── JwtTokenProvider.java
│   │   │               │   ├── JwtAuthenticationFilter.java
│   │   │               │   └── UserDetailsServiceImpl.java
│   │   │               ├── common/                    # 公共类
│   │   │               │   ├── Result.java           # 统一响应
│   │   │               │   ├── ResultCode.java       # 响应码
│   │   │               │   ├── BusinessException.java
│   │   │               │   └── GlobalExceptionHandler.java
│   │   │               └── util/                      # 工具类
│   │   │                   ├── PasswordUtil.java
│   │   │                   ├── ValidationUtil.java
│   │   │                   └── RedisUtil.java
│   │   └── resources/
│   │       ├── application.yml                        # 主配置
│   │       ├── application-dev.yml                    # 开发环境
│   │       ├── application-prod.yml                   # 生产环境
│   │       ├── mapper/                                # MyBatis XML
│   │       │   ├── UserMapper.xml
│   │       │   ├── RechargeMapper.xml
│   │       │   └── TransactionMapper.xml
│   │       └── db/
│   │           └── migration/                         # Flyway迁移脚本
│   │               ├── V1__init_database.sql
│   │               ├── V2__add_user_country.sql
│   │               └── V3__add_recharge_table.sql
│   └── test/
│       └── java/
│           └── com/
│               └── zero/
│                   └── baseu/
│                       ├── service/
│                       └── controller/
└── pom.xml
```

---

## 4. 数据库设计

### 4.1 用户表 (tb_user)
```sql
CREATE TABLE `tb_user` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希',
  `salt` VARCHAR(64) NOT NULL COMMENT '密码盐值',
  `country_code` VARCHAR(10) DEFAULT 'CN' COMMENT '国家代码',
  `dial_code` VARCHAR(10) DEFAULT '+86' COMMENT '区号',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_username` (`username`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';
```

### 4.2 用户账户表 (tb_user_account)
```sql
CREATE TABLE `tb_user_account` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账户ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `balance` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '账户余额',
  `frozen_amount` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '冻结金额',
  `total_recharge` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '累计充值',
  `total_withdraw` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '累计提现',
  `version` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  KEY `idx_balance` (`balance`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户账户表';
```

### 4.3 充值记录表 (tb_recharge)
```sql
CREATE TABLE `tb_recharge` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '充值ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '充值订单号',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `amount` DECIMAL(20, 2) NOT NULL COMMENT '充值金额',
  `currency` VARCHAR(10) NOT NULL DEFAULT 'CNY' COMMENT '货币类型',
  `payment_method` VARCHAR(20) NOT NULL COMMENT '支付方式：ALIPAY/WECHAT/BANK',
  `payment_channel` VARCHAR(50) DEFAULT NULL COMMENT '支付渠道',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待支付，1-支付中，2-成功，3-失败，4-已取消',
  `transaction_id` VARCHAR(100) DEFAULT NULL COMMENT '第三方交易ID',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值记录表';
```

### 4.4 交易记录表 (tb_transaction)
```sql
CREATE TABLE `tb_transaction` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '交易ID',
  `transaction_no` VARCHAR(64) NOT NULL COMMENT '交易流水号',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `type` TINYINT NOT NULL COMMENT '交易类型：1-充值，2-提现，3-转账，4-收款',
  `amount` DECIMAL(20, 2) NOT NULL COMMENT '交易金额',
  `balance_before` DECIMAL(20, 2) NOT NULL COMMENT '交易前余额',
  `balance_after` DECIMAL(20, 2) NOT NULL COMMENT '交易后余额',
  `related_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '关联ID（充值/提现/转账记录ID）',
  `related_user_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '关联用户ID（转账对方）',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_transaction_no` (`transaction_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交易记录表';
```

### 4.5 验证码记录表 (tb_verification_code)
```sql
CREATE TABLE `tb_verification_code` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `target` VARCHAR(100) NOT NULL COMMENT '目标（手机号/邮箱）',
  `code` VARCHAR(10) NOT NULL COMMENT '验证码',
  `type` TINYINT NOT NULL COMMENT '类型：1-注册，2-登录，3-重置密码',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间',
  `used` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已使用：0-未使用，1-已使用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_target_type` (`target`, `type`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='验证码记录表';
```

---

## 5. API接口设计

### 5.1 统一响应格式
```java
@Data
public class Result<T> {
    private Integer code;
    private String message;
    private T data;
    private Long timestamp;
    
    public static <T> Result<T> success(T data) {
        Result<T> result = new Result<>();
        result.setCode(200);
        result.setMessage("成功");
        result.setData(data);
        result.setTimestamp(System.currentTimeMillis());
        return result;
    }
    
    public static <T> Result<T> error(Integer code, String message) {
        Result<T> result = new Result<>();
        result.setCode(code);
        result.setMessage(message);
        result.setTimestamp(System.currentTimeMillis());
        return result;
    }
}
```

### 5.2 认证相关接口

#### 5.2.1 发送验证码
```
POST /api/auth/send-code
Content-Type: application/json

Request:
{
  "target": "user@example.com",  // 手机号或邮箱
  "type": 1,                     // 1-注册，2-登录，3-重置密码
  "countryCode": "CN"            // 国家代码（手机号时需要）
}

Response:
{
  "code": 200,
  "message": "验证码已发送",
  "data": {
    "expireIn": 300  // 过期时间（秒）
  },
  "timestamp": 1699000000000
}
```

#### 5.2.2 用户注册
```
POST /api/auth/register
Content-Type: application/json

Request:
{
  "email": "user@example.com",
  "phone": "13800138000",
  "password": "Password123!",
  "verificationCode": "123456",
  "countryCode": "CN",
  "dialCode": "+86"
}

Response:
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "userId": 10001,
    "email": "user@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "timestamp": 1699000000000
}
```

#### 5.2.3 用户登录
```
POST /api/auth/login
Content-Type: application/json

Request:
{
  "account": "user@example.com",  // 邮箱或手机号
  "password": "Password123!"
}

Response:
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "userId": 10001,
    "username": "用户名",
    "email": "user@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200
  },
  "timestamp": 1699000000000
}
```

#### 5.2.4 刷新Token
```
POST /api/auth/refresh-token
Content-Type: application/json
Authorization: Bearer {refreshToken}

Response:
{
  "code": 200,
  "message": "刷新成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 7200
  },
  "timestamp": 1699000000000
}
```

### 5.3 用户相关接口

#### 5.3.1 获取用户信息
```
GET /api/user/info
Authorization: Bearer {token}

Response:
{
  "code": 200,
  "message": "成功",
  "data": {
    "userId": 10001,
    "username": "用户名",
    "email": "user@example.com",
    "phone": "13800138000",
    "countryCode": "CN",
    "dialCode": "+86",
    "balance": "1000.00",
    "createTime": "2024-01-01 12:00:00"
  },
  "timestamp": 1699000000000
}
```

#### 5.3.2 修改密码
```
PUT /api/user/password
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "oldPassword": "OldPassword123!",
  "newPassword": "NewPassword123!"
}

Response:
{
  "code": 200,
  "message": "密码修改成功",
  "timestamp": 1699000000000
}
```

### 5.4 充值相关接口

#### 5.4.1 创建充值订单
```
POST /api/recharge/create
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "amount": "100.00",
  "paymentMethod": "ALIPAY"  // ALIPAY/WECHAT/BANK
}

Response:
{
  "code": 200,
  "message": "订单创建成功",
  "data": {
    "orderNo": "RC202401010001",
    "amount": "100.00",
    "paymentUrl": "https://payment.example.com/...",
    "qrCode": "data:image/png;base64,..."
  },
  "timestamp": 1699000000000
}
```

#### 5.4.2 查询充值记录
```
GET /api/recharge/list?page=1&size=10&status=2
Authorization: Bearer {token}

Response:
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 50,
    "list": [
      {
        "orderNo": "RC202401010001",
        "amount": "100.00",
        "status": 2,  // 0-待支付，1-支付中，2-成功，3-失败
        "statusText": "成功",
        "paymentMethod": "ALIPAY",
        "createTime": "2024-01-01 12:00:00",
        "payTime": "2024-01-01 12:05:00"
      }
    ]
  },
  "timestamp": 1699000000000
}
```

#### 5.4.3 充值回调（支付平台调用）
```
POST /api/recharge/callback/{channel}
Content-Type: application/json

Request: (支付平台格式)

Response: (返回给支付平台)
```

### 5.5 交易相关接口

#### 5.5.1 查询交易记录
```
GET /api/transaction/list?page=1&size=10&type=1
Authorization: Bearer {token}

Response:
{
  "code": 200,
  "message": "成功",
  "data": {
    "total": 100,
    "list": [
      {
        "transactionNo": "TX202401010001",
        "type": 1,  // 1-充值，2-提现，3-转账，4-收款
        "typeText": "充值",
        "amount": "100.00",
        "balanceBefore": "900.00",
        "balanceAfter": "1000.00",
        "remark": "充值",
        "createTime": "2024-01-01 12:00:00"
      }
    ]
  },
  "timestamp": 1699000000000
}
```

---

## 6. 安全性设计

### 6.1 密码安全
```java
@Service
public class PasswordUtil {
    
    /**
     * 生成密码哈希（使用BCrypt）
     */
    public String hashPassword(String password, String salt) {
        return BCrypt.hashpw(password + salt, BCrypt.gensalt(12));
    }
    
    /**
     * 验证密码
     */
    public boolean verifyPassword(String password, String salt, String hash) {
        return BCrypt.checkpw(password + salt, hash);
    }
    
    /**
     * 生成随机盐值
     */
    public String generateSalt() {
        return UUID.randomUUID().toString().replace("-", "");
    }
    
    /**
     * 密码强度校验
     */
    public boolean validatePasswordStrength(String password) {
        // 至少8位，包含大小写字母、数字
        String regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$";
        return password.matches(regex);
    }
}
```

### 6.2 JWT Token配置
```java
@Component
public class JwtTokenProvider {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private Long jwtExpiration;  // 2小时
    
    @Value("${jwt.refresh-expiration}")
    private Long refreshExpiration;  // 7天
    
    /**
     * 生成访问Token
     */
    public String generateToken(Long userId, String email) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);
        
        return Jwts.builder()
                .setSubject(userId.toString())
                .claim("email", email)
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }
    
    /**
     * 生成刷新Token
     */
    public String generateRefreshToken(Long userId) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + refreshExpiration);
        
        return Jwts.builder()
                .setSubject(userId.toString())
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(SignatureAlgorithm.HS512, jwtSecret)
                .compact();
    }
}
```

### 6.3 接口限流（Redis + 注解）
```java
@Aspect
@Component
public class RateLimitAspect {
    
    @Autowired
    private RedisTemplate<String, Integer> redisTemplate;
    
    @Around("@annotation(rateLimit)")
    public Object around(ProceedingJoinPoint point, RateLimit rateLimit) throws Throwable {
        String key = getRateLimitKey(point);
        Integer count = redisTemplate.opsForValue().get(key);
        
        if (count == null) {
            redisTemplate.opsForValue().set(key, 1, rateLimit.time(), TimeUnit.SECONDS);
        } else if (count < rateLimit.count()) {
            redisTemplate.opsForValue().increment(key);
        } else {
            throw new BusinessException(429, "请求过于频繁，请稍后再试");
        }
        
        return point.proceed();
    }
}

// 使用示例
@RateLimit(count = 5, time = 60)  // 60秒内最多5次
@PostMapping("/send-code")
public Result<Void> sendCode(@RequestBody SendCodeRequest request) {
    // ...
}
```

### 6.4 敏感信息加密
```java
@Configuration
public class EncryptConfig {
    
    /**
     * 手机号脱敏
     */
    public String maskPhone(String phone) {
        if (phone == null || phone.length() < 11) {
            return phone;
        }
        return phone.substring(0, 3) + "****" + phone.substring(7);
    }
    
    /**
     * 邮箱脱敏
     */
    public String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return email;
        }
        String[] parts = email.split("@");
        String username = parts[0];
        if (username.length() <= 2) {
            return "**@" + parts[1];
        }
        return username.substring(0, 2) + "***@" + parts[1];
    }
}
```

---

## 7. 数据库迁移

### 7.1 Flyway配置
```yaml
# application.yml
spring:
  flyway:
    enabled: true
    baseline-on-migrate: true
    locations: classpath:db/migration
    encoding: UTF-8
    validate-on-migrate: true
```

### 7.2 迁移脚本命名规范
```
V{版本号}__{描述}.sql

示例：
V1__init_database.sql           # 初始化数据库
V2__add_user_country.sql        # 添加用户国家字段
V3__add_recharge_table.sql      # 添加充值表
V4__add_transaction_index.sql  # 添加交易索引
```

### 7.3 V1__init_database.sql
```sql
-- =============================================
-- BaseU 数据库初始化脚本
-- Version: 1.0.0
-- Date: 2024-01-01
-- =============================================

-- 用户表
CREATE TABLE `tb_user` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `email` VARCHAR(100) NOT NULL COMMENT '邮箱',
  `phone` VARCHAR(20) DEFAULT NULL COMMENT '手机号',
  `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希',
  `salt` VARCHAR(64) NOT NULL COMMENT '密码盐值',
  `status` TINYINT DEFAULT 1 COMMENT '状态：0-禁用，1-正常',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 用户账户表
CREATE TABLE `tb_user_account` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账户ID',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `balance` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '账户余额',
  `frozen_amount` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '冻结金额',
  `total_recharge` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '累计充值',
  `total_withdraw` DECIMAL(20, 2) NOT NULL DEFAULT 0.00 COMMENT '累计提现',
  `version` INT NOT NULL DEFAULT 0 COMMENT '乐观锁版本号',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户账户表';

-- 验证码记录表
CREATE TABLE `tb_verification_code` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `target` VARCHAR(100) NOT NULL COMMENT '目标（手机号/邮箱）',
  `code` VARCHAR(10) NOT NULL COMMENT '验证码',
  `type` TINYINT NOT NULL COMMENT '类型：1-注册，2-登录，3-重置密码',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间',
  `used` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已使用：0-未使用，1-已使用',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_target_type` (`target`, `type`),
  KEY `idx_expire_time` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='验证码记录表';
```

### 7.4 V2__add_user_country.sql
```sql
-- =============================================
-- 添加用户国家地区字段
-- Version: 1.1.0
-- Date: 2024-01-02
-- =============================================

ALTER TABLE `tb_user` 
ADD COLUMN `country_code` VARCHAR(10) DEFAULT 'CN' COMMENT '国家代码' AFTER `salt`,
ADD COLUMN `dial_code` VARCHAR(10) DEFAULT '+86' COMMENT '区号' AFTER `country_code`;

-- 为现有用户设置默认值
UPDATE `tb_user` SET `country_code` = 'CN', `dial_code` = '+86' WHERE `country_code` IS NULL;
```

### 7.5 V3__add_recharge_table.sql
```sql
-- =============================================
-- 添加充值和交易相关表
-- Version: 1.2.0
-- Date: 2024-01-03
-- =============================================

-- 充值记录表
CREATE TABLE `tb_recharge` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '充值ID',
  `order_no` VARCHAR(64) NOT NULL COMMENT '充值订单号',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `amount` DECIMAL(20, 2) NOT NULL COMMENT '充值金额',
  `currency` VARCHAR(10) NOT NULL DEFAULT 'CNY' COMMENT '货币类型',
  `payment_method` VARCHAR(20) NOT NULL COMMENT '支付方式：ALIPAY/WECHAT/BANK',
  `payment_channel` VARCHAR(50) DEFAULT NULL COMMENT '支付渠道',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态：0-待支付，1-支付中，2-成功，3-失败，4-已取消',
  `transaction_id` VARCHAR(100) DEFAULT NULL COMMENT '第三方交易ID',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `pay_time` DATETIME DEFAULT NULL COMMENT '支付时间',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_no` (`order_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='充值记录表';

-- 交易记录表
CREATE TABLE `tb_transaction` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '交易ID',
  `transaction_no` VARCHAR(64) NOT NULL COMMENT '交易流水号',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `type` TINYINT NOT NULL COMMENT '交易类型：1-充值，2-提现，3-转账，4-收款',
  `amount` DECIMAL(20, 2) NOT NULL COMMENT '交易金额',
  `balance_before` DECIMAL(20, 2) NOT NULL COMMENT '交易前余额',
  `balance_after` DECIMAL(20, 2) NOT NULL COMMENT '交易后余额',
  `related_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '关联ID（充值/提现/转账记录ID）',
  `related_user_id` BIGINT UNSIGNED DEFAULT NULL COMMENT '关联用户ID（转账对方）',
  `remark` VARCHAR(255) DEFAULT NULL COMMENT '备注',
  `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_transaction_no` (`transaction_no`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='交易记录表';
```

### 7.6 数据库迁移命令
```bash
# 查看迁移状态
mvn flyway:info

# 执行迁移
mvn flyway:migrate

# 验证迁移
mvn flyway:validate

# 清理数据库（慎用！）
mvn flyway:clean
```

---

## 8. 部署说明

### 8.1 环境要求
- JDK 17+
- MySQL 8.0+
- Redis 7.0+
- Maven 3.8+

### 8.2 配置文件（application-prod.yml）
```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/baseu?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    driver-class-name: com.mysql.cj.jdbc.Driver
    hikari:
      maximum-pool-size: 20
      minimum-idle: 5
      connection-timeout: 30000
      
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    database: 0
    
jwt:
  secret: ${JWT_SECRET}
  expiration: 7200000      # 2小时
  refresh-expiration: 604800000  # 7天
  
# 日志配置
logging:
  level:
    com.zero.baseu: INFO
  file:
    name: logs/baseu.log
```

### 8.3 Docker部署
```dockerfile
# Dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/baseu-server-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=prod", "app.jar"]
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: baseu
    ports:
      - "3306:3306"
    volumes:
      - mysql-data:/var/lib/mysql
      
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
      
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_USERNAME: root
      DB_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      REDIS_HOST: redis
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - mysql
      - redis

volumes:
  mysql-data:
  redis-data:
```

### 8.4 启动命令
```bash
# 开发环境
mvn spring-boot:run -Dspring.profiles.active=dev

# 生产环境打包
mvn clean package -DskipTests

# 运行
java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=prod

# Docker部署
docker-compose up -d
```

---

## 附录

### A. 错误码定义
```java
public enum ResultCode {
    SUCCESS(200, "成功"),
    BAD_REQUEST(400, "请求参数错误"),
    UNAUTHORIZED(401, "未授权"),
    FORBIDDEN(403, "无权限"),
    NOT_FOUND(404, "资源不存在"),
    TOO_MANY_REQUESTS(429, "请求过于频繁"),
    INTERNAL_ERROR(500, "服务器内部错误"),
    
    // 业务错误码 1000+
    USER_NOT_FOUND(1001, "用户不存在"),
    USER_ALREADY_EXISTS(1002, "用户已存在"),
    INVALID_PASSWORD(1003, "密码错误"),
    INVALID_CODE(1004, "验证码错误或已过期"),
    INSUFFICIENT_BALANCE(1005, "余额不足"),
    RECHARGE_ORDER_NOT_FOUND(1006, "充值订单不存在");
}
```

### B. API测试示例（Postman）
详见项目根目录下的 `BaseU.postman_collection.json`

---

**文档版本**: 1.0.0  
**最后更新**: 2024-01-01  
**维护者**: Zero Team

