@echo off
setlocal enabledelayedexpansion

chcp 65001

echo ========================================
echo Start nanobot webui
echo ========================================

:: Get script directory
set DEPLOY_DIR=%~dp0
if "%DEPLOY_DIR:~-1%"=="\" set DEPLOY_DIR=%DEPLOY_DIR:~0,-1%
set VENV_DIR=%DEPLOY_DIR%\venv

:: Check if virtual environment exists
if not exist "%VENV_DIR%\Scripts\activate.bat" (
     echo Error: Virtual environment does not exist
     echo Please run deploy_nanobot.bat first for deployment
    pause
    exit /b 1
)

:: Start nanobot webui
     echo Starting nanobot webui...
start "nanobot-webui" cmd /k "call "%VENV_DIR%\Scripts\activate.bat" && nanobot webui"

echo.
echo nanobot webui started!
echo Access address: http://localhost:18780
echo Default username: admin
echo Default password: nanobot
echo.
echo Please change password immediately after first login!
echo.
echo Press any key to close this window...
pause