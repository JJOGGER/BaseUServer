#!/bin/bash

# BaseU 一键部署脚本
# 功能：自动检查环境、处理冲突、部署应用

set -e  # 遇到错误立即退出

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

# 安装Java
install_java() {
    log_step "检查Java环境..."
    
    if check_command java; then
        # 获取Java版本信息
        JAVA_FULL_VERSION=$(java -version 2>&1 | head -n 1)
        log_info "检测到Java: $JAVA_FULL_VERSION"
        
        # 尝试多种方式提取版本号
        JAVA_VERSION=$(java -version 2>&1 | sed -n 's/.* version "\(.*\)".*/\1/p' | cut -d'.' -f1)
        
        # 如果提取失败，尝试其他方式
        if [ -z "$JAVA_VERSION" ]; then
            JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
        fi
        
        # 如果还是失败，直接使用1.8作为默认值
        if [ -z "$JAVA_VERSION" ]; then
            JAVA_VERSION=1
        fi
        
        log_info "提取的Java主版本: $JAVA_VERSION"
        
        # 检查版本是否满足要求
        if [ "$JAVA_VERSION" -ge 17 ] 2>/dev/null; then
            log_info "Java版本满足要求 (>= 17)，跳过安装"
            return 0
        else
            log_warn "Java版本过低 (当前: $JAVA_VERSION, 需要: 17+)"
            log_info "将尝试升级Java..."
        fi
    else
        log_info "未检测到Java，开始安装..."
    fi
    
    log_info "正在安装Java 17..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION_ID=$VERSION_ID
    fi
    
    case $OS in
        centos|rhel)
            # CentOS 7/8 使用EPEL或手动安装
            if [ "$VERSION_ID" = "7" ]; then
                # CentOS 7 使用Oracle JDK或从其他源安装
                log_info "CentOS 7，使用手动安装方式..."
                cd /tmp
                wget --no-check-certificate -O jdk17.tar.gz https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz || \
                wget --no-check-certificate -O jdk17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8%2B101/OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_101.tar.gz
                tar -xzf jdk17.tar.gz
                JDK_DIR=$(ls -d jdk-*)
                mv $JDK_DIR /opt/java17
                rm -f jdk17.tar.gz
            else
                # CentOS 8+ 尝试使用dnf
                dnf install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || \
                yum install -y java-17-openjdk java-17-openjdk-devel 2>/dev/null || \
                (cd /tmp && wget --no-check-certificate -O jdk17.tar.gz https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8%2B101/OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_101.tar.gz && tar -xzf jdk17.tar.gz && mv jdk-*/ /opt/java17 && rm -f jdk17.tar.gz)
            fi
            ;;
        ubuntu|debian)
            apt update
            apt install -y openjdk-17-jdk
            ;;
        *)
            log_error "不支持的操作系统: $OS"
            exit 1
            ;;
    esac
    
    # 设置JAVA_HOME
    if [ -d "/opt/java17" ]; then
        export JAVA_HOME=/opt/java17
    else
        export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    fi
    
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc
    
    # 立即生效
    export PATH=$JAVA_HOME/bin:$PATH
    
    log_info "Java安装完成"
}

# 安装Maven
install_maven() {
    log_step "检查Maven环境..."
    
    if check_command mvn; then
        MVN_VERSION=$(mvn -version | head -n 1 | awk '{print $3}')
        log_info "Maven已安装，版本：$MVN_VERSION"
        return 0
    fi
    
    log_info "正在安装Maven..."
    
    MAVEN_VERSION="3.9.5"
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
    
    cd /tmp
    wget -O maven.tar.gz $MAVEN_URL
    tar -xzf maven.tar.gz
    mv apache-maven-${MAVEN_VERSION} /opt/maven
    
    # 设置环境变量
    export M2_HOME=/opt/maven
    export PATH=$M2_HOME/bin:$PATH
    echo "export M2_HOME=/opt/maven" >> ~/.bashrc
    echo "export PATH=\$M2_HOME/bin:\$PATH" >> ~/.bashrc
    
    rm -f maven.tar.gz
    
    log_info "Maven安装完成"
}

# 安装Node.js
install_nodejs() {
    log_step "检查Node.js环境..."
    
    if check_command node; then
        NODE_VERSION=$(node -v)
        log_info "Node.js已安装，版本：$NODE_VERSION"
        return 0
    fi
    
    log_info "正在安装Node.js..."
    
    # 使用nvm安装
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 18
    nvm use 18
    
    echo "export NVM_DIR=\"$HOME/.nvm\"" >> ~/.bashrc
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> ~/.bashrc
    
    log_info "Node.js安装完成"
}

