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
print_color "$CYAN" "🚀 Starting build process..."

# Check for pnpm
if ! command_exists pnpm; then
    print_color "$YELLOW" "Installing pnpm globally..."
    npm install -g pnpm
fi

# Check for python
if ! command_exists python3; then
    print_color "$RED" "❌ Python is required but not found. Please install Python 3.12 or later."
    exit 1
fi

# Build frontend
print_color "$CYAN" "📦 Building frontend..."
cd app/frontend || exit 1

print_color "$YELLOW" "Installing frontend dependencies..."
pnpm install

print_color "$YELLOW" "Building frontend assets..."
pnpm run build

# Return to root directory
cd ../..

# Setup backend
print_color "$CYAN" "🔧 Setting up backend..."
cd app/backend || exit 1

# Remove existing virtual environment if it exists
if [ -d ".venv" ]; then
    print_color "$YELLOW" "Removing existing virtual environment..."
    rm -rf .venv
fi

print_color "$YELLOW" "Creating Python virtual environment..."
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Upgrade pip
print_color "$YELLOW" "Upgrading pip..."
python3 -m pip install --upgrade pip

print_color "$YELLOW" "Installing backend dependencies..."
python3 -m pip install -r requirements.txt

# Install development dependencies
print_color "$YELLOW" "Installing development dependencies..."
python3 -m pip install gunicorn aiohttp-devtools pytest pytest-asyncio pytest-cov black flake8 mypy

# Return to root directory
cd ../..

print_color "$GREEN" "✅ Build completed successfully!"

# Print instructions
print_color "$CYAN" "
To run the application:
1. Activate the virtual environment:
   cd app/backend
   source .venv/bin/activate

2. Start the server in development mode:
   adev runserver app.py --port 8000

   Or in production mode:
   gunicorn app:create_app -b 0.0.0.0:8000 --worker-class aiohttp.GunicornWebWorker

The application will be available at http://localhost:8000"
