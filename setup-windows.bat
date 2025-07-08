@echo off
setlocal enabledelayedexpansion

rem Setup script for Eversense Companion on Windows
rem This script installs all dependencies required to build and run the project

echo =====================================================
echo Eversense Companion - Windows Setup Script
echo =====================================================
echo.

rem Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [INFO] Running with administrator privileges.
) else (
    echo [WARNING] Not running as administrator. Some installations may fail.
    echo [WARNING] Consider running this script as administrator.
    echo.
)

rem Check for winget (Windows Package Manager)
echo 1. Checking Windows Package Manager...
winget --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Windows Package Manager (winget) is available
    set USE_WINGET=1
) else (
    echo [WARNING] Windows Package Manager (winget) not found
    echo [INFO] Will provide manual installation instructions
    set USE_WINGET=0
)

rem Check for chocolatey
echo.
echo 2. Checking Chocolatey...
choco --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Chocolatey is available
    set USE_CHOCO=1
) else (
    echo [INFO] Chocolatey not found. Installing...
    echo [INFO] This requires administrator privileges.
    
    rem Install chocolatey
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    
    if !errorLevel! == 0 (
        echo [OK] Chocolatey installed successfully
        set USE_CHOCO=1
        rem Refresh environment variables
        call refreshenv
    ) else (
        echo [WARNING] Chocolatey installation failed
        set USE_CHOCO=0
    )
)

rem Install Git if not present
echo.
echo 3. Installing Git...
git --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Git is already installed
) else (
    echo [INFO] Installing Git...
    if !USE_WINGET! == 1 (
        winget install --id Git.Git -e --source winget
    ) else if !USE_CHOCO! == 1 (
        choco install git -y
    ) else (
        echo [MANUAL] Please download and install Git from: https://git-scm.com/download/win
        pause
    )
)

rem Install Node.js and npm
echo.
echo 4. Installing Node.js and npm...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js is already installed
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [INFO] Node.js version: !NODE_VERSION!
) else (
    echo [INFO] Installing Node.js...
    if !USE_WINGET! == 1 (
        winget install --id OpenJS.NodeJS -e --source winget
    ) else if !USE_CHOCO! == 1 (
        choco install nodejs -y
    ) else (
        echo [MANUAL] Please download and install Node.js from: https://nodejs.org/
        pause
    )
)

rem Verify npm
npm --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] npm is available
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo [INFO] npm version: !NPM_VERSION!
) else (
    echo [ERROR] npm not found. Please reinstall Node.js
)

rem Install Python
echo.
echo 5. Installing Python...
python --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Python is already installed
    for /f "tokens=*" %%i in ('python --version') do set PYTHON_VERSION=%%i
    echo [INFO] Python version: !PYTHON_VERSION!
) else (
    echo [INFO] Installing Python...
    if !USE_WINGET! == 1 (
        winget install --id Python.Python.3.11 -e --source winget
    ) else if !USE_CHOCO! == 1 (
        choco install python -y
    ) else (
        echo [MANUAL] Please download and install Python from: https://www.python.org/downloads/
        pause
    )
)

rem Install Python dependencies
echo.
echo 6. Installing Python dependencies...
pip --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] pip is available
    pip install requests
    if !errorLevel! == 0 (
        echo [OK] Python dependencies installed
    ) else (
        echo [ERROR] Failed to install Python dependencies
    )
) else (
    echo [ERROR] pip not found. Please ensure Python is properly installed
)

rem Install Java
echo.
echo 7. Installing Java...
java -version >nul 2>&1
if %errorLevel! == 0 (
    echo [OK] Java is already installed
    for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do set JAVA_VERSION=%%g
    echo [INFO] Java version: !JAVA_VERSION!
) else (
    echo [INFO] Installing Java...
    if !USE_WINGET! == 1 (
        winget install --id Eclipse.Temurin.11.JDK -e --source winget
    ) else if !USE_CHOCO! == 1 (
        choco install openjdk11 -y
    ) else (
        echo [MANUAL] Please download and install Java 11+ from: https://adoptium.net/
        pause
    )
)

