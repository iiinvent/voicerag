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
    echo -e "${1}${2}${NC}"
}

# Load Python environment
. ./scripts/load_python_env.sh

print_color "$CYAN" "📦 Setting up frontend..."
cd app/frontend

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    print_color "$YELLOW" "Installing pnpm globally..."
    npm install -g pnpm
fi

print_color "$CYAN" "Installing frontend dependencies..."
pnpm install
if [ $? -ne 0 ]; then
    print_color "$RED" "Failed to install frontend dependencies"
    exit 1
fi

print_color "$CYAN" "Building frontend..."
pnpm run build
if [ $? -ne 0 ]; then
    print_color "$RED" "Failed to build frontend"
    exit 1
fi

print_color "$CYAN" "🚀 Starting development servers..."

# Start frontend dev server in background
print_color "$YELLOW" "Starting frontend development server..."
pnpm run dev &
FRONTEND_PID=$!

# Start backend in development mode
cd ../backend
print_color "$YELLOW" "Starting backend development server..."
./.venv/bin/python app.py runserver --port 8000

# Cleanup
kill $FRONTEND_PID 2>/dev/null || true
