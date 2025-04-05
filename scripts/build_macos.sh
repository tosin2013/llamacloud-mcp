#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting macOS build process..."

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check for Python 3.11
if ! command -v python3.11 &> /dev/null; then
    echo "Installing Python 3.11..."
    brew install python@3.11
fi

# Check for Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "Please complete the installation and run this script again."
    exit 1
fi

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

# Run validation
echo "Running validation..."
python scripts/validate.py

echo "✨ Build process complete!"
echo "To activate the environment, run: source venv/bin/activate" 