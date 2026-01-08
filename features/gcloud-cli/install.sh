#!/bin/bash
set -e

echo "Installing Google Cloud CLI..."

# Detect architecture
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
  GCLOUD_ARCH="x86_64"
elif [ "$ARCH" = "arm64" ]; then
  GCLOUD_ARCH="arm"
else
  echo "Unsupported architecture: $ARCH"
  exit 1
fi

# Download and install gcloud CLI
curl -O "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz"
tar -xf "google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz" -C /home/vscode
rm "google-cloud-cli-linux-${GCLOUD_ARCH}.tar.gz"

# Install gcloud CLI
/home/vscode/google-cloud-sdk/install.sh --quiet --usage-reporting=false --path-update=true

# Set proper permissions
chown -R vscode:vscode /home/vscode/google-cloud-sdk

echo "Google Cloud CLI installed successfully!"
