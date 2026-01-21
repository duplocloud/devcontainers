#!/usr/bin/env bash
set -e

echo "Checking Node.js installation..."

# Check if node is already installed
if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  echo "✓ Node.js already installed: ${NODE_VERSION}"
  exit 0
fi

echo "Node.js not found, attempting installation..."

# Try to use nvm if available
if [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
  echo "Found nvm, loading it..."
  # shellcheck disable=SC1091
  source "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
  
  if command -v nvm &> /dev/null; then
    echo "Installing Node.js LTS via nvm..."
    nvm install --lts
    nvm use --lts
    echo "✓ Node.js installed via nvm"
    node --version
    exit 0
  fi
fi

# Fallback to apt package manager
if command -v apt-get &> /dev/null; then
  echo "Installing Node.js via apt..."
  export DEBIAN_FRONTEND=noninteractive
  
  apt-get update
  apt-get install -y nodejs npm
  
  echo "✓ Node.js installed via apt"
  node --version
  exit 0
fi

# If we got here, we couldn't install Node.js
echo "ERROR: Could not install Node.js. Neither nvm nor apt-get are available."
exit 1
