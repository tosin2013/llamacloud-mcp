#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting RHEL build process..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Enable EPEL repository
echo "Enabling EPEL repository..."
dnf install -y epel-release

# Install Python 3.9 and development tools
echo "Installing Python 3.9 and development tools..."
dnf install -y python3 python3-devel gcc make

# Create and activate virtual environment
echo "Creating Python virtual environment..."
python3.9 -m venv venv
source venv/bin/activate

# Upgrade pip and install poetry
echo "Installing dependencies..."
pip install --upgrade pip
pip install poetry

# Install project dependencies
echo "Installing project dependencies..."
poetry env use python3.9
poetry install

# Create environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo "⚠️  Please edit .env file with your API keys"
fi

# Set correct permissions for the virtual environment
chown -R $(logname):$(logname) venv/

# Run validation
echo "Running validation..."
python scripts/validate.py

echo "✨ Build process complete!"
echo "To activate the environment, run: source venv/bin/activate" 