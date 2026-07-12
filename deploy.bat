@echo off
REM BaseU 一键部署脚本 (Windows版本)
REM 功能：自动检查环境、处理冲突、部署应用

setlocal enabledelayedexpansion

set "GREEN=[INFO]"
set "YELLOW=[WARN]"
set "RED=[ERROR]"
set "BLUE=[STEP]"

echo ========================================
echo    BaseU 一键部署脚本
echo ========================================

REM 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo %RED% 请以管理员身份运行此脚本
    pause
    exit /b 1
)

REM 设置项目路径
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

REM 检查Java
:check_java
echo %BLUE% 检查Java环境...
java -version >nul 2>&1
if %errorLevel% neq 0 (
    echo %YELLOW% Java未安装，正在下载安装...
    call :install_java
) else (
    for /f "tokens=3" %%a in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        set "JAVA_VER=%%a"
    )
    echo %GREEN% Java已安装，版本：!JAVA_VER!
)

REM 检查Maven
:check_maven
echo %BLUE% 检查Maven环境...
mvn -version >nul 2>&1
if %errorLevel% neq 0 (
    echo %YELLOW% Maven未安装，正在下载安装...
    call :install_maven
) else (
    for /f "tokens=3" %%a in ('mvn -version ^| findstr "Apache Maven"') do (
        set "MVN_VER=%%a"
    )
    echo %GREEN% Maven已安装，版本：!MVN_VER!
)

REM 检查Node.js
:check_node
echo %BLUE% 检查Node.js环境...
node -v >nul 2>&1
if %errorLevel% neq 0 (
    echo %YELLOW% Node.js未安装，正在下载安装...
    call :install_node
) else (
    for /f %%a in ('node -v') do (
        set "NODE_VER=%%a"
    )
    echo %GREEN% Node.js已安装，版本：!NODE_VER!
)

REM 检查Git
:check_git
echo %BLUE% 检查Git环境...
git --version >nul 2>&1
if %errorLevel% neq 0 (
    echo %YELLOW% Git未安装，正在下载安装...
    call :install_git
) else (
    for /f "tokens=3" %%a in ('git --version') do (
        set "GIT_VER=%%a"
    )
    echo %GREEN% Git已安装，版本：!GIT_VER!
)

REM 创建备份
:create_backup
echo %BLUE% 创建备份...
set "BACKUP_DIR=%PROJECT_DIR%backups"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
set "TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"

if exist "%PROJECT_DIR%target\baseu-server-1.0.0.jar" (
    copy "%PROJECT_DIR%target\baseu-server-1.0.0.jar" "%BACKUP_DIR%\baseu-server-%TIMESTAMP%.jar" >nul
    echo %GREEN% JAR文件已备份
)

if exist "%PROJECT_DIR%baseu-admin\dist" (
    xcopy "%PROJECT_DIR%baseu-admin\dist" "%BACKUP_DIR%\frontend-%TIMESTAMP%\" /E /I /Y >nul
    echo %GREEN% 前端文件已备份
)

REM 拉取代码
:pull_code
echo %BLUE% 拉取最新代码...
cd /d "%PROJECT_DIR%"

REM 检查是否有未提交的修改
git status --porcelain >nul 2>&1
if %errorLevel% equ 0 (
    for /f %%a in ('git status --porcelain') do (
        if not "%%a"=="" (
            echo %YELLOW% 检测到未提交的修改，正在暂存...
            git stash push -m "部署前自动保存"
            goto :pull_continue
        )
    )
)

:pull_continue
git fetch origin
set "LOCAL_COMMIT="
set "REMOTE_COMMIT="
for /f %%a in ('git rev-parse @') do set "LOCAL_COMMIT=%%a"
for /f %%a in ('git rev-parse @{u}') do set "REMOTE_COMMIT=%%a"

if "%LOCAL_COMMIT%"=="%REMOTE_COMMIT%" (
    echo %GREEN% 代码已是最新
    goto :build_backend
)

