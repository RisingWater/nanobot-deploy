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

echo "请选择运行选项:"
echo "1. 使用默认用户 (容器内用户)"
echo "2. 使用当前宿主机用户 ($USER_ID:$GROUP_ID)"
echo ""
read -p "请选择 (1-2): " choice

case $choice in
    1)
        USER_ARG=""
        echo "使用容器内默认用户"
        ;;
    2)
        USER_ARG="--user $USER_ID:$GROUP_ID"
        echo "使用宿主机用户 ($USER_ID:$GROUP_ID)"
        ;;
    *)
        echo "无效的选择，使用默认选项"
        USER_ARG=""
        ;;
esac

echo ""
echo "请选择端口映射:"
echo "1. 默认端口 (18780:18780, 18790:18790)"
echo "2. 自定义端口"
echo ""
read -p "请选择 (1-2): " port_choice

case $port_choice in
    1)
        PORT_MAPPING="-p 18780:18780 -p 18790:18790"
        echo "使用默认端口映射"
        ;;
    2)
        read -p "请输入 WebUI 外部端口: " webui_port
        read -p "请输入 Gateway 外部端口: " gateway_port
        PORT_MAPPING="-p ${webui_port}:18780 -p ${gateway_port}:18790"
        echo "使用自定义端口映射: $PORT_MAPPING"
        ;;
    *)
        echo "无效的选择，使用默认端口"
        PORT_MAPPING="-p 18780:18780 -p 18790:18790"
        ;;
esac

echo ""
echo "正在启动 nanobot 容器..."

# 停止并删除已存在的容器
docker stop nanobot 2>/dev/null || true
docker rm nanobot 2>/dev/null || true

# 运行容器
docker run -d \
  --name nanobot \
  $PORT_MAPPING \
  -v $HOME/.nanobot:/home/nanobot/.nanobot \
  -e TZ=Asia/Shanghai \
  $USER_ARG \
  nanobot-all-in-one

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