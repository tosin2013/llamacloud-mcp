#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Ubuntu build process..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

# Update package list
echo "Updating package list..."
apt-get update

# Add deadsnakes PPA for Python 3.11
echo "Adding Python 3.11 repository..."
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update

# Install Python 3.11 and development tools
echo "Installing Python 3.11 and development tools..."
apt-get install -y python3.11 python3.11-venv python3.11-dev build-essential

# Create and activate virtual environment
echo "Creating Python virtual environment..."
python3.11 -m venv venv
source venv/bin/activate

# Upgrade pip and install poetry
echo "Installing dependencies..."
pip install --upgrade pip
pip install poetry

# Install project dependencies
echo "Installing project dependencies..."
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