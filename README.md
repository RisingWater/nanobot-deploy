# nanobot 部署方案

本目录包含 nanobot 的 Windows 和 Linux 部署方案。

## Windows 部署方案

### 文件说明

1. **deploy_nanobot.bat** - 主部署脚本
   - 克隆 nanobot 官方代码库 (HKUDS/nanobot)
   - 克隆 webui 代码库 (Good0007/nanobot-webui)
   - 创建虚拟环境
   - 以可编辑模式安装 nanobot 和 webui（支持热更新）
   - 下载bun
   - 编译前端

2. **start_nanobot.bat** - 启动脚本
   - 启动 nanobot webui 服务

### 使用步骤

#### 首次部署

1. 确保已安装：
   - Git
   - Python 3.7+

2. 运行部署脚本：
   ```
   cd D:\wangxu\work\nanobot_deploy
   deploy_nanobot.bat
   ```

#### 启动服务

运行启动脚本：
```
start_nanobot.bat
```

服务启动后访问：http://localhost:18780

默认登录信息：
- 用户名：admin
- 密码：nanobot

**重要**：首次登录后请立即修改密码！

#### 配置 nanobot

通过 webui 进行配置：
1. 登录后进入 **Settings** 页面
2. 在 **Providers** 选项卡配置 API 密钥
3. 在 **Agent Settings** 配置其他参数

#### 更新 nanobot 和 webui

再次运行部署脚本即可更新：
```
deploy_nanobot.bat
```

### 目录结构

部署完成后，目录结构如下：
```
D:\wangxu\work\nanobot_deploy\
├── nanobot\          # nanobot 官方代码 (HKUDS/nanobot)
├── nanobot-webui\    # webui 代码 (Good0007/nanobot-webui)
├── venv\             # Python 虚拟环境
├── deploy_nanobot.bat
├── start_nanobot.bat
└── README.md
```

### 脚本特点

1. **便携性**：使用脚本所在目录作为部署目录，无需硬编码路径
2. **幂等性**：可以多次运行，不会重复创建已存在的资源
3. **自动更新**：如果项目已存在，会自动更新到最新版本
4. **热更新支持**：使用 `-e` 参数安装，代码修改后无需重新安装
5. **webui 配置**：通过 webui 界面进行配置，无需手动编辑配置文件

### 注意事项

1. 确保网络连接正常，脚本需要从 GitHub 克隆代码
2. 首次登录 webui 后请立即修改默认密码
3. 如果部署失败，可以删除目录重新运行脚本
4. webui 默认端口为 18780，可以通过 `nanobot webui --port 端口号` 修改
5. nanobot 和 webui 都以可编辑模式安装，支持代码热更新

## Linux Docker 部署方案

### 功能特点

- ✅ 基于 Ubuntu 22.04 构建
- ✅ 包含 nanobot 和 nanobot-webui 功能
- ✅ 用户模式运行（非 root），避免权限问题
- ✅ 支持自定义 UID/GID
- ✅ 从 Git 仓库直接克隆项目
- ✅ 健康检查支持
- ✅ 简化版：不需要 WhatsApp bridge

### 快速开始

#### 前提条件

1. 安装 Docker: https://docs.docker.com/engine/install/
2. 确保 Docker 服务正在运行

#### 构建镜像

```bash
# 进入项目目录
cd /path/to/nanobot_deploy

# 基本构建（使用默认 UID/GID=1000）
docker build -t nanobot-all-in-one .

# 指定用户 ID 和组 ID（推荐）
docker build \
  --build-arg USER_ID=$(id -u) \
  --build-arg GROUP_ID=$(id -g) \
  -t nanobot-all-in-one .
```

#### 运行容器

```bash
# 获取当前用户 ID 和组 ID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# 运行容器（使用当前用户的 UID/GID）
docker run -d \
  --name nanobot \
  -p 18780:18780 \
  -p 18790:18790 \
  -v $HOME/.nanobot:/home/nanobot/.nanobot \
  -e TZ=Asia/Shanghai \
  --user $USER_ID:$GROUP_ID \
  nanobot-all-in-one

# 简化的运行命令
docker run -d --name nanobot -p 18780:18780 -p 18790:18790 -v $HOME/.nanobot:/home/nanobot/.nanobot nanobot-all-in-one
```

