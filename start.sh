#!/bin/bash

# BaseU Server 启动脚本

echo "======================================"
echo "   BaseU Server 启动脚本"
echo "======================================"

# 检查Java版本
java -version

# 设置环境变量
export SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-dev}

echo ""
echo "当前环境: $SPRING_PROFILES_ACTIVE"
echo ""

# 选择启动方式
echo "请选择启动方式:"
echo "1) Maven 启动"
echo "2) JAR 包启动"
echo "3) Docker 启动"
read -p "请输入选项 (1-3): " choice

case $choice in
  1)
    echo "使用Maven启动..."
    mvn spring-boot:run -Dspring.profiles.active=$SPRING_PROFILES_ACTIVE
    ;;
  2)
    echo "使用JAR包启动..."
    if [ ! -f "target/baseu-server-1.0.0.jar" ]; then
      echo "JAR文件不存在，开始打包..."
      mvn clean package -DskipTests
    fi
    java -jar target/baseu-server-1.0.0.jar --spring.profiles.active=$SPRING_PROFILES_ACTIVE
    ;;
  3)
    echo "使用Docker启动..."
    if [ ! -f ".env" ]; then
      echo "创建.env文件..."
      cp .env.example .env
      echo "请先编辑.env文件配置环境变量"
      exit 1
    fi
    docker-compose up -d
    echo "Docker容器启动成功"
    docker-compose logs -f app
    ;;
  *)
    echo "无效的选项"
    exit 1
    ;;
esac

