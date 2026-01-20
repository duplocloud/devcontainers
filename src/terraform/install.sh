#!/bin/bash
set -e

echo "Installing Terraform DuploCloud helpers..."

# Install fzf dependency
apt-get update
apt-get install -y --no-install-recommends fzf
apt-get clean
rm -rf /var/lib/apt/lists/*

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"

# Install tf.sh to a standard location
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p /usr/local/share/duplocloud
cp "${FEATURE_DIR}/scripts/tf.sh" /usr/local/share/duplocloud/tf.sh
chmod 644 /usr/local/share/duplocloud/tf.sh

# Install tf executable (renamed from tf.sh for CLI usage)
cp "${FEATURE_DIR}/scripts/tf.sh" /usr/local/bin/tf
chmod 755 /usr/local/bin/tf

echo "Terraform DuploCloud helpers installed successfully!"
