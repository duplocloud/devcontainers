#!/bin/bash
set -e

echo "Activating AWS CLI custom aliases feature..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"

# Ensure AWS CLI config directory exists
mkdir -p "$USER_HOME/.aws"

# Copy the custom alias file
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${FEATURE_DIR}/alias" "$USER_HOME/.aws/alias"

# Set proper permissions
chmod 644 "$USER_HOME/.aws/alias"
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.aws" 2>/dev/null || true

echo "AWS CLI custom aliases installed successfully!"
