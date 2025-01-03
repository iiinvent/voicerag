#!/usr/bin/env pwsh

# Stop on any error
$ErrorActionPreference = "Stop"

Write-Host "Starting build process..." -ForegroundColor Cyan

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check for required tools
if (-not (Test-Command "pnpm")) {
    Write-Host "Installing pnpm globally..." -ForegroundColor Yellow
    npm install -g pnpm
}

if (-not (Test-Command "python")) {
    Write-Host "X Python is required but not found. Please install Python 3.12 or later." -ForegroundColor Red
    exit 1
}

# Build frontend
Write-Host "Building frontend..." -ForegroundColor Cyan
Push-Location app/frontend
try {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
    pnpm install

    Write-Host "Building frontend assets..." -ForegroundColor Yellow
    pnpm run build

    if (-not $?) {
        throw "Frontend build failed"
    }
} finally {
    Pop-Location
}

# Setup backend
Write-Host "Setting up backend..." -ForegroundColor Cyan
Push-Location app/backend
try {
    # Remove existing virtual environment if it exists
    if (Test-Path ".venv") {
        Write-Host "Removing existing virtual environment..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force .venv
    }

    Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
    python -m venv .venv
    
    # Activate virtual environment
    .\.venv\Scripts\Activate.ps1

    # Upgrade pip
    Write-Host "Upgrading pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip

    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    python -m pip install -r requirements.txt

    # Install development dependencies
    Write-Host "Installing development dependencies..." -ForegroundColor Yellow
    python -m pip install gunicorn aiohttp-devtools pytest pytest-asyncio pytest-cov black flake8 mypy

    if (-not $?) {
        throw "Backend setup failed"
    }
} finally {
    Pop-Location
}

Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host @"

To run the application:
1. Activate the virtual environment:
   cd app/backend
   .\.venv\Scripts\Activate.ps1

2. Start the server in development mode:
   adev runserver app.py --port 8000

   Or in production mode:
   gunicorn app:create_app -b 0.0.0.0:8000 --worker-class aiohttp.GunicornWebWorker

The application will be available at http://localhost:8000
"@ -ForegroundColor Cyan