# 安装Git
install_git() {
    log_step "检查Git环境..."
    
    if check_command git; then
        GIT_VERSION=$(git --version)
        log_info "Git已安装，版本：$GIT_VERSION"
        return 0
    fi
    
    log_info "正在安装Git..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    fi
    
    case $OS in
        centos|rhel)
            yum install -y git
            ;;
        ubuntu|debian)
            apt update
            apt install -y git
            ;;
        *)
            log_error "不支持的操作系统: $OS"
            exit 1
            ;;
    esac
    
    log_info "Git安装完成"
}

# 处理Git冲突
handle_git_conflict() {
    log_warn "检测到Git冲突，正在处理..."
    
    # 查找冲突文件
    CONFLICT_FILES=$(git diff --name-only --diff-filter=U)
    
    if [ -z "$CONFLICT_FILES" ]; then
        log_info "没有冲突文件"
        return 0
    fi
    
    log_warn "冲突文件："
    echo "$CONFLICT_FILES"
    
    # 策略：使用远程版本覆盖本地
    log_info "策略：使用远程版本覆盖本地修改"
    
    for file in $CONFLICT_FILES; do
        git checkout --theirs "$file"
        git add "$file"
        log_info "已解决冲突：$file"
    done
    
    git commit -m "解决Git冲突：使用远程版本"
    log_info "冲突解决完成"
}

# Git拉取代码
pull_code() {
    log_step "拉取最新代码..."
    
    cd /www/wwwroot/BaseUServer
    
    # 检查是否有未提交的修改
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "检测到未提交的修改"
        git stash push -m "部署前自动保存"
    fi
    
    # 拉取代码
    git fetch origin
    
    # 检查是否有冲突
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})
    
    if [ $LOCAL = $REMOTE ]; then
        log_info "代码已是最新"
        return 0
    elif [ $LOCAL = $BASE ]; then
        log_info "需要拉取更新"
        git pull origin main || handle_git_conflict
    elif [ $REMOTE = $BASE ]; then
        log_warn "本地有未推送的提交"
    else
        log_warn "存在分歧，需要处理"
        handle_git_conflict
    fi
    
    log_info "代码拉取完成"
}

# 构建后端
build_backend() {
    log_step "构建后端应用..."
    
    cd /www/wwwroot/BaseUServer
    
    # 检查Maven配置
    if [ ! -f "pom.xml" ]; then
        log_error "未找到pom.xml文件"
        exit 1
    fi
    
    # 清理并打包
    mvn clean package -DskipTests -U
    
    if [ ! -f "target/baseu-server-1.0.0.jar" ]; then
        log_error "构建失败，未找到jar文件"
        exit 1
    fi
    
    log_info "后端构建完成"
}

# 构建前端
build_frontend() {
    log_step "构建前端应用..."
    
    cd /www/wwwroot/BaseUServer/baseu-admin
    
    # 检查package.json
    if [ ! -f "package.json" ]; then
        log_error "未找到package.json文件"
        exit 1
    fi
    
    # 安装依赖
    if [ ! -d "node_modules" ]; then
        log_info "安装前端依赖..."
        npm install
    fi
    
    # 构建
    npm run build
    
    if [ ! -d "dist" ]; then
        log_error "前端构建失败"
        exit 1
    fi
    
    log_info "前端构建完成"
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    
    # 查找并停止旧进程
    PID=$(ps aux | grep 'baseu-server-1.0.0.jar' | grep -v grep | awk '{print $2}')
    
    if [ -n "$PID" ]; then
        log_info "停止旧进程 (PID: $PID)"
        kill -15 $PID
        sleep 5
        
        # 强制杀死
        if ps -p $PID > /dev/null; then
            kill -9 $PID
            log_warn "强制停止进程"
        fi
    fi
    
    # 启动新进程
    cd /www/wwwroot/BaseUServer
    nohup java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=prod > logs/app.log 2>&1 &
    
    # 等待启动
    sleep 10
    
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
        nginx -t && nginx -s reload
        log_info "Nginx重载成功"
    else
        log_warn "Nginx未安装，跳过重载"
    fi
}

# 数据库迁移
migrate_database() {
    log_step "执行数据库迁移..."
    
    cd /www/wwwroot/BaseUServer
    
    # Flyway会自动执行迁移
    log_info "数据库迁移将在应用启动时自动执行"
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
    find $BACKUP_DIR -type f -mtime +30 -delete
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
}

# 主函数
main() {
    log_info "========================================"
    log_info "   BaseU 一键部署脚本"
    log_info "========================================"
    
    # 检查环境
    install_git
    install_java
    install_maven
    install_nodejs
    
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
