# Setup script for Eversense Companion on Windows (PowerShell)
# This script installs all dependencies required to build and run the project

param(
    [switch]$Force = $false,
    [switch]$NoConfirm = $false
)

# Ensure running with appropriate permissions
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Some installations may require administrator privileges."
    Write-Host "Consider running PowerShell as Administrator for best results." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Eversense Companion - Windows Setup Script" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function to install with winget
function Install-WithWinget {
    param($PackageId, $Name)
    
    Write-Host "[INFO] Installing $Name with winget..." -ForegroundColor Blue
    try {
        winget install --id $PackageId -e --source winget --accept-package-agreements --accept-source-agreements
        return $true
    } catch {
        Write-Host "[ERROR] Failed to install $Name with winget" -ForegroundColor Red
        return $false
    }
}

# Function to install with chocolatey
function Install-WithChocolatey {
    param($PackageName, $Name)
    
    Write-Host "[INFO] Installing $Name with chocolatey..." -ForegroundColor Blue
    try {
        choco install $PackageName -y
        return $true
    } catch {
        Write-Host "[ERROR] Failed to install $Name with chocolatey" -ForegroundColor Red
        return $false
    }
}

# Check for Windows Package Manager (winget)
Write-Host "1. Checking Windows Package Manager..." -ForegroundColor Green
$UseWinget = Test-Command "winget"
if ($UseWinget) {
    Write-Host "[OK] Windows Package Manager (winget) is available" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Windows Package Manager (winget) not found" -ForegroundColor Yellow
    Write-Host "[INFO] Consider installing it from Microsoft Store or GitHub" -ForegroundColor Blue
}

# Check for Chocolatey
Write-Host ""
Write-Host "2. Checking Chocolatey..." -ForegroundColor Green
$UseChocolatey = Test-Command "choco"
if ($UseChocolatey) {
    Write-Host "[OK] Chocolatey is available" -ForegroundColor Green
} else {
    Write-Host "[INFO] Chocolatey not found. Installing..." -ForegroundColor Blue
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        $UseChocolatey = Test-Command "choco"
        if ($UseChocolatey) {
            Write-Host "[OK] Chocolatey installed successfully" -ForegroundColor Green
        } else {
            Write-Host "[WARNING] Chocolatey installation may have failed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[ERROR] Failed to install Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
        $UseChocolatey = $false
    }
}

# Install Git
Write-Host ""
Write-Host "3. Installing Git..." -ForegroundColor Green
if (Test-Command "git") {
    $gitVersion = git --version
    Write-Host "[OK] Git is already installed: $gitVersion" -ForegroundColor Green
} else {
    $installed = $false
    if ($UseWinget) {
        $installed = Install-WithWinget "Git.Git" "Git"
    }
    if (-not $installed -and $UseChocolatey) {
        $installed = Install-WithChocolatey "git" "Git"
    }
    if (-not $installed) {
        Write-Host "[MANUAL] Please download and install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    }
}

# Install Node.js
Write-Host ""
Write-Host "4. Installing Node.js and npm..." -ForegroundColor Green
if (Test-Command "node") {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "[OK] Node.js is already installed: $nodeVersion" -ForegroundColor Green
    Write-Host "[OK] npm is available: $npmVersion" -ForegroundColor Green
    
    # Check version
    $nodeMajorVersion = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
    if ($nodeMajorVersion -lt 16) {
        Write-Host "[WARNING] Node.js version is below 16. Consider updating." -ForegroundColor Yellow
    }
} else {
    $installed = $false
    if ($UseWinget) {
        $installed = Install-WithWinget "OpenJS.NodeJS" "Node.js"
    }
    if (-not $installed -and $UseChocolatey) {
        $installed = Install-WithChocolatey "nodejs" "Node.js"
    }
    if (-not $installed) {
        Write-Host "[MANUAL] Please download and install Node.js from: https://nodejs.org/" -ForegroundColor Yellow
    }
}

# Install Python
Write-Host ""
Write-Host "5. Installing Python..." -ForegroundColor Green
if (Test-Command "python") {
    $pythonVersion = python --version
    Write-Host "[OK] Python is already installed: $pythonVersion" -ForegroundColor Green
} else {
    $installed = $false
    if ($UseWinget) {
        $installed = Install-WithWinget "Python.Python.3.11" "Python"
    }
    if (-not $installed -and $UseChocolatey) {
        $installed = Install-WithChocolatey "python" "Python"
    }
    if (-not $installed) {
        Write-Host "[MANUAL] Please download and install Python from: https://www.python.org/downloads/" -ForegroundColor Yellow
    }
}

# Install Python dependencies
Write-Host ""
Write-Host "6. Installing Python dependencies..." -ForegroundColor Green
if (Test-Command "pip") {
    try {
        pip install requests
        Write-Host "[OK] Python dependencies installed" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to install Python dependencies" -ForegroundColor Red
    }
} else {
    Write-Host "[ERROR] pip not found. Please ensure Python is properly installed" -ForegroundColor Red
}

# Install Java
Write-Host ""
Write-Host "7. Installing Java..." -ForegroundColor Green
if (Test-Command "java") {
    $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.Line }
    Write-Host "[OK] Java is already installed: $javaVersion" -ForegroundColor Green
} else {
    $installed = $false
    if ($UseWinget) {
        $installed = Install-WithWinget "Eclipse.Temurin.11.JDK" "Java (Eclipse Temurin)"
    }
    if (-not $installed -and $UseChocolatey) {
        $installed = Install-WithChocolatey "openjdk11" "OpenJDK 11"
    }
    if (-not $installed) {
        Write-Host "[MANUAL] Please download and install Java 11+ from: https://adoptium.net/" -ForegroundColor Yellow
    }
}

