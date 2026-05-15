#!/bin/bash
set -e

echo "Activating AWS CLI custom aliases feature..."

# Install fzf dependency
apt-get update
apt-get install -y --no-install-recommends fzf
apt-get clean
rm -rf /var/lib/apt/lists/*

# Install AWS SSM Session Manager plugin
curl -sSL "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o /tmp/session-manager-plugin.deb
dpkg -i /tmp/session-manager-plugin.deb
rm /tmp/session-manager-plugin.deb

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"

# Ensure AWS CLI config directory exists
# Ensure AWS CLI config and alias directories exist
mkdir -p "$USER_HOME/.aws" "$USER_HOME/.aws/cli"

# Copy the custom alias file into the AWS CLI aliases directory
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${FEATURE_DIR}/alias" "$USER_HOME/.aws/cli/alias"

# Copy the AWS JIT configuration script to shared location
cp "${FEATURE_DIR}/scripts/configure-aws-jit.sh" /usr/local/share/aws-cli-configure-jit.sh
chmod +x /usr/local/share/aws-cli-configure-jit.sh

# Write feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/aws-cli-feature.conf
JIT="${JIT:-false}"
JITADMIN="${JITADMIN:-false}"
JITINTERACTIVE="${JITINTERACTIVE:-false}"
EOF
chmod 644 /usr/local/etc/aws-cli-feature.conf

# Set proper permissions on the alias file and AWS config directory
chmod 644 "$USER_HOME/.aws/cli/alias"
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/.aws" 2>/dev/null || true

# Copy helpers and on-create script to shared location
cp "${FEATURE_DIR}/helpers.sh" /usr/local/share/aws-cli-helpers.sh
chmod 644 /usr/local/share/aws-cli-helpers.sh
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/aws-cli-on-create.sh
chmod +x /usr/local/share/aws-cli-on-create.sh

echo "AWS CLI custom aliases installed successfully!"
