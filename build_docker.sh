#!/bin/bash
# nanobot Docker 构建脚本
# 适用于 Linux 系统

set -e

echo "nanobot Docker 构建脚本"
echo "========================"

# 获取当前用户 ID 和组 ID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

echo "当前用户: $(whoami)"
echo "用户 ID: $USER_ID"
echo "组 ID: $GROUP_ID"
echo ""

echo "请选择构建选项:"
echo "1. 使用默认 UID/GID (1000)"
echo "2. 使用当前用户的 UID/GID ($USER_ID/$GROUP_ID)"
echo "3. 自定义 UID/GID"
echo ""
read -p "请选择 (1-3): " choice

case $choice in
    1)
        BUILD_ARGS=""
        echo "使用默认 UID/GID (1000)"
        ;;
    2)
        BUILD_ARGS="--build-arg USER_ID=$USER_ID --build-arg GROUP_ID=$GROUP_ID"
        echo "使用当前用户的 UID/GID ($USER_ID/$GROUP_ID)"
        ;;
    3)
        read -p "请输入用户 ID: " custom_uid
        read -p "请输入组 ID: " custom_gid
        BUILD_ARGS="--build-arg USER_ID=$custom_uid --build-arg GROUP_ID=$custom_gid"
        echo "使用自定义 UID/GID ($custom_uid/$custom_gid)"
        ;;
    *)
        echo "无效的选择，使用默认选项"
        BUILD_ARGS=""
        ;;
esac

echo ""
echo "开始构建 nanobot Docker 镜像..."
echo "构建命令: docker build $BUILD_ARGS -t nanobot-all-in-one ."
echo ""

docker build $BUILD_ARGS -t nanobot-all-in-one .

if [ $? -eq 0 ]; then
    echo ""
    echo "构建成功！"
    echo ""
    echo "运行容器命令:"
    echo "docker run -d --name nanobot -p 18780:18780 -p 18790:18790 -v \$HOME/.nanobot:/home/nanobot/.nanobot nanobot-all-in-one"
    echo ""
    echo "如果使用自定义 UID/GID，请添加 --user 参数:"
    echo "docker run -d --name nanobot -p 18780:18780 -p 18790:18790 -v \$HOME/.nanobot:/home/nanobot/.nanobot --user ${custom_uid:-$USER_ID}:${custom_gid:-$GROUP_ID} nanobot-all-in-one"
else
    echo ""
    echo "构建失败！"
    exit 1
fi