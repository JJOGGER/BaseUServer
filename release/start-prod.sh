#!/bin/bash
# 服务器启动脚本：强制使用 prod，不会走 application-dev.yml
cd "$(dirname "$0")"
chmod 777 start-prod.sh 2>/dev/null || true
mkdir -p logs
nohup java -jar baseu-server-1.0.0.jar --spring.profiles.active=prod > logs/app.log 2>&1 &
echo "started PID=$!"
sleep 2
tail -n 30 logs/app.log
