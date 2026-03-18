@echo off
setlocal enabledelayedexpansion

chcp 65001

echo ========================================
echo 启动 nanobot webui
echo ========================================

:: 获取脚本所在目录
set DEPLOY_DIR=%~dp0
if "%DEPLOY_DIR:~-1%"=="\" set DEPLOY_DIR=%DEPLOY_DIR:~0,-1%
set VENV_DIR=%DEPLOY_DIR%\venv

:: 检查虚拟环境是否存在
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo 错误: 虚拟环境不存在
    echo 请先运行 deploy_nanobot.bat 进行部署
    pause
    exit /b 1
)

:: 启动 nanobot webui
echo 启动 nanobot webui...
start "nanobot-webui" cmd /k "call "%VENV_DIR%\Scripts\activate.bat" && nanobot webui"

echo.
echo nanobot webui 已启动！
echo 访问地址: http://localhost:18780
echo 默认账号: admin
echo 默认密码: nanobot
echo.
echo 首次登录后请立即修改密码！
echo.
echo 按任意键关闭此窗口...
pause