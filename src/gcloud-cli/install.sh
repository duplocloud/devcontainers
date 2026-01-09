#!/bin/bash
set -e

echo "Installing Google Cloud CLI..."

# Install required dependencies (curl may not exist on vanilla images)
apt-get update
apt-get install -y --no-install-recommends curl ca-certificates

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"

# Detect architecture
ARCH=$(dpkg --print-architecture 2>/dev/null || uname -m)
if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x86_64" ]; then
  GCLOUD_ARCH="x86_64"
elif [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
  GCLOUD_ARCH="arm"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Download and install gcloud CLI
curl -sSL -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz"
tar -xf "google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz" -C "$USER_HOME"
rm "google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz"

# Install gcloud CLI
"$USER_HOME/google-cloud-sdk/install.sh" --quiet --usage-reporting=false --path-update=true

# Set proper permissions
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/google-cloud-sdk" 2>/dev/null || true

echo "Google Cloud CLI installed successfully!"
