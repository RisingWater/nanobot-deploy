#!/bin/bash
set -e

# 设置环境变量
export PATH="/app/venv/bin:$PATH"

# 显示启动信息
echo "=========================================="
echo "Starting Nanobot Gateway and WebUI..."
echo "=========================================="

# 第一步：更新 nanobot 代码
echo "Step 1: Updating nanobot code..."
cd /app/nanobot
git pull

# 第二步：更新 webui 代码
echo "Step 2: Updating nanobot-webui code..."
cd /app/nanobot-webui
git pull

# 第三步：构建前端并拷贝到 dist 目录
echo "Step 3: Building frontend..."
cd /app/nanobot-webui/web
bun install
bun run build

# 确保前端构建结果在正确的位置
cd /app/nanobot-webui
mkdir -p webui/web/dist
if [ -d "web/dist" ]; then
    cp -r web/dist/* webui/web/dist/
    echo "Frontend built and copied to webui/web/dist/"
else
    echo "Warning: web/dist directory not found"
fi

# 第四步：运行 nanobot webui
echo "[entrypoint] nanobot webui start"
exec nanobot webui start