# 更新日志

## v1.1.0 (2024-01-01) - Windows优化版

### 🎉 新功能

#### 1. 数据库自动创建
- ✅ 启动时自动检测数据库是否存在
- ✅ 不存在则自动创建数据库
- ✅ 自动执行Flyway迁移脚本
- ✅ **无需手动执行SQL**

**实现**：`DatabaseInitializer.java`

#### 2. 环境配置优化
- ✅ 开发环境（dev）和生产环境（prod）清晰分离
- ✅ 启动时显示当前环境标识
- ✅ 显示访问地址和API文档地址
- ✅ 更友好的启动信息输出

**配置文件**：
- `application-dev.yml` - 开发环境配置
- `application-prod.yml` - 生产环境配置（支持环境变量）

#### 3. Windows专属支持

##### a. Windows启动脚本 (`start.bat`)
- ✅ 可视化菜单选择启动方式
- ✅ 支持4种启动方式：
  - Maven启动（开发推荐）
  - JAR包启动（生产推荐）
  - Docker启动
  - 生产环境启动
- ✅ 自动检测Java环境
- ✅ 自动打包（如需要）

##### b. 环境配置助手 (`env-setup.bat`)
- ✅ 交互式配置向导
- ✅ 自动生成配置文件
- ✅ 支持开发/生产环境配置
- ✅ 验证输入参数

#### 4. Windows完整指南
- ✅ 新增 `WINDOWS_GUIDE.md`
- ✅ 详细的Windows系统使用说明
- ✅ 常见问题解决方案
- ✅ 开发技巧和部署指南

### 📝 文档更新

#### 更新的文档
- ✅ `QUICKSTART.md` - 突出数据库自动创建和Windows支持
- ✅ `README.md` - 添加环境配置说明
- ✅ `WINDOWS_GUIDE.md` - 全新的Windows系统指南

#### 新增的文档
- ✅ `UPDATE_LOG.md` - 更新日志
- ✅ `PROJECT_SUMMARY.md` - 项目总结

### 🔧 技术改进

#### 启动信息优化
**之前**：
```
====================================
   BaseU Server Started Successfully
====================================
```

**现在**：
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

#### 配置增强
- ✅ 生产环境支持更多环境变量
- ✅ 开发环境标识清晰
- ✅ 日志配置优化

### 🐛 修复

- 修复生产环境数据库URL SSL配置
- 优化Flyway配置

### 📊 影响范围

#### 新增文件
- `src/main/java/com/zero/baseu/config/DatabaseInitializer.java`
- `start.bat`
- `env-setup.bat`
- `WINDOWS_GUIDE.md`
- `UPDATE_LOG.md`

#### 修改文件
- `src/main/java/com/zero/baseu/BaseUApplication.java`
- `src/main/resources/application-dev.yml`
- `src/main/resources/application-prod.yml`
- `QUICKSTART.md`
- `README.md`

### 🚀 使用建议

#### Windows用户
1. 使用 `env-setup.bat` 快速配置环境
2. 使用 `start.bat` 启动项目
3. 查看 `WINDOWS_GUIDE.md` 了解详细功能

#### Linux/Mac用户
1. 手动编辑 `application-dev.yml`
2. 使用 `start.sh` 或 Maven命令启动
3. 数据库仍会自动创建

### 💡 升级注意事项

#### 从旧版本升级

如果您已经手动创建了数据库，不会有任何影响：
- ✅ 数据库初始化器会检测到数据库已存在
- ✅ 跳过创建步骤
- ✅ Flyway正常执行迁移

#### 新项目

直接启动即可：
1. 配置数据库连接（用户名/密码）
2. 启动项目
3. 数据库自动创建并初始化

---

## v1.0.0 (2024-01-01) - 初始版本

### 功能
- ✅ 用户认证（注册、登录、Token刷新）
- ✅ 用户管理（信息查询、密码修改）
- ✅ 充值功能（订单创建、记录查询）
- ✅ 交易功能（记录查询）
- ✅ JWT安全认证
- ✅ Flyway数据库迁移
- ✅ Swagger API文档

### 技术栈
- Java 17
- Spring Boot 3.2.0
- MySQL 8.0+
- Redis 7.0+
- MyBatis Plus 3.5.4

---

**版本**: 1.1.0  
**发布日期**: 2024-01-01  
**重要程度**: ⭐⭐⭐⭐⭐ (强烈推荐升级)

