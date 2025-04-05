# Requires -RunAsAdministrator

# Enable error handling
$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Windows build process..."

# Check for Python 3.11
try {
    $pythonVersion = python -V 2>&1
    if (-not ($pythonVersion -like "*3.11*")) {
        Write-Host "Python 3.11 not found. Please install Python 3.11 from https://www.python.org/downloads/"
        Write-Host "Make sure to check 'Add Python to PATH' during installation."
        exit 1
    }
} catch {
    Write-Host "Python not found. Please install Python 3.11 from https://www.python.org/downloads/"
    Write-Host "Make sure to check 'Add Python to PATH' during installation."
    exit 1
}

# Check for Visual C++ Build Tools
try {
    cl 2>&1 | Out-Null
} catch {
    Write-Host "Visual C++ Build Tools not found."
    Write-Host "Please install Visual Studio Build Tools from:"
    Write-Host "https://visualstudio.microsoft.com/visual-cpp-build-tools/"
    Write-Host "Make sure to select 'Desktop development with C++' workload."
    exit 1
}

# Create and activate virtual environment
Write-Host "Creating Python virtual environment..."
python -m venv venv
.\venv\Scripts\Activate.ps1

# Upgrade pip and install poetry
Write-Host "Installing dependencies..."
python -m pip install --upgrade pip
pip install poetry

# Install project dependencies
Write-Host "Installing project dependencies..."
poetry install

# Create environment file if it doesn't exist
if (-not (Test-Path .env)) {
    Write-Host "Creating .env file..."
    Copy-Item .env.example .env
    Write-Host "⚠️  Please edit .env file with your API keys"
}

# Run validation
Write-Host "Running validation..."
python scripts\validate.py

Write-Host "✨ Build process complete!"
Write-Host "To activate the environment, run: .\venv\Scripts\Activate.ps1" 