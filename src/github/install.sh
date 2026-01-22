#!/usr/bin/env bash
set -e

echo "Installing GitHub CLI..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure curl and unzip are available
if ! command -v curl &> /dev/null; then
  apt-get update && apt-get install -y curl
fi

if ! command -v unzip &> /dev/null; then
  apt-get update && apt-get install -y unzip
fi

# GitHub CLI version
GH_VERSION="2.64.0"

# Detect OS and architecture
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

# Map architecture to GitHub CLI naming
case "${ARCH}" in
  x86_64)
    GH_ARCH="amd64"
    ;;
  aarch64|arm64)
    GH_ARCH="arm64"
    ;;
  i386|i686)
    GH_ARCH="386"
    ;;
  *)
    echo "Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

# Map OS to GitHub CLI naming
case "${OS}" in
  linux)
    GH_OS="linux"
    GH_FILE="gh_${GH_VERSION}_${GH_OS}_${GH_ARCH}.tar.gz"
    ;;
  darwin)
    GH_OS="macOS"
    GH_FILE="gh_${GH_VERSION}_${GH_OS}_${GH_ARCH}.zip"
    ;;
  *)
    echo "Unsupported OS: ${OS}"
    exit 1
    ;;
esac

# Download URL
DOWNLOAD_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_FILE}"

echo "Downloading GitHub CLI v${GH_VERSION} for ${OS}/${ARCH}..."
echo "URL: ${DOWNLOAD_URL}"

# Create temporary directory
TMP_DIR="$(mktemp -d)"
cd "${TMP_DIR}"

# Download and extract
curl -fsSL "${DOWNLOAD_URL}" -o "${GH_FILE}"

if [[ "${GH_FILE}" == *.tar.gz ]]; then
  tar -xzf "${GH_FILE}"
  GH_DIR="gh_${GH_VERSION}_${GH_OS}_${GH_ARCH}"
else
  unzip -q "${GH_FILE}"
  GH_DIR="gh_${GH_VERSION}_${GH_OS}_${GH_ARCH}"
fi

# Install to /usr/local
cp -r "${GH_DIR}/bin/gh" /usr/local/bin/gh
chmod 755 /usr/local/bin/gh

# Install man pages if available
if [ -d "${GH_DIR}/share/man" ]; then
  mkdir -p /usr/local/share/man
  cp -r "${GH_DIR}/share/man/"* /usr/local/share/man/ || true
fi

# Cleanup
cd /
rm -rf "${TMP_DIR}"

# Verify installation
if command -v gh &> /dev/null; then
  echo "✓ GitHub CLI installed successfully!"
  gh --version
else
  echo "ERROR: GitHub CLI installation failed"
  exit 1
fi

# Install GitHub Copilot CLI if option is enabled
if [ "${INSTALLCOPILOT}" = "true" ]; then
  bash "${FEATURE_DIR}/install-copilot.sh"
fi

# Install GitKraken CLI if option is enabled and installer is available
if [ "${INSTALLGITKRAKEN}" = "true" ]; then
  if [ -f /usr/local/share/install-gitkraken.sh ]; then
    echo "Installing GitKraken CLI from git feature..."
    bash /usr/local/share/install-gitkraken.sh
  else
    echo "WARNING: GitKraken installer not found. The git feature must be installed first."
  fi
fi

# Copy on-create script to shared location
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/github-on-create.sh
chmod 755 /usr/local/share/github-on-create.sh

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/github-feature.conf
INSTALLCOPILOT="${INSTALLCOPILOT:-false}"
INSTALLGITKRAKEN="${INSTALLGITKRAKEN:-false}"
SKILLS="${SKILLS:-}"
EOF
chmod 644 /usr/local/etc/github-feature.conf

echo "GitHub CLI feature installed successfully!"
