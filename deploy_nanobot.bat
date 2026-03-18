@echo off
setlocal enabledelayedexpansion

chcp 65001

echo ========================================
echo nanobot 部署脚本
echo ========================================

:: 获取脚本所在目录作为部署目录
set DEPLOY_DIR=%~dp0
:: 移除末尾的反斜杠
if "%DEPLOY_DIR:~-1%"=="\" set DEPLOY_DIR=%DEPLOY_DIR:~0,-1%

echo "部署目录: %DEPLOY_DIR%"

:: 设置变量
set NANOBOT_REPO=https://github.com/HKUDS/nanobot.git
set WEBUI_REPO=https://github.com/Good0007/nanobot-webui.git
set VENV_DIR=%DEPLOY_DIR%\venv
set BUN_DIR=%DEPLOY_DIR%\bun-windows-x64
set NANOBOT_DIR=%DEPLOY_DIR%\nanobot
set WEBUI_DIR=%DEPLOY_DIR%\nanobot-webui
set START_SCRIPT=%DEPLOY_DIR%\start_nanobot.bat

echo.
echo 步骤1: 检查并创建目录结构
if not exist "%DEPLOY_DIR%" (
    echo 创建部署目录: %DEPLOY_DIR%
    mkdir "%DEPLOY_DIR%"
)

echo.
echo 步骤2: 克隆或更新 nanobot 代码库
if exist "%NANOBOT_DIR%" (
    echo nanobot 目录已存在，更新代码...
    cd /d "%NANOBOT_DIR%"
    git pull
) else (
    echo 克隆 nanobot 代码库...
    git clone --depth 1 "%NANOBOT_REPO%" "%NANOBOT_DIR%"
)

echo.
echo 步骤3: 克隆或更新 webui 代码库
if exist "%WEBUI_DIR%" (
    echo webui 目录已存在，更新代码...
    cd /d "%WEBUI_DIR%"
    git pull
) else (
    echo 克隆 webui 代码库...
    git clone --depth 1 "%WEBUI_REPO%" "%WEBUI_DIR%"
)

echo.
echo 步骤4: 创建虚拟环境
if exist "%VENV_DIR%\Scripts\python.exe" (
    echo 虚拟环境已存在
) else (
    echo 创建虚拟环境...
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
        echo 错误: 创建虚拟环境失败
        echo 请确保已安装 Python 3.7+
        pause
        exit /b 1
    )
)

echo.
echo 步骤5: 安装或升级 nanobot
echo 激活虚拟环境并安装 nanobot...
call "%VENV_DIR%\Scripts\activate.bat"
python -m pip install --upgrade pip -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
cd /d "%NANOBOT_DIR%"

:: 检查是否已安装 nanobot
pip show nanobot-ai >nul 2>&1
if errorlevel 1 (
    echo 安装 nanobot...
    pip install -e . -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
) 

echo.
echo 步骤6: 安装或升级 webui
echo 安装 webui...
cd /d "%WEBUI_DIR%"
pip show nanobot-webui >nul 2>&1
if errorlevel 1 (
    echo 安装 nanobot-webui...
    pip install -e . -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
)

:: 安装额外依赖
echo.
echo 安装额外依赖...
pip show requests >nul 2>&1
if errorlevel 1 (
    pip install requests 
)

pip show pillow >nul 2>&1
if errorlevel 1 (
    pip install pillow 
)

echo.
echo "步骤7：下载bun..."
if not exist "%BUN_DIR%\bun.exe" (
    if not exist "%DEPLOY_DIR%\bun-windows-x64.zip" (
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/oven-sh/bun/releases/latest/download/bun-windows-x64.zip' -OutFile %DEPLOY_DIR%\bun-windows-x64.zip"
        if %errorlevel% neq 0 (
            echo "❌ 下载失败，请检查网络连接"
            echo "你可以手动下载：https://github.com/oven-sh/bun/releases/latest/bun-windows-x64.zip"
            pause
            exit /b 1
        )
        echo "✅ Bun 下载成功"
    )

    if exist "%DEPLOY_DIR%\bun-windows-x64.zip" (
        echo "步骤7：解压 Bun..."
        powershell -Command "Expand-Archive -Path %DEPLOY_DIR%\bun-windows-x64.zip -DestinationPath %DEPLOY_DIR% -Force"
        if %errorlevel% neq 0 (
            echo "❌ 解压失败"
            pause
            exit /b 1
        )
        echo "✅ Bun 解压成功"
    ) 
)

:: 步骤8：检查 dist 目录
echo.
echo 步骤8：检查生成的 dist 目录...
if not exist "%WEBUI_DIR%\webui\web\dist" (
    echo ❌ dist 目录不存在，构建可能未生成文件
    cd /d "%WEBUI_DIR%\web"
    "%BUN_DIR%\bun.exe" install
    "%BUN_DIR%\bun.exe" run build
    xcopy "%WEBUI_DIR%\web\dist" "%WEBUI_DIR%\webui\web\dist" /e /i /h /y >nul
)

echo.
echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 部署目录: %DEPLOY_DIR%
echo nanobot 目录: %NANOBOT_DIR%
echo webui 目录: %WEBUI_DIR%
echo 虚拟环境: %VENV_DIR%
echo 启动脚本: %START_SCRIPT%
echo.
echo 重要信息:
echo 1. nanobot 和 webui 都以可编辑模式安装，支持代码热更新
echo 2. 使用 'nanobot webui' 命令启动 web 界面
echo 3. 默认访问地址: http://localhost:18780
echo 4. 默认账号密码: admin / nanobot (首次登录后请立即修改)
echo.
echo 配置方式:
echo 1. 启动 webui 后访问 http://localhost:18780
echo 2. 使用 admin/nanobot 登录
echo 3. 进入 Settings -> Providers 配置 API 密钥
echo 4. 进入 Settings -> Agent Settings 配置其他参数
echo.
echo 下一步:
echo 运行 %START_SCRIPT% 启动 nanobot webui
echo.
pause