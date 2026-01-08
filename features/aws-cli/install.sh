#!/bin/bash
set -e

echo "Activating AWS CLI custom aliases feature..."

# Ensure AWS CLI config directory exists
mkdir -p /home/vscode/.aws

# Copy the custom alias file
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${FEATURE_DIR}/alias" /home/vscode/.aws/alias

# Set proper permissions
chmod 644 /home/vscode/.aws/alias
chown -R vscode:vscode /home/vscode/.aws 2>/dev/null || true

echo "AWS CLI custom aliases installed successfully!"
