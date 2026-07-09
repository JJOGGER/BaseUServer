@echo off
chcp 65001 >nul
echo ======================================
echo    BaseU Server 环境配置助手
echo ======================================
echo.

echo 请选择环境:
echo 1) 开发环境 (dev)
echo 2) 生产环境 (prod)
echo.
set /p env_choice="请输入选项 (1-2): "

if "%env_choice%"=="1" goto setup_dev
if "%env_choice%"=="2" goto setup_prod
echo ❌ 无效的选项
pause
exit /b 1

:setup_dev
echo.
echo ========== 配置开发环境 ==========
echo.

REM 设置默认值
set DB_HOST=localhost
set DB_PORT=3306
set DB_NAME=baseu
set DB_USERNAME=root
set REDIS_HOST=localhost
set REDIS_PORT=6379

REM 获取用户输入
set /p DB_HOST="MySQL地址 [%DB_HOST%]: " || set DB_HOST=localhost
set /p DB_PORT="MySQL端口 [%DB_PORT%]: " || set DB_PORT=3306
set /p DB_NAME="数据库名 [%DB_NAME%]: " || set DB_NAME=baseu
set /p DB_USERNAME="数据库用户名 [%DB_USERNAME%]: " || set DB_USERNAME=root
set /p DB_PASSWORD="数据库密码: "
echo.
set /p REDIS_HOST="Redis地址 [%REDIS_HOST%]: " || set REDIS_HOST=localhost
set /p REDIS_PORT="Redis端口 [%REDIS_PORT%]: " || set REDIS_PORT=6379
set /p REDIS_PASSWORD="Redis密码 (可选): "

REM 生成配置文件
echo.
echo 正在生成 application-dev.yml ...
(
echo server:
echo   port: 8080
echo.
echo spring:
echo   # 数据源配置
echo   datasource:
echo     url: jdbc:mysql://%DB_HOST%:%DB_PORT%/%DB_NAME%?useUnicode=true^&characterEncoding=utf8^&serverTimezone=Asia/Shanghai^&useSSL=false^&allowPublicKeyRetrieval=true
echo     username: %DB_USERNAME%
echo     password: %DB_PASSWORD%
echo.
echo   # Redis配置
echo   data:
echo     redis:
echo       host: %REDIS_HOST%
echo       port: %REDIS_PORT%
if not "%REDIS_PASSWORD%"=="" echo       password: %REDIS_PASSWORD%
echo.
echo # JWT配置
echo jwt:
echo   secret: dev-secret-key-for-development-environment-change-in-production-aB3dEf9hIjKl2nOpQr5tUvWxYz
echo.
echo # 日志配置
echo logging:
echo   level:
echo     com.zero.baseu: DEBUG
echo   file:
echo     name: logs/baseu-dev.log
) > src\main\resources\application-dev.yml

echo ✅ 开发环境配置完成！
echo.
echo 配置已保存到: src\main\resources\application-dev.yml
echo.
echo 下一步: 运行 start.bat 启动项目
goto end

:setup_prod
echo.
echo ========== 配置生产环境 ==========
echo.
echo ⚠️  生产环境建议使用环境变量配置
echo.

REM 生成.env示例
echo 正在生成 .env 文件...
(
echo # MySQL配置
echo DB_HOST=your-mysql-host
echo DB_PORT=3306
echo DB_NAME=baseu
echo DB_USERNAME=baseu
echo DB_PASSWORD=your-secure-mysql-password
echo.
echo # Redis配置
echo REDIS_HOST=your-redis-host
echo REDIS_PORT=6379
echo REDIS_PASSWORD=your-secure-redis-password
echo.
echo # JWT配置 ^(请生成一个强密钥^)
echo JWT_SECRET=your-256-bit-secret-key-change-this-to-random-string-in-production
) > .env

echo ✅ 已生成 .env 文件模板
echo.
echo 请编辑 .env 文件，填写正确的生产环境配置
notepad .env
echo.
echo 配置完成后:
echo 1. 本地部署: 运行 start.bat 选择选项4
echo 2. Docker部署: 运行 docker-compose up -d
goto end

:end
echo.
pause

