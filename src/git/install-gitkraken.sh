#!/usr/bin/env bash
set -e

echo "Installing GitKraken CLI..."

# GitKraken CLI version
GK_VERSION="3.1.51"

# Detect OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

# Map architecture to GitKraken naming
case "${ARCH}" in
  x86_64)
    GK_ARCH="amd64"
    ;;
  aarch64|arm64)
    GK_ARCH="arm64"
    ;;
  i386|i686)
    GK_ARCH="386"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

# Map OS to GitKraken naming and set file extension
case "${OS}" in
  linux)
    GK_OS="linux"
    GK_FILE="gk_${GK_VERSION}_${GK_OS}_${GK_ARCH}.zip"
    ;;
  darwin)
    GK_OS="darwin"
    GK_FILE="gk_${GK_VERSION}_${GK_OS}_${GK_ARCH}.zip"
    ;;
  *)
    echo "Unsupported OS: ${OS}"
    exit 1
    ;;
esac

# Download URL
DOWNLOAD_URL="https://github.com/gitkraken/gk-cli/releases/download/v${GK_VERSION}/${GK_FILE}"

echo "Downloading GitKraken CLI v${GK_VERSION} for ${GK_OS}/${GK_ARCH}..."
echo "URL: ${DOWNLOAD_URL}"

# Create temporary directory
TMP_DIR="$(mktemp -d)"
cd "${TMP_DIR}"

# Download and extract
curl -fsSL "${DOWNLOAD_URL}" -o "${GK_FILE}"
unzip -q "${GK_FILE}"

# Install to /usr/local/bin
install -m 755 gk /usr/local/bin/gk

# Cleanup
cd /
rm -rf "${TMP_DIR}"

# Verify installation
if command -v gk &> /dev/null; then
  echo "GitKraken CLI installed successfully!"
  gk --version
else
  echo "ERROR: GitKraken CLI installation failed"
  exit 1
fi
