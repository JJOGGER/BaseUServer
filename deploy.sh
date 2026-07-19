#!/bin/bash

# BaseU 一键部署脚本 (简化稳定版)
# 功能：自动检查环境、处理冲突、部署应用

set +e  # 不在错误时立即退出，手动处理错误

cd "$(dirname "$0")"
# 拉代码后可能丢执行权限，启动时自动恢复
chmod 777 start.sh deploy.sh install-centos7-env.sh release/start-prod.sh 2>/dev/null || true
chmod 777 *.sh 2>/dev/null || true

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

# 是否为 Java 17+
is_java17_plus() {
    local ver
    ver=$(java -version 2>&1 | head -n 1)
    echo "$ver" | grep -Eq '"1[7-9]\.|\"2[0-9]\.'
}

# 环境检查：优先宝塔 JDK 17，避免系统 Java 7 抢占 PATH
check_environment() {
    log_step "检查运行环境..."

    JAVA_OK=0
    # 1) 优先扫描宝塔 / 常见 JDK 17 安装路径
    if [ -d "/www/server/java" ]; then
        for home in /www/server/java/jdk-17* /www/server/java/jdk-21*; do
            if [ -x "$home/bin/java" ]; then
                export JAVA_HOME="$home"
                export PATH="$JAVA_HOME/bin:$PATH"
                log_info "使用宝塔 Java: $JAVA_HOME"
                JAVA_OK=1
                break
            fi
        done
    fi
    if [ "$JAVA_OK" -eq 0 ] && [ -x "/opt/java17/bin/java" ]; then
        export JAVA_HOME=/opt/java17
        export PATH=$JAVA_HOME/bin:$PATH
        log_info "使用 /opt/java17"
        JAVA_OK=1
    fi
    # 2) 仅当 PATH 中的 java 已是 17+ 才采用
    if [ "$JAVA_OK" -eq 0 ] && check_command java && is_java17_plus; then
        export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
        export PATH=$JAVA_HOME/bin:$PATH
        log_info "使用 PATH 中的 Java 17+: $JAVA_HOME"
        JAVA_OK=1
    fi
    if [ "$JAVA_OK" -eq 0 ]; then
        if check_command java; then
            log_error "当前 Java 版本过低: $(java -version 2>&1 | head -n 1)"
        fi
        log_error "未找到 Java 17+，请在宝塔安装 JDK 17 后再部署"
        log_info "常见路径: /www/server/java/jdk-17.x.x"
        exit 1
    fi
    log_info "Java: $(java -version 2>&1 | head -n 1)"

    # Maven：优先宝塔，并确保用上面的 JAVA_HOME 跑
    MVN_OK=0
    for home in /www/server/maven /opt/maven /usr/share/maven; do
        if [ -x "$home/bin/mvn" ]; then
            export M2_HOME="$home"
            export MAVEN_HOME="$home"
            export PATH="$M2_HOME/bin:$PATH"
            log_info "使用 Maven: $M2_HOME"
            MVN_OK=1
            break
        fi
    done
    if [ "$MVN_OK" -eq 0 ] && check_command mvn; then
        log_info "使用 PATH 中的 Maven"
        MVN_OK=1
    fi
    if [ "$MVN_OK" -eq 0 ]; then
        log_error "未检测到 Maven，请先安装"
        exit 1
    fi
    # 用 JAVA_HOME 验证 mvn 可运行
    if ! mvn -version >/dev/null 2>&1; then
        log_error "Maven 无法运行（通常仍是 Java 版本不对）"
        log_info "JAVA_HOME=$JAVA_HOME"
        java -version
        exit 1
    fi
    log_info "Maven: $(mvn -version 2>/dev/null | head -n 1)"

    # Node.js：CentOS7 常见 GLIBC 过旧，不可用时允许跳过前端构建
    SKIP_FRONTEND=0
    export SKIP_FRONTEND
    NODE_BIN=""
    for home in /www/server/nodejs /opt/nodejs; do
        if [ -x "$home/bin/node" ]; then
            export NODE_HOME="$home"
            export PATH="$NODE_HOME/bin:$PATH"
            NODE_BIN="$home/bin/node"
            break
        fi
    done
    if [ -z "$NODE_BIN" ] && check_command node; then
        NODE_BIN=$(command -v node)
    fi
    if [ -n "$NODE_BIN" ]; then
        if NODE_VERSION=$($NODE_BIN -v 2>/dev/null); then
            log_info "Node.js: $NODE_VERSION"
        else
            log_warn "Node.js 无法运行（可能是 CentOS7 GLIBC 过旧），将跳过前端构建"
            SKIP_FRONTEND=1
        fi
    else
        log_warn "未检测到 Node.js，将跳过前端构建"
        SKIP_FRONTEND=1
    fi

    if check_command git; then
        log_info "Git: $(git --version)"
    else
        log_error "未检测到 Git"
        exit 1
    fi

    mkdir -p /www/wwwroot/BaseUServer/logs
    chmod 777 start.sh deploy.sh install-centos7-env.sh 2>/dev/null || true
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
    
    # 检查是否有未提交的修改（兼容旧版 git，不用 stash push / @）
    if [ -n "$(git status --porcelain)" ]; then
        log_warn "检测到未提交的修改，暂存本地修改..."
        git stash save "部署前自动保存" || true
    fi
    
    # 拉取代码
    git fetch origin
    
    # 检查是否需要更新
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse origin/main 2>/dev/null || git rev-parse @{u} 2>/dev/null)
    
    if [ -n "$REMOTE" ] && [ "$LOCAL" = "$REMOTE" ]; then
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

    chmod 777 start.sh deploy.sh install-centos7-env.sh 2>/dev/null || true
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
    if [ "${SKIP_FRONTEND:-0}" = "1" ]; then
        log_warn "跳过前端构建（Node 不可用）。如已有 dist 可继续用旧前端"
        return 0
    fi

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
        log_warn "依赖安装失败，跳过前端构建"
        return 0
    fi
    
    # 构建
    if npm run build; then
        log_info "前端构建完成"
    else
        log_warn "前端构建失败，保留已有 dist（如有）"
        return 0
    fi
    
    if [ ! -d "dist" ]; then
        log_warn "未找到 dist 目录，请本地构建后上传 baseu-admin/dist"
    fi
}

