# nanobot 一体化部署镜像
# 从 Ubuntu 24.04 开始构建，包含 nanobot 和 nanobot-webui 功能
# 支持用户模式运行，避免 root 权限问题
# 从 Git 仓库直接克隆项目
FROM ubuntu:24.04

# 构建参数：用户 ID 和组 ID
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=nanobot
ARG GIT_PROXY=

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    PYTHONUNBUFFERED=1 \
    UV_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/ \
    NANOBOT_REPO=https://github.com/RisingWater/nanobot.git \
    NANOBOT_WEBUI_REPO=https://github.com/Good0007/nanobot-webui.git \
    HOME=/home/$USERNAME

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 更新 apt 源为阿里云镜像
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Bun (用于前端构建)
RUN PROXY_ADDR=$(echo $GIT_PROXY | cut -d'/' -f3) && \
    echo "提取的代理地址: $PROXY_ADDR" && \
    curl http://10.17.17.19:8083/api/public/dl/9sUKBg9h -o bun.zip && \
    unzip bun.zip -d /root/.bun && \
    rm bun.zip && \
    cp /root/.bun/bun-linux-x64/bun /usr/local/bin/bun && \
    chmod 777 /usr/local/bin/bun

# 创建工作目录并设置权限
RUN mkdir -p /app && chown -R $USER_ID:$GROUP_ID /app

RUN mkdir -p /home/$USERNAME && chown -R $USER_ID:$GROUP_ID /home/$USERNAME

# 切换到非 root 用户
USER $USER_ID
WORKDIR /app

RUN git config --global http.proxy $GIT_PROXY
RUN git config --global https.proxy $GIT_PROXY

# 从 Git 仓库克隆 nanobot 项目到 /app/nanobot
RUN git clone $NANOBOT_REPO /app/nanobot

# 从 Git 仓库克隆 nanobot-webui 项目到 /app/nanobot-webui
RUN git clone $NANOBOT_WEBUI_REPO /app/nanobot-webui

RUN git config --global --unset http.proxy
RUN git config --global --unset https.proxy

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
RUN ls -l /usr/local/bin/bun
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

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:18780/ || exit 1

# 设置默认命令：同时启动 nanobot-webui 和 nanobot gateway
# 注意：nanobot-webui 已经包含了 gateway 功能
CMD ["python", "-m", "webui", "--port", "18780", "--host", "0.0.0.0"]

# 可选：如果只需要 nanobot gateway，可以使用以下命令
# CMD ["nanobot", "gateway", "--port", "18790", "--host", "0.0.0.0"]