#!/bin/bash
set -e

echo "Installing direnv..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"

# Install direnv (vanilla images may not include it)
apt-get update
apt-get install -y --no-install-recommends direnv ca-certificates
apt-get clean
rm -rf /var/lib/apt/lists/*

# Install direnvrc under $HOME/direnv
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${USER_HOME}/direnv"
cp -f "${FEATURE_DIR}/direnvrc" "${USER_HOME}/direnv/direnvrc"
chown -R "${USER_NAME}:${USER_NAME}" "${USER_HOME}/direnv" 2>/dev/null || true

echo "direnv installed successfully."
