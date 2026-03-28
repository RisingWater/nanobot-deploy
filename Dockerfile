# nanobot 一体化部署镜像
# 从 Ubuntu 24.04 开始构建，包含 nanobot 和 nanobot-webui 功能
# 支持用户模式运行，避免 root 权限问题
# 从 Git 仓库直接克隆项目
FROM ubuntu:24.04

# 构建参数：用户 ID 和组 ID
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=nanobot

# 设置环境变量
ENV NANOBOT_REPO=https://github.com/HKUDS/nanobot \
    NANOBOT_WEBUI_REPO=https://github.com/Good0007/nanobot-webui.git \
    HOME=/home/$USERNAME

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    curl \
    ca-certificates \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    unzip \
    sudo \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Bun (用于前端构建)
RUN curl -fsSL https://bun.com/install | bash
RUN cp ~/.bun/bin/bun /usr/bin

# 创建工作目录并设置权限
RUN mkdir -p /app && chown -R $USER_ID:$GROUP_ID /app
RUN mkdir -p /home/$USERNAME && chown -R $USER_ID:$GROUP_ID /home/$USERNAME

# 拷贝启动脚本
COPY start.sh /app/start.sh
RUN chmod 777 /app/start.sh

# 切换到非 root 用户
USER $USER_ID
WORKDIR /app

# 从 Git 仓库克隆 nanobot 项目到 /app/nanobot
RUN git clone $NANOBOT_REPO /app/nanobot

# 从 Git 仓库克隆 nanobot-webui 项目到 /app/nanobot-webui
RUN git clone $NANOBOT_WEBUI_REPO /app/nanobot-webui

RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

RUN python3 -m pip install --upgrade pip

# 安装 nanobot Python 依赖
WORKDIR /app/nanobot
RUN pip install -e .

# 安装 nanobot-webui Python 依赖
WORKDIR /app/nanobot-webui
RUN pip install -e .

# 构建前端
WORKDIR /app/nanobot-webui/web
RUN bun install && bun run build

# 确保前端构建结果在正确的位置
WORKDIR /app/nanobot-webui
RUN mkdir -p webui/web/dist && \
    if [ -d "web/dist" ]; then cp -r web/dist/* webui/web/dist/; fi

# 创建用户配置目录
RUN mkdir -p $HOME/.nanobot && chmod 755 $HOME/.nanobot

# 暴露端口
# 18780: nanobot-webui 端口
# 18790: nanobot gateway 端口
EXPOSE 18780 18790


# 使用启动脚本作为默认命令
CMD ["/app/start.sh"]

