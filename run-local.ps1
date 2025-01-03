#!/usr/bin/env pwsh

# Stop on any error
$ErrorActionPreference = "Stop"

# Colors for output
$Colors = @{
    Cyan = [System.ConsoleColor]::Cyan
    Yellow = [System.ConsoleColor]::Yellow
    Red = [System.ConsoleColor]::Red
    Green = [System.ConsoleColor]::Green
}

function Write-ColorOutput($ForegroundColor, $Message) {
    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check for required tools
Write-ColorOutput $Colors.Cyan "🔍 Checking required tools..."

if (-not (Test-Command "pnpm")) {
    Write-ColorOutput $Colors.Yellow "Installing pnpm globally..."
    npm install -g pnpm
}

if (-not (Test-Command "python")) {
    Write-ColorOutput $Colors.Red "❌ Python is required but not found. Please install Python 3.12 or later."
    exit 1
}

# Function to start the frontend
function Start-Frontend {
    Write-ColorOutput $Colors.Cyan "🚀 Starting frontend development server..."
    Push-Location app/frontend
    try {
        # Install dependencies if needed
        if (-not (Test-Path "node_modules")) {
            Write-ColorOutput $Colors.Yellow "Installing frontend dependencies..."
            pnpm install
        }
        Start-Process pnpm -ArgumentList "run", "dev" -NoNewWindow
    } finally {
        Pop-Location
    }
}

# Function to start the backend
function Start-Backend {
    Write-ColorOutput $Colors.Cyan "🚀 Starting backend server..."
    Push-Location app/backend
    try {
        # Create and activate virtual environment if it doesn't exist
        if (-not (Test-Path ".venv")) {
            Write-ColorOutput $Colors.Yellow "Creating Python virtual environment..."
            python -m venv .venv
        }

        # Activate virtual environment
        . .\.venv\Scripts\Activate.ps1

        # Install dependencies if needed
        if (-not (Test-Path ".venv\Lib\site-packages\aiohttp")) {
            Write-ColorOutput $Colors.Yellow "Installing backend dependencies..."
            python -m pip install -r requirements.txt
            python -m pip install aiohttp-devtools
        }

        # Start the backend with auto-reload
        Write-ColorOutput $Colors.Green "Starting backend server with auto-reload..."
        adev runserver app.py --port 8000
    } finally {
        Pop-Location
    }
}

# Start both servers
try {
    # Start frontend in background
    Start-Frontend

    # Start backend in foreground
    Start-Backend
} catch {
    Write-ColorOutput $Colors.Red "❌ Error: $_"
    exit 1
}
