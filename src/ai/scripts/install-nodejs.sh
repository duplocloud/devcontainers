#!/usr/bin/env bash
set -euo pipefail

MIN_NODE_MAJOR="${MIN_NODE_MAJOR:-18}"

echo "Checking Node.js installation..."

node_major() {
  node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo "0"
}

has_node() {
  command -v node >/dev/null 2>&1
}

has_python() {
  command -v python >/dev/null 2>&1 || command -v python3 >/dev/null 2>&1
}

ensure_min_node() {
  if ! has_node; then
    return 1
  fi

  local major
  major="$(node_major)"
  if [[ "$major" -ge "$MIN_NODE_MAJOR" ]]; then
    echo "✓ Node.js already installed: v$(node -p 'process.versions.node')"
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
      # shellcheck disable=SC1090,SC1091
      source "$nvm_sh"
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
  nvm install --lts
  nvm use --lts

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
