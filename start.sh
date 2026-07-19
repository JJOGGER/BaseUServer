#!/bin/bash

# BaseU Server 启动脚本（兼容宝塔 / CentOS）

set -e

cd "$(dirname "$0")"

# 拉代码后可能丢执行权限，启动时自动恢复
chmod 777 start.sh deploy.sh install-centos7-env.sh release/start-prod.sh 2>/dev/null || true
chmod 777 *.sh 2>/dev/null || true

echo "======================================"
echo "   BaseU Server 启动脚本"
echo "======================================"
echo

# ---------- 选择 Java 17+（优先宝塔，避免系统自带 Java 7） ----------
setup_java() {
    local candidates=(
        "/www/server/java/jdk-17.0.8"
        "/www/server/java/jdk-17.0.9"
        "/www/server/java/jdk-17.0.10"
        "/www/server/java/jdk-17.0.11"
        "/www/server/java/jdk-17.0.12"
        "/www/server/java/jdk-17.0.13"
        "/www/server/java/jdk-17.0.14"
        "/www/server/java/jdk-17.0.15"
        "/www/server/java/jdk-17.0.16"
        "/www/server/java/jdk-17.0.17"
        "/www/server/java/jdk-17.0.18"
        "/www/server/java/jdk-17.0.19"
        "/www/server/java/jdk-17.0.20"
        "/opt/java17"
        "/usr/lib/jvm/java-17-openjdk"
        "/usr/lib/jvm/java-17"
    )

    # 扫描宝塔 java 目录下所有 jdk-17*
    if [ -d "/www/server/java" ]; then
        for d in /www/server/java/jdk-17*; do
            [ -d "$d" ] && candidates+=("$d")
        done
    fi

    for home in "${candidates[@]}"; do
        if [ -x "$home/bin/java" ]; then
            export JAVA_HOME="$home"
            export PATH="$JAVA_HOME/bin:$PATH"
            echo "[INFO] 使用 Java: $JAVA_HOME"
            java -version
            return 0
        fi
    done

    # 最后尝试 PATH 里的 java，但必须是 17+
    if command -v java >/dev/null 2>&1; then
        local ver
        ver=$(java -version 2>&1 | head -n 1)
        echo "[WARN] PATH 中的 Java: $ver"
        if echo "$ver" | grep -Eq '"1[7-9]\.|\"2[0-9]\.'; then
            export JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
            echo "[INFO] 使用 PATH 中的 Java 17+: $JAVA_HOME"
            return 0
        fi
    fi

    echo "[ERROR] 未找到 Java 17+"
    echo "请在宝塔「软件商店」安装 Java 项目管理器 / JDK 17"
    echo "或执行: yum install -y java-17-openjdk java-17-openjdk-devel"
    exit 1
}

# ---------- 选择 Maven ----------
setup_maven() {
    local candidates=(
        "/www/server/maven"
        "/opt/maven"
        "/usr/share/maven"
    )

    for home in "${candidates[@]}"; do
        if [ -x "$home/bin/mvn" ]; then
            export M2_HOME="$home"
            export MAVEN_HOME="$home"
            export PATH="$M2_HOME/bin:$PATH"
            echo "[INFO] 使用 Maven: $M2_HOME"
            mvn -version | head -n 1
            return 0
        fi
    done

    if command -v mvn >/dev/null 2>&1; then
        echo "[INFO] 使用 PATH 中的 Maven"
        mvn -version | head -n 1
        return 0
    fi

    echo "[ERROR] 未找到 Maven"
    echo "请在宝塔安装 Maven，或放到 /www/server/maven"
    exit 1
}

setup_java
echo
setup_maven
echo

# 服务器默认 prod；本地可 export SPRING_PROFILES_ACTIVE=dev
export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-prod}
mkdir -p logs /www/wwwroot/BaseUServer/logs 2>/dev/null || mkdir -p logs

echo "当前环境: $SPRING_PROFILES_ACTIVE"
echo

# 无参数时默认 JAR 启动；也可: ./start.sh 1|2|3
if [ -n "$1" ]; then
    choice="$1"
else
    echo "请选择启动方式:"
    echo "1) Maven 编译并启动 (开发)"
    echo "2) JAR 包启动 (推荐生产)"
    echo "3) Docker 启动"
    read -p "请输入选项 (1-3): " choice
fi

case $choice in
  1)
    echo "使用 Maven 编译并启动 (profile=$SPRING_PROFILES_ACTIVE)..."
    mvn clean compile -DskipTests
    mvn spring-boot:run -Dspring-boot.run.profiles=$SPRING_PROFILES_ACTIVE
    ;;
  2)
    echo "使用 JAR 包启动 (profile=$SPRING_PROFILES_ACTIVE)..."
    if [ ! -f "target/baseu-server-1.0.0.jar" ]; then
      echo "JAR 不存在，开始打包..."
      mvn clean package -DskipTests
    fi
    mkdir -p logs
    nohup java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=$SPRING_PROFILES_ACTIVE > logs/app.log 2>&1 &
    echo "已后台启动 PID=$!"
    sleep 3
    tail -n 40 logs/app.log
    ;;
  3)
    echo "使用 Docker 启动..."
    if [ ! -f ".env" ]; then
      echo "创建 .env 文件..."
      cp .env.example .env
      echo "请先编辑 .env 后再启动"
      exit 1
    fi
    docker-compose up -d
    echo "Docker 容器启动成功"
    docker-compose logs -f app
    ;;
  *)
    echo "无效的选项"
    exit 1
    ;;
esac
