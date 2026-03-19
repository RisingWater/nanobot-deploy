#!/bin/bash
# nanobot Docker 运行脚本
# 适用于 Linux 系统

set -e

echo "nanobot Docker 运行脚本"
echo "========================"

# 获取当前用户 ID 和组 ID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

echo "当前用户: $(whoami)"
echo "用户 ID: $USER_ID"
echo "组 ID: $GROUP_ID"
echo ""

# 检查镜像是否存在
if ! docker image inspect nanobot-all-in-one > /dev/null 2>&1; then
    echo "错误: nanobot-all-in-one 镜像不存在"
    echo "请先运行 build_docker.sh 构建镜像"
    exit 1
fi

echo ""
echo "正在启动 nanobot 容器..."

# 运行容器
docker run -d --name nanobot -p 18780:18780 -v $HOME:/home/nanobot --user $USER_ID:$GROUP_ID nanobot-all-in-one

if [ $? -eq 0 ]; then
    echo ""
    echo "容器启动成功！"
    echo ""
    echo "访问地址:"
    echo "- WebUI 管理界面: http://localhost:${webui_port:-18780}"
    echo "- Gateway API: http://localhost:${gateway_port:-18790}"
    echo ""
    echo "管理命令:"
    echo "- 查看日志: docker logs nanobot"
    echo "- 实时日志: docker logs -f nanobot"
    echo "- 停止容器: docker stop nanobot"
    echo "- 启动容器: docker start nanobot"
    echo "- 重启容器: docker restart nanobot"
    echo "- 删除容器: docker rm nanobot"
    echo "- 进入容器: docker exec -it nanobot bash"
else
    echo ""
    echo "容器启动失败！"
    exit 1
fi