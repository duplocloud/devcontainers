#!/usr/bin/env bash
set -e

VERSION="${VERSION:-latest}"
BIN_DIR="/usr/local/bin"
BINARY_FALLBACK_VERSION="${BINARY_FALLBACK_VERSION:-v0.3.8}"

# Check if pip is available
has_pip() { command -v python3 >/dev/null && python3 -m pip --version >/dev/null 2>&1; }

# Detect architecture
get_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
}

# Detect OS
get_os() {
  case "$(uname -s | tr '[:upper:]' '[:lower:]')" in
    linux) echo "linux" ;;
    darwin) echo "darwin" ;;
    cygwin*|mingw*|msys*) echo "windows" ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
}

install_with_pip() {
  local pkg="duplocloud-client"
  [[ "$VERSION" != "latest" ]] && pkg="duplocloud-client==${VERSION#v}"
  echo "Installing $pkg globally via pip"
  python3 -m pip install --break-system-packages "$pkg"
}

install_binary() {
  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl tar gzip
  apt-get clean
  rm -rf /var/lib/apt/lists/*

  if [[ "$VERSION" == "latest" ]]; then
    echo "Version 'latest' requested, but pip is unavailable. Falling back to ${BINARY_FALLBACK_VERSION} for binary install."
    VERSION="${BINARY_FALLBACK_VERSION}"
  fi
  
  local ver="${VERSION#v}"
  local url="https://github.com/duplocloud/duploctl/releases/download/v${ver}/duploctl-${ver}-$(get_os)-$(get_arch).tar.gz"
  
  echo "Downloading duploctl $VERSION"
  mkdir -p "$BIN_DIR"
  curl -fsSL "$url" | tar -xz -C "$BIN_DIR" --strip-components=0
  chmod +x "$BIN_DIR/duploctl"
}

echo "Installing duploctl..."
if has_pip; then
  install_with_pip
else
  install_binary
fi
echo "Done."
