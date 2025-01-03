#!/usr/bin/env pwsh

# Stop on any error
$ErrorActionPreference = "Stop"

# Source the Python environment setup
. ./scripts/load_python_env.ps1

Write-Host "📦 Setting up frontend..." -ForegroundColor Cyan
Push-Location app/frontend

# Check if pnpm is installed
if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    Write-Host "Installing pnpm globally..." -ForegroundColor Yellow
    npm install -g pnpm
}

try {
    Write-Host "Installing frontend dependencies..." -ForegroundColor Cyan
    pnpm install
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install frontend dependencies"
    }

    Write-Host "Building frontend..." -ForegroundColor Cyan
    pnpm run build
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build frontend"
    }

    Write-Host "🚀 Starting development servers..." -ForegroundColor Cyan

    # Start frontend dev server in background
    Write-Host "Starting frontend development server..." -ForegroundColor Yellow
    $frontendJob = Start-Job -ScriptBlock {
        Set-Location $using:PWD
        pnpm run dev
    }

    # Start backend in development mode
    Write-Host "Starting backend development server..." -ForegroundColor Yellow
    Push-Location ../backend
    try {
        adev runserver app.py --port 8000
    } finally {
        Pop-Location
    }
} finally {
    # Cleanup
    if ($frontendJob) {
        Stop-Job -Job $frontendJob
        Remove-Job -Job $frontendJob
    }
    Pop-Location
}
