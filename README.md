# nanobot 部署脚本

## 概述

这个目录包含 nanobot 的自动化部署脚本，可以一键部署 nanobot 和 webui。

## 文件说明

1. **deploy_nanobot.bat** - 主部署脚本
   - 克隆 nanobot 官方代码库 (HKUDS/nanobot)
   - 克隆 webui 代码库 (Good0007/nanobot-webui)
   - 创建虚拟环境
   - 以可编辑模式安装 nanobot 和 webui（支持热更新）
   - 创建启动脚本

2. **start_nanobot.bat** - 启动脚本
   - 启动 nanobot webui 服务

## 使用步骤

### 首次部署

1. 确保已安装：
   - Git
   - Python 3.7+

2. 运行部署脚本：
   ```
   cd D:\wangxu\work\nanobot_deploy
   deploy_nanobot.bat
   ```

### 启动服务

运行启动脚本：
```
start_nanobot.bat
```

服务启动后访问：http://localhost:18780

默认登录信息：
- 用户名：admin
- 密码：nanobot

**重要**：首次登录后请立即修改密码！

### 配置 nanobot

通过 webui 进行配置：
1. 登录后进入 **Settings** 页面
2. 在 **Providers** 选项卡配置 API 密钥
3. 在 **Agent Settings** 配置其他参数

### 更新 nanobot 和 webui

再次运行部署脚本即可更新：
```
deploy_nanobot.bat
```

## 目录结构

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

## 脚本特点

1. **便携性**：使用脚本所在目录作为部署目录，无需硬编码路径
2. **幂等性**：可以多次运行，不会重复创建已存在的资源
3. **自动更新**：如果项目已存在，会自动更新到最新版本
4. **热更新支持**：使用 `-e` 参数安装，代码修改后无需重新安装
5. **webui 配置**：通过 webui 界面进行配置，无需手动编辑配置文件

## 注意事项

1. 确保网络连接正常，脚本需要从 GitHub 克隆代码
2. 首次登录 webui 后请立即修改默认密码
3. 如果部署失败，可以删除目录重新运行脚本
4. webui 默认端口为 18780，可以通过 `nanobot webui --port 端口号` 修改
5. nanobot 和 webui 都以可编辑模式安装，支持代码热更新

## 手动启动方式

如果不想使用启动脚本，可以手动启动：
```bash
cd D:\wangxu\work\nanobot_deploy
call venv\Scripts\activate.bat
nanobot webui
```

## 常用命令

- `nanobot webui` - 启动 webui
- `nanobot webui --port 9090` - 指定端口启动
- `nanobot webui --daemon` - 后台运行
- `nanobot webui logs` - 查看日志
- `nanobot stop` - 停止服务
- `nanobot status` - 查看状态

## 开发模式

由于使用 `-e` 参数安装，你可以直接修改代码：
1. 修改 `nanobot` 或 `nanobot-webui` 目录中的代码
2. 重启服务即可生效（部分修改可能需要重启）