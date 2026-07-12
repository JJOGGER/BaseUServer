#!/bin/bash

# BaseU 一键部署脚本 (简化稳定版)
# 功能：自动检查环境、处理冲突、部署应用

set +e  # 不在错误时立即退出，手动处理错误

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        return 1
    fi
    return 0
}

# 环境检查（简化版）
check_environment() {
    log_step "检查运行环境..."
    
    # 检查Java（支持多个常见路径）
    if check_command java; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1)
        log_info "Java: $JAVA_VERSION"
        export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    elif [ -d "/www/server/java/jdk-17.0.8" ]; then
        log_info "检测到宝塔面板安装的Java 17"
        export JAVA_HOME=/www/server/java/jdk-17.0.8
        export PATH=$JAVA_HOME/bin:$PATH
        JAVA_VERSION=$(java -version 2>&1 | head -n 1)
        log_info "Java: $JAVA_VERSION"
    elif [ -d "/opt/java17" ]; then
        log_info "检测到手动安装的Java 17"
        export JAVA_HOME=/opt/java17
        export PATH=$JAVA_HOME/bin:$PATH
        JAVA_VERSION=$(java -version 2>&1 | head -n 1)
        log_info "Java: $JAVA_VERSION"
    else
        log_error "未检测到Java，请先安装Java 17+"
        log_info "CentOS: yum install java-17-openjdk"
        log_info "Ubuntu: apt install openjdk-17-jdk"
        log_info "或者运行: ./install-centos7-env.sh"
        exit 1
    fi
    
    # 检查Maven
    if check_command mvn; then
        MVN_VERSION=$(mvn -version | head -n 1)
        log_info "Maven: $MVN_VERSION"
    elif [ -d "/www/server/maven" ]; then
        log_info "检测到宝塔面板安装的Maven"
        export M2_HOME=/www/server/maven
        export PATH=$M2_HOME/bin:$PATH
        MVN_VERSION=$(mvn -version | head -n 1)
        log_info "Maven: $MVN_VERSION"
    elif [ -d "/opt/maven" ]; then
        log_info "检测到手动安装的Maven"
        export M2_HOME=/opt/maven
        export PATH=$M2_HOME/bin:$PATH
        MVN_VERSION=$(mvn -version | head -n 1)
        log_info "Maven: $MVN_VERSION"
    else
        log_error "未检测到Maven，请先安装Maven"
        log_info "下载: https://maven.apache.org/download.cgi"
        log_info "或者运行: ./install-centos7-env.sh"
        exit 1
    fi
    
    # 检查Node.js
    if check_command node; then
        NODE_VERSION=$(node -v)
        NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
        log_info "Node.js: $NODE_VERSION (主版本: $NODE_MAJOR_VERSION)"
        
        # 检查Node.js版本是否满足要求
        if [ "$NODE_MAJOR_VERSION" -lt 16 ]; then
            log_error "Node.js版本过低 (当前: $NODE_VERSION, 需要: >=16.0.0)"
            log_info "Vite 5.x需要Node.js 16+"
            log_info "请升级Node.js或运行: ./install-centos7-env.sh"
            exit 1
        fi
    elif [ -d "/www/server/nodejs" ]; then
        log_info "检测到宝塔面板安装的Node.js"
        export NODE_HOME=/www/server/nodejs
        export PATH=$NODE_HOME/bin:$PATH
        NODE_VERSION=$(node -v)
        NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
        log_info "Node.js: $NODE_VERSION (主版本: $NODE_MAJOR_VERSION)"
        
        if [ "$NODE_MAJOR_VERSION" -lt 16 ]; then
            log_error "Node.js版本过低 (当前: $NODE_VERSION, 需要: >=16.0.0)"
            exit 1
        fi
    elif [ -d "/opt/nodejs" ]; then
        log_info "检测到手动安装的Node.js"
        export NODE_HOME=/opt/nodejs
        export PATH=$NODE_HOME/bin:$PATH
        NODE_VERSION=$(node -v)
        NODE_MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
        log_info "Node.js: $NODE_VERSION (主版本: $NODE_MAJOR_VERSION)"
        
        if [ "$NODE_MAJOR_VERSION" -lt 16 ]; then
            log_error "Node.js版本过低 (当前: $NODE_VERSION, 需要: >=16.0.0)"
            exit 1
        fi
    else
        log_error "未检测到Node.js，请先安装Node.js"
        log_info "CentOS: yum install nodejs npm"
        log_info "Ubuntu: apt install nodejs npm"
        log_info "或者运行: ./install-centos7-env.sh"
        exit 1
    fi
    
    # 检查Git
    if check_command git; then
        GIT_VERSION=$(git --version)
        log_info "Git: $GIT_VERSION"
    else
        log_error "未检测到Git，请先安装Git"
        log_info "CentOS: yum install git"
        log_info "Ubuntu: apt install git"
        exit 1
    fi
    
    log_info "环境检查完成"
}

# 处理Git冲突
handle_git_conflict() {
    log_warn "检测到Git冲突，使用远程版本覆盖本地..."
    
    # 放弃本地修改
    git reset --hard origin/main
    git clean -fd
    
    log_info "冲突已解决"
}

# Git拉取代码
pull_code() {
    log_step "拉取最新代码..."
    
    cd /www/wwwroot/BaseUServer || exit 1
    
    # 检查是否有未提交的修改
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "检测到未提交的修改，暂存本地修改..."
        git stash push -m "部署前自动保存" || true
    fi
    
    # 拉取代码
    git fetch origin
    
    # 检查是否需要更新
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        log_info "代码已是最新"
        return 0
    fi
    
    # 尝试拉取
    if git pull origin main; then
        log_info "代码拉取完成"
    else
        log_warn "拉取失败，处理冲突..."
        handle_git_conflict
    fi
}