# 重启后端服务
restart_backend() {
    log_step "重启后端服务..."
    SERVER_PORT=${SERVER_PORT:-8081}
    export SERVER_PORT
    
    # 查找并停止旧 jar 进程
    PIDS=$(ps aux | grep 'baseu-server-1.0.0.jar' | grep -v grep | awk '{print $2}')
    if [ -n "$PIDS" ]; then
        log_info "停止旧 jar 进程: $PIDS"
        kill -15 $PIDS 2>/dev/null || true
        sleep 3
        kill -9 $PIDS 2>/dev/null || true
    fi

    # 释放应用端口（宝塔面板启动的 java 往往不带 jar 名，上面杀不到）
    free_port "$SERVER_PORT"
    
    # 启动新进程（输出到 logs/app.log，宝塔面板也可看项目日志）
    cd /www/wwwroot/BaseUServer
    mkdir -p logs
    # 明确指定 Java 17，避免宝塔/系统默认 Java 7
    if [ -z "$JAVA_HOME" ] || ! "$JAVA_HOME/bin/java" -version 2>&1 | grep -Eq '"1[7-9]\.|\"2[0-9]\.'; then
        for home in /www/server/java/jdk-17* /www/server/java/jdk-21*; do
            if [ -x "$home/bin/java" ]; then
                export JAVA_HOME="$home"
                break
            fi
        done
    fi
    if [ -z "$JAVA_HOME" ] || [ ! -x "$JAVA_HOME/bin/java" ]; then
        log_error "启动失败：未找到 Java 17+，请在宝塔安装 JDK 17"
        exit 1
    fi
    log_info "启动使用 Java: $JAVA_HOME ，端口: $SERVER_PORT"
    nohup "$JAVA_HOME/bin/java" -jar target/baseu-server-1.0.0.jar --spring.profiles.active=prod --server.port=$SERVER_PORT > logs/app.log 2>&1 &
    
    # 等待启动
    sleep 15
    
    # 检查进程
    NEW_PID=$(ps aux | grep 'baseu-server-1.0.0.jar' | grep -v grep | awk '{print $2}')
    
    if [ -n "$NEW_PID" ]; then
        log_info "后端服务启动成功 (PID: $NEW_PID, port=$SERVER_PORT)"
        log_info "查看日志: tail -f /www/wwwroot/BaseUServer/logs/app.log"
    else
        log_error "后端服务启动失败，最近日志如下："
        tail -n 80 logs/app.log
        exit 1
    fi
}

# 释放指定端口
free_port() {
    local port=${1:-8081}
    log_info "检查并释放 ${port} 端口..."
    local pids=""
    if command -v lsof >/dev/null 2>&1; then
        pids=$(lsof -t -i:${port} 2>/dev/null || true)
    fi
    if [ -z "$pids" ] && command -v fuser >/dev/null 2>&1; then
        pids=$(fuser ${port}/tcp 2>/dev/null || true)
    fi
    if [ -z "$pids" ] && command -v ss >/dev/null 2>&1; then
        pids=$(ss -lptn "sport = :${port}" 2>/dev/null | grep -oE 'pid=[0-9]+' | cut -d= -f2 | sort -u)
    fi
    if [ -z "$pids" ] && command -v netstat >/dev/null 2>&1; then
        pids=$(netstat -tlnp 2>/dev/null | awk -v p=":${port} " '$0 ~ p {print $7}' | cut -d'/' -f1 | grep -E '^[0-9]+$' | sort -u)
    fi

    if [ -n "$pids" ]; then
        log_warn "${port} 被占用，结束进程: $pids"
        kill -15 $pids 2>/dev/null || true
        sleep 2
        kill -9 $pids 2>/dev/null || true
        sleep 1
    else
        log_info "${port} 端口空闲"
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
