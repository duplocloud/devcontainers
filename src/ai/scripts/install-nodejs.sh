#!/usr/bin/env bash
set -euo pipefail

MIN_NODE_MAJOR="${MIN_NODE_MAJOR:-18}"

echo "Checking Node.js installation..."

node_major() {
  if ! command -v node >/dev/null 2>&1; then
    echo "0"
    return
  fi
  
  # Try multiple methods to get the version
  local version
  
  # Method 1: Use node to extract major version
  version=$(node -e "console.log(process.versions.node.split('.')[0])" 2>/dev/null)
  if [[ -n "$version" && "$version" =~ ^[0-9]+$ ]]; then
    echo "$version"
    return
  fi
  
  # Method 2: Parse from node --version output
  version=$(node --version 2>/dev/null | sed -E 's/^v?([0-9]+)\..*/\1/')
  if [[ -n "$version" && "$version" =~ ^[0-9]+$ ]]; then
    echo "$version"
    return
  fi
  
  # Fallback
  echo "0"
}

has_node() {
  command -v node >/dev/null 2>&1
}

has_python() {
  command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1
}

has_npm() {
  command -v npm >/dev/null 2>&1
}

ensure_min_node() {
  if ! has_node; then
    return 1
  fi

  local major
  major="$(node_major)"
  if [[ "$major" -ge "$MIN_NODE_MAJOR" ]]; then
    # Try to get full version, fallback to showing major version
    local full_version
    full_version=$(node --version 2>/dev/null || echo "v${major}.x")
    echo "✓ Node.js already installed: ${full_version}"
    
    # Also verify npm is available
    if ! has_npm; then
      echo "⚠ npm not found in PATH, attempting to locate..."
      # Try to find npm in common locations
      local npm_candidates=(
        "/usr/local/bin/npm"
        "/usr/bin/npm"
        "$(dirname "$(command -v node)")/npm"
      )
      for npm_path in "${npm_candidates[@]}"; do
        if [[ -x "$npm_path" ]]; then
          echo "Found npm at $npm_path"
          export PATH="$(dirname "$npm_path"):$PATH"
          if has_npm; then
            echo "✓ npm is now available: v$(npm -v)"
            return 0
          fi
        fi
      done
      echo "npm not found; will attempt reinstall"
      return 1
    fi
    
    echo "✓ npm is available: v$(npm -v)"
    return 0
  fi

  echo "Node.js is installed but too old (major=$major, need >= $MIN_NODE_MAJOR)."
  return 1
}

load_nvm() {
  local candidates=(
    "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
    "$HOME/.nvm/nvm.sh"
    "/usr/local/share/nvm/nvm.sh"
  )

  for nvm_sh in "${candidates[@]}"; do
    if [[ -s "$nvm_sh" ]]; then
      echo "Found nvm at $nvm_sh, loading it..."
      # Temporarily disable unbound variable check for nvm
      # shellcheck disable=SC1090,SC1091
      set +u
      source "$nvm_sh"
      set -u
      if command -v nvm >/dev/null 2>&1; then
        return 0
      fi
    fi
  done

  return 1
}

install_with_nvm() {
  if ! load_nvm; then
    return 1
  fi

  echo "Installing Node.js LTS via nvm..."
  # Temporarily disable unbound variable check for nvm commands
  set +u
  nvm install --lts
  nvm use --lts
  set -u

  ensure_min_node
}

install_with_apt_nodesource() {
  if ! command -v apt-get >/dev/null 2>&1; then
    return 1
  fi

  echo "Installing Node.js LTS via apt (NodeSource)..."
  export DEBIAN_FRONTEND=noninteractive

  apt-get update
  apt-get install -y --no-install-recommends ca-certificates curl gnupg

  curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
  apt-get install -y --no-install-recommends nodejs

  apt-get clean
  rm -rf /var/lib/apt/lists/*

  # Refresh PATH cache and verify node is available
  hash -r 2>/dev/null || true
  
  # Give the system a moment to settle
  sleep 1
  
  # Explicitly check if node is now available
  if ! command -v node >/dev/null 2>&1; then
    echo "ERROR: node command not found after installation"
    return 1
  fi
  
  echo "Verifying Node.js installation..."
  node --version || echo "WARNING: node --version failed"
  
  ensure_min_node
}

if ensure_min_node; then
  exit 0
fi

echo "Node.js not present or too old; attempting installation..."

# Prefer nvm when available (works well with images that pre-install nvm)
if install_with_nvm; then
  exit 0
fi

# Fall back to apt-based install of LTS
if install_with_apt_nodesource; then
  exit 0
fi

echo "ERROR: Could not install a usable Node.js (>= ${MIN_NODE_MAJOR})."
if ! command -v apt-get >/dev/null 2>&1; then
  echo "Reason: apt-get not available."
fi
if ! has_python; then
  echo "Note: Some installers require Python; consider adding the devcontainers Python feature or using a base image with Python."
fi
exit 1
