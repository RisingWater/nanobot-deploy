@echo off
setlocal enabledelayedexpansion

chcp 65001

echo ========================================
echo nanobot deployment script
echo ========================================

:: Get script directory as deployment directory
set DEPLOY_DIR=%~dp0
:: Remove trailing backslash
if "%DEPLOY_DIR:~-1%"=="\" set DEPLOY_DIR=%DEPLOY_DIR:~0,-1%

echo "Deployment directory: %DEPLOY_DIR%"

:: Set variables
set NANOBOT_REPO=https://github.com/HKUDS/nanobot.git
set WEBUI_REPO=https://github.com/Good0007/nanobot-webui.git
set VENV_DIR=%DEPLOY_DIR%\venv
set BUN_DIR=%DEPLOY_DIR%\bun-windows-x64
set NANOBOT_DIR=%DEPLOY_DIR%\nanobot
set WEBUI_DIR=%DEPLOY_DIR%\nanobot-webui
set START_SCRIPT=%DEPLOY_DIR%\start_nanobot.bat

echo.
echo Step 1: Check and create directory structure
if not exist "%DEPLOY_DIR%" (
     echo Create deployment directory: %DEPLOY_DIR%
    mkdir "%DEPLOY_DIR%"
)

echo.
echo Step 2: Clone or update nanobot repository
if exist "%NANOBOT_DIR%" (
     echo nanobot directory exists, updating code...
    cd /d "%NANOBOT_DIR%"
    git pull
) else (
     echo Cloning nanobot repository...
    git clone --depth 1 "%NANOBOT_REPO%" "%NANOBOT_DIR%"
)

echo.
echo Step 3: Clone or update webui repository
if exist "%WEBUI_DIR%" (
     echo webui directory exists, updating code...
    cd /d "%WEBUI_DIR%"
    git pull
) else (
     echo Cloning webui repository...
    git clone --depth 1 "%WEBUI_REPO%" "%WEBUI_DIR%"
)

echo.
echo Step 4: Create virtual environment
if exist "%VENV_DIR%\Scripts\python.exe" (
     echo Virtual environment already exists
) else (
     echo Creating virtual environment...
    python -m venv "%VENV_DIR%"
    if errorlevel 1 (
         echo Error: Failed to create virtual environment
         echo Please ensure Python 3.7+ is installed
        pause
        exit /b 1
    )
)

echo.
echo Step 5: Install or upgrade nanobot
echo Activating virtual environment and installing nanobot...
call "%VENV_DIR%\Scripts\activate.bat"
python -m pip install --upgrade pip -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
cd /d "%NANOBOT_DIR%"

:: Check if nanobot is already installed
pip show nanobot-ai >nul 2>&1
if errorlevel 1 (
     echo Installing nanobot...
    pip install -e . -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
) 

echo.
echo Step 6: Install or upgrade webui
echo Installing webui...
cd /d "%WEBUI_DIR%"
pip show nanobot-webui >nul 2>&1
if errorlevel 1 (
     echo Installing nanobot-webui...
    pip install -e . -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com
)

:: Install additional dependencies
echo.
echo Installing additional dependencies...
pip show requests >nul 2>&1
if errorlevel 1 (
    pip install requests 
)

pip show pillow >nul 2>&1
if errorlevel 1 (
    pip install pillow 
)

echo.
echo "Step 7: Download bun..."
if not exist "%BUN_DIR%\bun.exe" (
    if not exist "%DEPLOY_DIR%\bun-windows-x64.zip" (
        powershell -Command "Invoke-WebRequest -Uri 'https://github.com/oven-sh/bun/releases/latest/download/bun-windows-x64.zip' -OutFile %DEPLOY_DIR%\bun-windows-x64.zip"
        if %errorlevel% neq 0 (
             echo "❌ Download failed, please check network connection"
             echo "You can manually download: https://github.com/oven-sh/bun/releases/latest/bun-windows-x64.zip"
            pause
            exit /b 1
        )
         echo "✅ Bun downloaded successfully"
    )

    if exist "%DEPLOY_DIR%\bun-windows-x64.zip" (
         echo "Step 7: Extracting Bun..."
        powershell -Command "Expand-Archive -Path %DEPLOY_DIR%\bun-windows-x64.zip -DestinationPath %DEPLOY_DIR% -Force"
        if %errorlevel% neq 0 (
             echo "❌ Extraction failed"
            pause
            exit /b 1
        )
         echo "✅ Bun extracted successfully"
    ) 
)

:: Step 8: Check dist directory
echo.
echo Step 8: Checking generated dist directory...
if not exist "%WEBUI_DIR%\webui\web\dist" (
     echo ❌ dist directory does not exist, build may not have generated files
    cd /d "%WEBUI_DIR%\web"
    "%BUN_DIR%\bun.exe" install
    "%BUN_DIR%\bun.exe" run build
    xcopy "%WEBUI_DIR%\web\dist" "%WEBUI_DIR%\webui\web\dist" /e /i /h /y >nul
)

echo.
echo ========================================
echo Deployment completed!
echo ========================================
echo.
echo Deployment directory: %DEPLOY_DIR%
echo nanobot directory: %NANOBOT_DIR%
echo webui directory: %WEBUI_DIR%
echo Virtual environment: %VENV_DIR%
echo Startup script: %START_SCRIPT%
echo.
echo Important information:
echo 1. nanobot and webui are installed in editable mode, supporting hot code updates
echo 2. Use 'nanobot webui' command to start web interface
echo 3. Default access address: http://localhost:18780
echo 4. Default username/password: admin / nanobot (change immediately after first login)
echo.
echo Configuration steps:
echo 1. After starting webui, access http://localhost:18780
echo 2. Login with admin/nanobot
echo 3. Go to Settings -> Providers to configure API keys
echo 4. Go to Settings -> Agent Settings to configure other parameters
echo.
echo Next step:
echo Run %START_SCRIPT% to start nanobot webui
echo.
pause