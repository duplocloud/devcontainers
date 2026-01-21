#!/bin/bash
set -e

echo "Installing Google Cloud CLI..."

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install required dependencies (curl/fzf may not exist on vanilla images)
apt-get update
apt_packages=(curl ca-certificates fzf)

# gcloud's installer requires `python` on PATH
if ! command -v python >/dev/null 2>&1; then
  if command -v python3 >/dev/null 2>&1; then
    echo "python3 is available but python is missing; creating python -> python3 shim."
    mkdir -p /usr/local/bin
    ln -sf "$(command -v python3)" /usr/local/bin/python
  else
    echo "python is not available; installing python3."
    apt_packages+=(python3)
  fi
fi

apt-get install -y --no-install-recommends "${apt_packages[@]}"
apt-get clean
rm -rf /var/lib/apt/lists/*

if ! command -v python >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
  mkdir -p /usr/local/bin
  ln -sf "$(command -v python3)" /usr/local/bin/python
fi

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

# Copy on-create script to shared location
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/gcloud-on-create.sh
chmod +x /usr/local/share/gcloud-on-create.sh

echo "Google Cloud CLI installed successfully!"