#### 查看容器状态

```bash
# 查看运行中的容器
docker ps

# 查看容器日志
docker logs nanobot

# 实时查看日志
docker logs -f nanobot
```

## 访问服务

- **WebUI 管理界面**: http://localhost:18780
- **Gateway API**: http://localhost:18790

## 配置文件

配置文件位于 `~/.nanobot/config.json`，首次启动时会自动生成默认配置。

### 自定义配置

1. 停止容器：
```bash
docker stop nanobot
```

2. 编辑配置文件：
```bash
# Linux/Mac
vim ~/.nanobot/config.json

# Windows
notepad %USERPROFILE%\.nanobot\config.json
```

3. 重新启动容器：
```bash
docker start nanobot
```

## 构建参数说明

Dockerfile 支持以下构建参数：

| 参数名 | 说明 | 默认值 |
|--------|------|--------|
| `USER_ID` | 用户 ID | `1000` |
| `GROUP_ID` | 组 ID | `1000` |
| `USERNAME` | 用户名 | `nanobot` |

### 为什么需要指定 UID/GID？

在 Docker 容器中，如果以 root 用户运行 nanobot，创建的文件在宿主机上会属于 root，导致普通用户无法读取。通过指定与宿主机用户相同的 UID/GID，可以确保容器内创建的文件在宿主机上有正确的权限。

## 数据持久化

- 配置文件：`~/.nanobot/config.json`
- 工作空间：`~/.nanobot/workspace/`
- 记忆文件：`~/.nanobot/workspace/memory/`

这些目录已通过 Docker 卷挂载，数据会持久化保存。

## 管理容器

### 停止容器
```bash
docker stop nanobot
```

### 启动容器
```bash
docker start nanobot
```

### 重启容器
```bash
docker restart nanobot
```

### 删除容器
```bash
# 停止并删除容器
docker stop nanobot && docker rm nanobot

# 删除镜像
docker rmi nanobot-all-in-one
```

### 进入容器（调试）
```bash
docker exec -it --user root nanobot bash
```

## 故障排除

### 1. 端口冲突

如果端口 18780 或 18790 已被占用，可以修改端口映射：

```bash
# 修改外部端口
docker run -d --name nanobot -p 18880:18780 -p 18890:18790 -v $HOME/.nanobot:/home/nanobot/.nanobot nanobot-all-in-one
```

### 2. 权限问题

如果遇到权限问题，确保使用正确的 UID/GID：

```bash
# 查看当前用户的 UID/GID
id -u
id -g

# 使用正确的 UID/GID 构建
docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) -t nanobot-all-in-one .
```

### 3. 构建失败

如果构建过程中下载依赖失败，可以尝试：

1. 检查网络连接
2. 修改镜像源（已在 Dockerfile 中配置为国内镜像源）
3. 清理缓存后重试：
```bash
docker build --no-cache -t nanobot-all-in-one .
```

### 4. 容器启动失败

查看详细日志：
```bash
docker logs nanobot
```

### 5. 健康检查失败

等待容器完全启动（首次启动可能需要较长时间下载依赖）。

## Dockerfile 说明

这个 Dockerfile 的特点：

1. **基于 Ubuntu 22.04**：稳定的基础镜像
2. **用户模式运行**：创建非 root 用户，避免权限问题
3. **可配置 UID/GID**：支持通过构建参数传入用户 ID 和组 ID
4. **国内镜像源优化**：使用阿里云镜像加速下载
5. **从 Git 克隆**：直接从 GitHub 仓库克隆项目，不需要本地文件
7. **完整功能**：包含 nanobot 和 nanobot-webui 所有功能
8. **健康检查**：自动监控服务状态

### Git 仓库配置
- **nanobot**: https://github.com/RisingWater/nanobot.git
- **nanobot-webui**: https://github.com/Good0007/nanobot-webui.git

## 许可证

MIT License