@echo off
chcp 65001 >nul
echo ======================================
echo    BaseU Server 启动脚本 (Windows)
echo ======================================
echo.

REM 检查Java版本
echo 检查Java版本...
java -version
if errorlevel 1 (
    echo ❌ 未检测到Java，请先安装JDK 17+
    pause
    exit /b 1
)

REM 自动设置JAVA_HOME / MAVEN_HOME
set JAVA_HOME=C:\Program Files\Amazon Corretto\jdk17.0.19_10
set MAVEN_HOME=C:\Program Files\Apache Maven Foundation\apache-maven-3.9.6
echo 设置JAVA_HOME: %JAVA_HOME%
echo 设置MAVEN_HOME: %MAVEN_HOME%
set PATH=%JAVA_HOME%\bin;%MAVEN_HOME%\bin;%PATH%
echo.

REM 设置环境变量（默认为dev）
if "%SPRING_PROFILES_ACTIVE%"=="" (
    set SPRING_PROFILES_ACTIVE=dev
)

echo 当前环境: %SPRING_PROFILES_ACTIVE%
echo.

REM 无参数时默认 Maven 编译并运行；也可传 1/2/3/4
if "%~1"=="" (
    set choice=1
) else (
    set choice=%~1
)

if "%choice%"=="1" goto maven_start
if "%choice%"=="2" goto jar_start
if "%choice%"=="3" goto docker_start
if "%choice%"=="4" goto prod_start

echo 请选择启动方式:
echo 1) Maven 编译并启动 (开发环境推荐)
echo 2) JAR 包启动 (生产环境推荐)
echo 3) Docker 启动
echo 4) 切换到生产环境启动
echo.
set /p choice="请输入选项 (1-4): "

if "%choice%"=="1" goto maven_start
if "%choice%"=="2" goto jar_start
if "%choice%"=="3" goto docker_start
if "%choice%"=="4" goto prod_start
echo ❌ 无效的选项
pause
exit /b 1

:maven_start
echo.
echo [1/2] Maven 编译...
call mvn clean compile -DskipTests
if errorlevel 1 (
    echo ❌ 编译失败
    pause
    exit /b 1
)
echo.
echo [2/2] Maven 启动 (环境: %SPRING_PROFILES_ACTIVE%)...
echo.
call mvn spring-boot:run "-Dspring-boot.run.profiles=%SPRING_PROFILES_ACTIVE%"
goto end

:jar_start
echo.
echo 使用JAR包启动 (环境: %SPRING_PROFILES_ACTIVE%)...
if not exist "target\baseu-server-1.0.0.jar" (
    echo JAR文件不存在，开始打包...
    call mvn clean package -DskipTests
    if errorlevel 1 (
        echo ❌ 打包失败
        pause
        exit /b 1
    )
)
echo.
java -jar target\baseu-server-1.0.0.jar --spring.profiles.active=%SPRING_PROFILES_ACTIVE%
goto end

:docker_start
echo.
echo 使用Docker启动...
if not exist ".env" (
    echo 创建.env文件...
    copy .env.example .env
    echo ⚠️  请先编辑.env文件配置环境变量
    notepad .env
)
echo.
docker-compose up -d
if errorlevel 1 (
    echo ❌ Docker启动失败，请确保Docker已安装并运行
    pause
    exit /b 1
)
echo.
echo ✅ Docker容器启动成功
echo 查看日志请运行: docker-compose logs -f app
goto end

:prod_start
echo.
echo 切换到生产环境...
set SPRING_PROFILES_ACTIVE=prod
echo.
echo ⚠️  生产环境需要配置以下环境变量:
echo    - DB_HOST (数据库地址)
echo    - DB_PASSWORD (数据库密码)
echo    - REDIS_HOST (Redis地址)
echo    - JWT_SECRET (JWT密钥)
echo.
set /p confirm="是否继续? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo 已取消
    pause
    exit /b 0
)
echo.
echo 使用JAR包启动生产环境...
if not exist "target\baseu-server-1.0.0.jar" (
    echo JAR文件不存在，开始打包...
    call mvn clean package -DskipTests
    if errorlevel 1 (
        echo ❌ 打包失败
        pause
        exit /b 1
    )
)
java -jar target\baseu-server-1.0.0.jar --spring.profiles.active=prod
goto end

:end
pause
