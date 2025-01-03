#!/usr/bin/env pwsh

# Stop on any error
$ErrorActionPreference = "Stop"

# Find Python command
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    # fallback to python3 if python not found
    $pythonCmd = Get-Command python3 -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        Write-Host "❌ Python is required but not found. Please install Python 3.12 or later." -ForegroundColor Red
        exit 1
    }
}

# Remove existing venv if it exists
if (Test-Path ".venv") {
    Write-Host "Removing existing virtual environment..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force .venv
}

Write-Host 'Creating Python virtual environment ".venv"...' -ForegroundColor Cyan
& $pythonCmd.Source -m venv .venv

# Determine the Python path based on OS
$venvPythonPath = "./.venv/scripts/python.exe"
if (Test-Path "/usr") {
    # fallback to Linux venv path
    $venvPythonPath = "./.venv/bin/python"
}

# Activate virtual environment
if ($IsWindows) {
    & ./.venv/Scripts/Activate.ps1
} else {
    & ./.venv/bin/Activate.ps1
}

# Upgrade pip
Write-Host "Upgrading pip..." -ForegroundColor Yellow
& $venvPythonPath -m pip install --upgrade pip

Write-Host 'Installing dependencies from "requirements.txt"...' -ForegroundColor Cyan
& $venvPythonPath -m pip install -r app/backend/requirements.txt

# Install development tools
Write-Host "Installing development dependencies..." -ForegroundColor Yellow
& $venvPythonPath -m pip install gunicorn aiohttp-devtools pytest pytest-asyncio pytest-cov black flake8 mypy

Write-Host "✅ Python environment setup completed!" -ForegroundColor Green