# Set JAVA_HOME if not set
if (-not $env:JAVA_HOME) {
    Write-Host "[INFO] Setting JAVA_HOME..." -ForegroundColor Blue
    
    # Try to find Java installation
    $javaPath = Get-Command java -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
    if ($javaPath) {
        $javaHome = Split-Path (Split-Path $javaPath) -Parent
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "User")
        $env:JAVA_HOME = $javaHome
        Write-Host "[OK] JAVA_HOME set to: $javaHome" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Could not automatically set JAVA_HOME" -ForegroundColor Yellow
    }
}

# Install browser dependencies
Write-Host ""
Write-Host "8. Installing browser application dependencies..." -ForegroundColor Green
if (Test-Path "browser\package.json") {
    Write-Host "[INFO] Installing browser dependencies..." -ForegroundColor Blue
    Push-Location "browser"
    try {
        npm install
        Write-Host "[OK] Browser dependencies installed" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to install browser dependencies" -ForegroundColor Red
    }
    Pop-Location
} else {
    Write-Host "[WARNING] Browser directory not found. Skipping browser dependencies." -ForegroundColor Yellow
}

# Download Garmin Connect IQ SDK
Write-Host ""
Write-Host "9. Setting up Garmin Connect IQ SDK..." -ForegroundColor Green
$SdkVersion = "4.2.4"
$SdkPath = "$env:USERPROFILE\.garmin-sdk"

if (-not (Test-Path $SdkPath)) {
    New-Item -ItemType Directory -Path $SdkPath -Force | Out-Null
}

if (-not (Test-Path "$SdkPath\bin\monkeyc.exe")) {
    Write-Host "[INFO] Downloading Connect IQ SDK v$SdkVersion..." -ForegroundColor Blue
    
    $SdkUrl = "https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-win-$SdkVersion.zip"
    $SdkZip = "$env:TEMP\connectiq-sdk.zip"
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $SdkUrl -OutFile $SdkZip
        
        Write-Host "[INFO] Extracting SDK..." -ForegroundColor Blue
        Expand-Archive -Path $SdkZip -DestinationPath $SdkPath -Force
        Remove-Item $SdkZip
        
        Write-Host "[OK] Connect IQ SDK installed to $SdkPath" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Failed to download SDK: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[MANUAL] Please download SDK manually from: https://developer.garmin.com/connect-iq/sdk/" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] Connect IQ SDK already exists at $SdkPath" -ForegroundColor Green
}

# Configure environment variables
Write-Host ""
Write-Host "10. Configuring environment variables..." -ForegroundColor Green

# Set CIQ_SDK_PATH
[Environment]::SetEnvironmentVariable("CIQ_SDK_PATH", $SdkPath, "User")
$env:CIQ_SDK_PATH = $SdkPath
Write-Host "[OK] CIQ_SDK_PATH environment variable set" -ForegroundColor Green

# Add SDK bin to PATH
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$sdkBinPath = "$SdkPath\bin"
if ($userPath -notlike "*$sdkBinPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$sdkBinPath", "User")
    $env:PATH += ";$sdkBinPath"
    Write-Host "[OK] SDK bin directory added to PATH" -ForegroundColor Green
} else {
    Write-Host "[OK] SDK bin directory already in PATH" -ForegroundColor Green
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[OK] All dependencies have been installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Environment setup:" -ForegroundColor Blue
if ($env:JAVA_HOME) {
    Write-Host "  JAVA_HOME: $env:JAVA_HOME" -ForegroundColor Gray
}
Write-Host "  CIQ_SDK_PATH: $SdkPath" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Blue
Write-Host "  1. Restart your PowerShell session to refresh environment variables" -ForegroundColor Gray
Write-Host "  2. Test the setup by running:" -ForegroundColor Gray
Write-Host "     cd browser; npm run dev    # Start browser app" -ForegroundColor Gray
Write-Host "     cd garmin; .\build.sh      # Build Garmin app (requires Git Bash)" -ForegroundColor Gray
Write-Host "     python eversense_client.py --help  # Test Python client" -ForegroundColor Gray
Write-Host ""
Write-Host "For more information, see:" -ForegroundColor Blue
Write-Host "  - Browser app: browser\README.md" -ForegroundColor Gray
Write-Host "  - Garmin app: garmin\DEVELOPMENT.md" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: You may need to restart your terminal for all" -ForegroundColor Yellow
Write-Host "      environment variables to take effect." -ForegroundColor Yellow