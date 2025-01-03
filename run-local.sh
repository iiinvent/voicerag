#!/bin/bash

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print with color
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
print_color "$CYAN" "🔍 Checking required tools..."

if ! command_exists pnpm; then
    print_color "$YELLOW" "Installing pnpm globally..."
    npm install -g pnpm
fi

if ! command_exists python3; then
    print_color "$RED" "❌ Python is required but not found. Please install Python 3.12 or later."
    exit 1
fi

# Function to start the frontend
start_frontend() {
    print_color "$CYAN" "🚀 Starting frontend development server..."
    cd app/frontend

    # Install dependencies if needed
    if [ ! -d "node_modules" ]; then
        print_color "$YELLOW" "Installing frontend dependencies..."
        pnpm install
    fi

    # Start the frontend server in the background
    pnpm run dev &
    FRONTEND_PID=$!
}

# Function to start the backend
start_backend() {
    print_color "$CYAN" "🚀 Starting backend server..."
    cd app/backend

    # Create and activate virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        print_color "$YELLOW" "Creating Python virtual environment..."
        python3 -m venv .venv
    fi

    # Activate virtual environment
    source .venv/bin/activate

    # Install dependencies if needed
    if ! python3 -c "import aiohttp" 2>/dev/null; then
        print_color "$YELLOW" "Installing backend dependencies..."
        python3 -m pip install -r requirements.txt
        python3 -m pip install aiohttp-devtools
    fi

    # Start the backend with auto-reload
    print_color "$GREEN" "Starting backend server with auto-reload..."
    adev runserver app.py --port 8000
}

# Function to cleanup background processes
cleanup() {
    print_color "$YELLOW" "Cleaning up..."
    kill $FRONTEND_PID 2>/dev/null || true
    exit 0
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Start both servers
(
    cd "$(dirname "$0")"
    start_frontend
    start_backend
)
