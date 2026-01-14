@echo off
REM Quick Start Script for WMPFDebugger + AI_JS_DEBUGGER Integration (Windows)
REM This script helps you set up the AI-powered miniapp reverse engineering environment

setlocal enabledelayedexpansion

echo ==========================================
echo WMPFDebugger + AI_JS_DEBUGGER Integration
echo ==========================================
echo.

REM Check if we're in the WMPFDebugger directory
if not exist package.json (
    echo Error: package.json not found. This script must be run from the WMPFDebugger directory
    exit /b 1
)
findstr /C:"\"name\"" /C:"WMPFDebugger" package.json >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Not in WMPFDebugger directory. This script must be run from the WMPFDebugger directory
    exit /b 1
)

set WMPF_DIR=%CD%
set AI_DEBUGGER_DIR=..\AI_JS_DEBUGGER

echo WMPFDebugger directory: %WMPF_DIR%
echo AI_JS_DEBUGGER directory: %AI_DEBUGGER_DIR%
echo.

REM Check if AI_JS_DEBUGGER is cloned
if not exist "%AI_DEBUGGER_DIR%" (
    echo AI_JS_DEBUGGER not found. Cloning...
    cd ..
    git clone https://github.com/Valerian7/AI_JS_DEBUGGER.git
    cd "%WMPF_DIR%"
    echo [OK] AI_JS_DEBUGGER cloned successfully
) else (
    echo [OK] AI_JS_DEBUGGER directory found
)

REM Check Node.js installation
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed. Please install Node.js (LTS v22+)
    exit /b 1
)
for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [OK] Node.js found: %NODE_VERSION%

REM Check Python installation
REM Note: On Windows, 'python' is the standard command (not 'python3')
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Python is not installed. Please install Python 3.11+
    exit /b 1
)
for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo [OK] Python found: %PYTHON_VERSION%

REM Check Python version (3.11+)
REM Extract major and minor version from "Python 3.11.x" format
for /f "tokens=2 delims= " %%a in ('python --version 2^>^&1') do (
    for /f "tokens=1,2 delims=." %%b in ("%%a") do (
        set PY_MAJOR=%%b
        set PY_MINOR=%%c
    )
)
if defined PY_MAJOR if defined PY_MINOR (
    if %PY_MAJOR% LSS 3 (
        echo [!] Warning: Python 3.11+ is recommended. Current version: %PYTHON_VERSION%
    ) else if %PY_MAJOR% EQU 3 if %PY_MINOR% LSS 11 (
        echo [!] Warning: Python 3.11+ is recommended. Current version: %PYTHON_VERSION%
    )
)

REM Check yarn installation
where yarn >nul 2>nul
if %errorlevel% neq 0 (
    echo Warning: yarn is not installed. Installing yarn...
    npm install -g yarn
)
echo [OK] Yarn found

echo.
echo Installing dependencies...
echo.

REM Install WMPFDebugger dependencies
echo Installing WMPFDebugger dependencies...
call yarn install
if %errorlevel% equ 0 (
    echo [OK] WMPFDebugger dependencies installed
) else (
    echo Error: Failed to install WMPFDebugger dependencies
    exit /b 1
)

REM Install AI_JS_DEBUGGER dependencies
if exist "%AI_DEBUGGER_DIR%\requirements.txt" (
    echo Installing AI_JS_DEBUGGER dependencies...
    cd "%AI_DEBUGGER_DIR%"
    python -m pip install -r requirements.txt
    cd "%WMPF_DIR%"
    echo [OK] AI_JS_DEBUGGER dependencies installed
) else (
    echo Warning: AI_JS_DEBUGGER requirements.txt not found
)

echo.
echo Copying example configuration...

REM Copy example config if AI_JS_DEBUGGER config doesn't exist
if not exist "%AI_DEBUGGER_DIR%\config.yaml" (
    if exist "ai_debugger_config.example.yaml" (
        copy ai_debugger_config.example.yaml "%AI_DEBUGGER_DIR%\config.yaml" >nul
        echo [OK] Configuration file copied to AI_JS_DEBUGGER\config.yaml
        echo [!] Please edit %AI_DEBUGGER_DIR%\config.yaml and set your AI API key
    ) else (
        echo Warning: Example config not found. Please configure AI_JS_DEBUGGER manually
    )
) else (
    echo [OK] AI_JS_DEBUGGER config.yaml already exists
)

echo.
echo ==========================================
echo Setup completed successfully!
echo ==========================================
echo.
echo Next steps:
echo 1. Edit %AI_DEBUGGER_DIR%\config.yaml and set your AI API key
echo 2. Start WMPFDebugger: npx ts-node src\index.ts
echo 3. Launch your target miniapp in WeChat
echo 4. Start AI_JS_DEBUGGER: cd %AI_DEBUGGER_DIR% ^&^& python run_flask.py
echo 5. Open http://localhost:5001 in your browser
echo.
echo For detailed instructions, see: AI_INTEGRATION.md
echo.

pause