rem Set JAVA_HOME if not set
if not defined JAVA_HOME (
    echo [INFO] Setting JAVA_HOME...
    for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\JDK" /s /v JavaHome 2^>nul ^| find "JavaHome"') do set JAVA_HOME=%%b
    if defined JAVA_HOME (
        echo [OK] JAVA_HOME set to: !JAVA_HOME!
    ) else (
        echo [WARNING] Could not automatically set JAVA_HOME
        echo [INFO] Please set JAVA_HOME manually to your Java installation directory
    )
)

rem Install browser dependencies
echo.
echo 8. Installing browser application dependencies...
if exist "browser\package.json" (
    echo [INFO] Installing browser dependencies...
    cd browser
    npm install
    if !errorLevel! == 0 (
        echo [OK] Browser dependencies installed
    ) else (
        echo [ERROR] Failed to install browser dependencies
    )
    cd ..
) else (
    echo [WARNING] Browser directory not found. Skipping browser dependencies.
)

rem Download Garmin Connect IQ SDK
echo.
echo 9. Setting up Garmin Connect IQ SDK...
set SDK_VERSION=4.2.4
set SDK_PATH=%USERPROFILE%\.garmin-sdk

if not exist "%SDK_PATH%" (
    echo [INFO] Creating SDK directory...
    mkdir "%SDK_PATH%"
)

if not exist "%SDK_PATH%\bin\monkeyc.exe" (
    echo [INFO] Downloading Connect IQ SDK v%SDK_VERSION%...
    
    rem Use PowerShell to download the SDK
    powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-win-%SDK_VERSION%.zip' -OutFile '%TEMP%\connectiq-sdk.zip'}"
    
    if exist "%TEMP%\connectiq-sdk.zip" (
        echo [INFO] Extracting SDK...
        powershell -Command "Expand-Archive -Path '%TEMP%\connectiq-sdk.zip' -DestinationPath '%SDK_PATH%' -Force"
        del "%TEMP%\connectiq-sdk.zip"
        echo [OK] Connect IQ SDK installed to %SDK_PATH%
    ) else (
        echo [ERROR] Failed to download SDK
        echo [MANUAL] Please download SDK manually from: https://developer.garmin.com/connect-iq/sdk/
    )
) else (
    echo [OK] Connect IQ SDK already exists at %SDK_PATH%
)

rem Configure environment variables
echo.
echo 10. Configuring environment variables...

rem Add CIQ_SDK_PATH to user environment
setx CIQ_SDK_PATH "%SDK_PATH%" >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] CIQ_SDK_PATH environment variable set
) else (
    echo [WARNING] Failed to set CIQ_SDK_PATH environment variable
)

rem Add SDK bin to PATH
echo %PATH% | find /i "%SDK_PATH%\bin" >nul
if %errorLevel% neq 0 (
    setx PATH "%PATH%;%SDK_PATH%\bin" >nul 2>&1
    if !errorLevel! == 0 (
        echo [OK] SDK bin directory added to PATH
    ) else (
        echo [WARNING] Failed to add SDK bin to PATH
    )
) else (
    echo [OK] SDK bin directory already in PATH
)

echo.
echo =====================================================
echo Setup Complete!
echo =====================================================
echo.
echo [OK] All dependencies have been installed successfully!
echo.
echo Environment setup:
if defined JAVA_HOME (
    echo   JAVA_HOME: %JAVA_HOME%
)
echo   CIQ_SDK_PATH: %SDK_PATH%
echo.
echo Next steps:
echo   1. Restart your command prompt to refresh environment variables
echo   2. Test the setup by running:
echo      cd browser ^&^& npm run dev    # Start browser app
echo      cd garmin ^&^& build.sh         # Build Garmin app (in Git Bash)
echo      python eversense_client.py --help  # Test Python client
echo.
echo For more information, see:
echo   - Browser app: browser\README.md
echo   - Garmin app: garmin\DEVELOPMENT.md
echo.
echo Note: You may need to restart your terminal or command prompt
echo       for all environment variables to take effect.
echo.

pause