 #!/bin/bash

# Exit on any error
set -e

echo 'Creating Python virtual environment ".venv"...'
# Remove existing venv if it exists
if [ -d ".venv" ]; then
    echo 'Removing existing virtual environment...'
    rm -rf .venv
fi

python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Upgrade pip
echo 'Upgrading pip...'
python3 -m pip install --upgrade pip

echo 'Installing dependencies from "requirements.txt" into virtual environment...'
python3 -m pip install -r app/backend/requirements.txt

# Install development tools
echo 'Installing development dependencies...'
python3 -m pip install gunicorn aiohttp-devtools pytest pytest-asyncio pytest-cov black flake8 mypy