# 构建后端
build_backend() {
    log_step "构建后端应用..."
    
    cd /www/wwwroot/BaseUServer || exit 1
    
    if [ ! -f "pom.xml" ]; then
        log_error "未找到pom.xml文件"
        exit 1
    fi
    
    # 清理并打包
    if mvn clean package -DskipTests -U; then
        log_info "后端构建完成"
    else
        log_error "后端构建失败"
        exit 1
    fi
    
    if [ ! -f "target/baseu-server-1.0.0.jar" ]; then
        log_error "构建失败，未找到jar文件"
        exit 1
    fi
}

# 构建前端
build_frontend() {
    log_step "构建前端应用..."
    
    cd /www/wwwroot/BaseUServer/baseu-admin || exit 1
    
    if [ ! -f "package.json" ]; then
        log_error "未找到package.json文件"
        exit 1
    fi
    
    # 清理npm缓存（解决npmrc冲突）
    npm cache clean --force 2>/dev/null || true
    
    # 删除node_modules重新安装
    if [ -d "node_modules" ]; then
        log_info "清理旧的依赖..."
        rm -rf node_modules
    fi
    
    # 安装依赖
    log_info "安装前端依赖..."
    if npm install --registry=https://registry.npmmirror.com; then
        log_info "依赖安装完成"
    else
        log_error "依赖安装失败"
        exit 1
    fi
    
    # 构建
    if npm run build; then
        log_info "前端构建完成"
    else
        log_error "前端构建失败"
        exit 1
    fi
    
    if [ ! -d "dist" ]; then
        log_error "前端构建失败，未找到dist目录"
        exit 1
    fi
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    
    # 查找并停止旧进程
    PID=$(ps aux | grep 'baseu-server-1.0.0.jar' | grep -v grep | awk '{print $2}')
    
    if [ -n "$PID" ]; then
        log_info "停止旧进程 (PID: $PID)"
        kill -15 $PID 2>/dev/null || true
        sleep 5
        
        # 强制杀死
        if ps -p $PID > /dev/null 2>&1; then
            kill -9 $PID 2>/dev/null || true
            log_warn "强制停止进程"
        fi
    fi
    
    # 创建日志目录
    mkdir -p /www/wwwroot/BaseUServer/logs
    
    # 启动新进程
    cd /www/wwwroot/BaseUServer
    nohup java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=prod > logs/app.log 2>&1 &
    
    # 等待启动
    sleep 15
    
    # 检查进程
    NEW_PID=$(ps aux | grep 'baseu-server-1.0.0.jar' | grep -v grep | awk '{print $2}')
    
    if [ -n "$NEW_PID" ]; then
        log_info "后端服务启动成功 (PID: $NEW_PID)"
    else
        log_error "后端服务启动失败"
        tail -n 50 logs/app.log
        exit 1
    fi
}

# 重载Nginx
reload_nginx() {
    log_step "重载Nginx..."
    
    if command -v nginx &> /dev/null; then
        if nginx -t; then
            nginx -s reload
            log_info "Nginx重载成功"
        else
            log_warn "Nginx配置检查失败，跳过重载"
        fi
    else
        log_warn "Nginx未安装，跳过重载"
    fi
}

# 创建备份
create_backup() {
    log_step "创建备份..."
    
    BACKUP_DIR="/www/wwwroot/backups"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    mkdir -p $BACKUP_DIR
    
    # 备份jar文件
    if [ -f "/www/wwwroot/BaseUServer/target/baseu-server-1.0.0.jar" ]; then
        cp /www/wwwroot/BaseUServer/target/baseu-server-1.0.0.jar $BACKUP_DIR/baseu-server-$TIMESTAMP.jar
        log_info "JAR文件已备份"
    fi
    
    # 备份前端
    if [ -d "/www/wwwroot/BaseUServer/baseu-admin/dist" ]; then
        cp -r /www/wwwroot/BaseUServer/baseu-admin/dist $BACKUP_DIR/frontend-$TIMESTAMP
        log_info "前端文件已备份"
    fi
    
    # 清理30天前的备份
    find $BACKUP_DIR -type f -mtime +30 -delete 2>/dev/null || true
    find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    
    log_info "备份完成"
}

# 回滚
rollback() {
    log_error "部署失败，开始回滚..."
    
    BACKUP_DIR="/www/wwwroot/backups"
    LATEST_JAR=$(ls -t $BACKUP_DIR/baseu-server-*.jar 2>/dev/null | head -n 1)
    LATEST_FRONTEND=$(ls -td $BACKUP_DIR/frontend-* 2>/dev/null | head -n 1)
    
    if [ -n "$LATEST_JAR" ]; then
        cp $LATEST_JAR /www/wwwroot/BaseUServer/target/baseu-server-1.0.0.jar
        log_info "JAR文件已回滚"
    fi
    
    if [ -n "$LATEST_FRONTEND" ]; then
        rm -rf /www/wwwroot/BaseUServer/baseu-admin/dist
        cp -r $LATEST_FRONTEND /www/wwwroot/BaseUServer/baseu-admin/dist
        log_info "前端文件已回滚"
    fi
    
    restart_backend
    reload_nginx
    
    log_error "回滚完成"
    exit 1
}

# 主函数
main() {
    log_info "========================================"
    log_info "   BaseU 一键部署脚本"
    log_info "========================================"
    
    # 检查环境
    check_environment
    
    # 创建备份
    create_backup
    
    # 拉取代码
    pull_code
    
    # 构建应用
    build_backend
    build_frontend
    
    # 部署
    restart_backend
    reload_nginx
    
    log_info "========================================"
    log_info "   部署完成！"
    log_info "========================================"
}

# 错误处理
trap 'rollback' ERR

# 执行主函数
main
