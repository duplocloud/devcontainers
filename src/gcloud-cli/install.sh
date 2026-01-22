#!/bin/bash
set -e

echo "Installing Google Cloud CLI..."

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

require_apt() {
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "ERROR: apt-get is required to install Google Cloud CLI on this image."
    exit 1
  fi
}

python_version_ok() {
  # Prints "ok" if python3 exists and is >= 3.12, else prints nothing.
  if ! command -v python3 >/dev/null 2>&1; then
    return 1
  fi
  python3 -c 'import sys; print("ok" if sys.version_info >= (3,12) else "")' 2>/dev/null | grep -q '^ok$'
}

ensure_python_312_plus_or_warn() {
  if python_version_ok; then
    echo "python3 is already >= 3.12"
    return 0
  fi

  echo "python3 >= 3.12 is recommended for gcloud."

  # Best-effort: try python3.12 from the existing repo (no extra PPAs).
  if apt-cache show python3.12 >/dev/null 2>&1; then
    echo "Installing python3.12..."
    apt-get install -y --no-install-recommends python3.12 python3.12-distutils python3.12-venv || true
  else
    echo "python3.12 not available in current apt sources."
  fi

  if ! python_version_ok; then
    echo "Warning: python3 >= 3.12 not available. gcloud may fail to run."
    python3 --version 2>/dev/null || true
  fi
}

require_apt

# Install required dependencies (curl/fzf may not exist on vanilla images)
apt-get update
apt_packages=(curl ca-certificates fzf)

# Ensure at least python3 exists so the installer can run.
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found; installing distro python3."
  apt_packages+=(python3)
fi

apt-get install -y --no-install-recommends "${apt_packages[@]}"
apt-get clean
rm -rf /var/lib/apt/lists/*

ensure_python_312_plus_or_warn

# Prefer python3.12 if present
if command -v python3.12 >/dev/null 2>&1; then
  mkdir -p /usr/local/bin
  ln -sf "$(command -v python3.12)" /usr/local/bin/python3
  ln -sf "$(command -v python3.12)" /usr/local/bin/python
fi

# Ensure 'python' is available for installers that assume it exists.
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

# Install gcloud CLI if Python is new enough; otherwise warn and continue.
if python_version_ok; then
  if command -v python3.12 >/dev/null 2>&1; then
    CLOUDSDK_PYTHON="$(command -v python3.12)" "$USER_HOME/google-cloud-sdk/install.sh" --quiet --usage-reporting=false --path-update=true
  else
    CLOUDSDK_PYTHON="$(command -v python3)" "$USER_HOME/google-cloud-sdk/install.sh" --quiet --usage-reporting=false --path-update=true
  fi
else
  echo "Warning: Python >= 3.12 not available. Skipping gcloud installer."
  echo "Install a newer Python or use an image that includes Python 3.12+."
  mkdir -p /usr/local/etc
  echo "python_not_supported=true" > /usr/local/etc/gcloud-cli-python-warning
fi

# Set proper permissions
chown -R "$USER_NAME:$USER_NAME" "$USER_HOME/google-cloud-sdk" 2>/dev/null || true

# Copy on-create script to shared location
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/gcloud-on-create.sh
chmod +x /usr/local/share/gcloud-on-create.sh

echo "Google Cloud CLI installed successfully!"