echo %INFO% 需要拉取更新
git pull origin main
if %errorLevel% neq 0 (
    echo %YELLOW% 检测到冲突，使用远程版本覆盖本地...
    git checkout --theirs .
    git add .
    git commit -m "解决Git冲突：使用远程版本"
)

echo %GREEN% 代码拉取完成

REM 构建后端
:build_backend
echo %BLUE% 构建后端应用...
cd /d "%PROJECT_DIR%"

if not exist "pom.xml" (
    echo %RED% 未找到pom.xml文件
    pause
    exit /b 1
)

call mvn clean package -DskipTests -U
if %errorLevel% neq 0 (
    echo %RED% 后端构建失败
    call :rollback
    pause
    exit /b 1
)

if not exist "target\baseu-server-1.0.0.jar" (
    echo %RED% 构建失败，未找到jar文件
    call :rollback
    pause
    exit /b 1
)

echo %GREEN% 后端构建完成

REM 构建前端
:build_frontend
echo %BLUE% 构建前端应用...
cd /d "%PROJECT_DIR%baseu-admin"

if not exist "package.json" (
    echo %RED% 未找到package.json文件
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo %INFO% 安装前端依赖...
    call npm install
)

call npm run build
if %errorLevel% neq 0 (
    echo %RED% 前端构建失败
    call :rollback
    pause
    exit /b 1
)

if not exist "dist" (
    echo %RED% 前端构建失败
    call :rollback
    pause
    exit /b 1
)

echo %GREEN% 前端构建完成

REM 重启后端服务
:restart_backend
echo %BLUE% 重启后端服务...

REM 查找并停止旧进程
for /f "tokens=2" %%a in ('tasklist ^| findstr "java.exe"') do (
    set "OLD_PID=%%a"
)

if defined OLD_PID (
    echo %INFO% 停止旧进程
    taskkill /F /PID %OLD_PID% >nul 2>&1
    timeout /t 3 /nobreak >nul
)

REM 启动新进程
cd /d "%PROJECT_DIR%"
start /B java -jar target\baseu-server-1.0.0.jar --spring.profiles.active=prod > logs\app.log 2>&1

timeout /t 10 /nobreak >nul

echo %GREEN% 后端服务启动完成

REM 完成
:success
echo ========================================
echo    部署完成！
echo ========================================
pause
exit /b 0

REM 回滚函数
:rollback
echo %RED% 部署失败，开始回滚...

set "LATEST_JAR="
for /f %%a in ('dir /b /o-d "%BACKUP_DIR%\baseu-server-*.jar 2^>nul"') do (
    if not defined LATEST_JAR set "LATEST_JAR=%%a"
)

set "LATEST_FRONTEND="
for /f %%a in ('dir /b /o-d "%BACKUP_DIR%\frontend-* 2^>nul"') do (
    if not defined LATEST_FRONTEND set "LATEST_FRONTEND=%%a"
)

if defined LATEST_JAR (
    copy "%BACKUP_DIR%\!LATEST_JAR!" "%PROJECT_DIR%target\baseu-server-1.0.0.jar" >nul
    echo %GREEN% JAR文件已回滚
)

if defined LATEST_FRONTEND (
    rd /s /q "%PROJECT_DIR%baseu-admin\dist" 2>nul
    xcopy "%BACKUP_DIR%\!LATEST_FRONTEND!" "%PROJECT_DIR%baseu-admin\dist\" /E /I /Y >nul
    echo %GREEN% 前端文件已回滚
)

goto :restart_backend

REM 安装Java函数
:install_java
echo %YELLOW% 请手动安装Java 17或更高版本
echo 下载地址: https://adoptium.net/
pause
exit /b 1

REM 安装Maven函数
:install_maven
echo %YELLOW% 请手动安装Maven
echo 下载地址: https://maven.apache.org/download.cgi
pause
exit /b 1

REM 安装Node.js函数
:install_node
echo %YELLOW% 请手动安装Node.js
echo 下载地址: https://nodejs.org/
pause
exit /b 1

REM 安装Git函数
:install_git
echo %YELLOW% 请手动安装Git
echo 下载地址: https://git-scm.com/download/win
pause
exit /b 1
