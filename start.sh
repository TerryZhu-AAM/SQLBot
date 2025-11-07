#!/bin/bash

SSR_PATH=/opt/sqlbot/g2-ssr
APP_PATH=/opt/sqlbot/app
PM2_CMD_PATH=$SSR_PATH/node_modules/pm2/bin/pm2

# 1. 启动 PostgreSQL (后台)
echo "正在启动 PostgreSQL..."
/usr/local/bin/docker-entrypoint.sh postgres &

# 2. 【关键改动】等待数据库完全就绪
#    使用 pg_isready 循环检查，直到数据库可以接受连接
echo "等待 PostgreSQL 完全就绪..."
until pg_isready -h 127.0.0.1 -p 5432 -U postgres -q; do
  echo "PostgreSQL 仍在启动中 (正在从崩溃中恢复)... 继续等待..."
  sleep 3
done

echo -e "\033[1;32mPostgreSQL 已就绪。开始启动应用服务。\033[0m"

# 3. 启动其他后台服务
echo "正在启动 PM2 (SSR) 服务..."
nohup $PM2_CMD_PATH start $SSR_PATH/app.js &

echo "正在启动 MCP 服务..."
nohup uvicorn main:mcp_app --host 0.0.0.0 --port 8001 &

# 4. 切换到应用目录并启动主 FastAPI 应用 (前台)
echo "正在启动主 FastAPI 应用..."
cd $APP_PATH
uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 --proxy-headers
