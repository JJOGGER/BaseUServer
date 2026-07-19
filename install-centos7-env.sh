#!/bin/bash

# CentOS 7 环境安装脚本
# 安装Java 17、Maven、Node.js、Git

set -e

cd "$(dirname "$0")"
chmod 777 start.sh deploy.sh install-centos7-env.sh 2>/dev/null || true
chmod 777 *.sh 2>/dev/null || true

echo "========================================="
echo "   CentOS 7 环境安装脚本"
echo "========================================="

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "请使用root用户运行此脚本"
    exit 1
fi

# 安装Java 17
echo "[STEP] 安装Java 17..."
cd /tmp

# 下载Adoptium (Eclipse Temurin) OpenJDK 17
if [ ! -f "/opt/java17/bin/java" ]; then
    echo "下载OpenJDK 17..."
    wget --no-check-certificate -O jdk17.tar.gz \
        https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8%2B101/OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_101.tar.gz
    
    echo "解压Java 17..."
    tar -xzf jdk17.tar.gz
    JDK_DIR=$(ls -d jdk-*)
    mv $JDK_DIR /opt/java17
    rm -f jdk17.tar.gz
    
    # 设置环境变量
    cat >> /etc/profile.d/java.sh << 'EOF'
export JAVA_HOME=/opt/java17
export PATH=$JAVA_HOME/bin:$PATH
EOF
    
    chmod +x /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    
    echo "Java 17安装完成"
else
    echo "Java 17已安装"
fi

# 安装Maven
echo "[STEP] 安装Maven..."
cd /tmp

if [ ! -f "/opt/maven/bin/mvn" ]; then
    echo "下载Maven 3.9.5..."
    wget -O maven.tar.gz \
        https://archive.apache.org/dist/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
    
    echo "解压Maven..."
    tar -xzf maven.tar.gz
    mv apache-maven-3.9.5 /opt/maven
    rm -f maven.tar.gz
    
    # 设置环境变量
    cat >> /etc/profile.d/maven.sh << 'EOF'
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
EOF
    
    chmod +x /etc/profile.d/maven.sh
    source /etc/profile.d/maven.sh
    
    echo "Maven安装完成"
else
    echo "Maven已安装"
fi

# 安装Node.js
echo "[STEP] 安装Node.js 18..."
cd /tmp

if ! command -v node &> /dev/null; then
    echo "下载Node.js 18..."
    wget -O nodejs.tar.xz \
        https://nodejs.org/dist/v18.20.8/node-v18.20.8-linux-x64.tar.xz
    
    echo "解压Node.js..."
    tar -xf nodejs.tar.xz
    mv node-v18.20.8-linux-x64 /opt/nodejs
    rm -f nodejs.tar.xz
    
    # 设置环境变量
    cat >> /etc/profile.d/nodejs.sh << 'EOF'
export NODE_HOME=/opt/nodejs
export PATH=$NODE_HOME/bin:$PATH
EOF
    
    chmod +x /etc/profile.d/nodejs.sh
    source /etc/profile.d/nodejs.sh
    
    # 安装npm淘宝镜像
    npm config set registry https://registry.npmmirror.com
    
    echo "Node.js安装完成"
else
    echo "Node.js已安装"
fi

# 安装Git
echo "[STEP] 安装Git..."
if ! command -v git &> /dev/null; then
    yum install -y git
    echo "Git安装完成"
else
    echo "Git已安装"
fi

# 验证安装
echo ""
echo "========================================="
echo "   环境验证"
echo "========================================="
echo "Java版本:"
java -version 2>&1 | head -n 1
echo "Maven版本:"
mvn -version | head -n 1
echo "Node.js版本:"
node -v
echo "npm版本:"
npm -v
echo "Git版本:"
git --version

echo ""
echo "========================================="
echo "   安装完成！"
echo "========================================="
echo "请执行以下命令使环境变量生效："
echo "source /etc/profile"
echo "或者重新登录服务器"
