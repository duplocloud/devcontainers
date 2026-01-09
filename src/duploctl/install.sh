#!/usr/bin/env bash
set -e

VERSION="${VERSION:-latest}"
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
BIN_DIR="$USER_HOME/.local/bin"

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
  echo "Installing $pkg via pip --user"
  python3 -m pip install --user "$pkg"
}

install_binary() {
  [[ "$VERSION" == "latest" ]] && { echo "Error: Binary install requires a specific version (e.g. v0.3.8)" >&2; exit 1; }
  
  local ver="${VERSION#v}"
  local url="https://github.com/duplocloud/duploctl/releases/download/v${ver}/duploctl-${ver}-$(get_os)-$(get_arch).tar.gz"
  
  echo "Downloading duploctl $VERSION"
  mkdir -p "$BIN_DIR"
  curl -fsSL "$url" | tar -xz -C "$BIN_DIR" duploctl
  chmod +x "$BIN_DIR/duploctl"
}

echo "Installing duploctl..."
if has_pip; then
  install_with_pip
else
  install_binary
fi
echo "Done."
