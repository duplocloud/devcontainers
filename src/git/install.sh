#!/usr/bin/env bash
set -e

echo "Installing git feature..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install git plugins to a location in PATH
PLUGIN_DIR="/usr/local/bin"

for plugin in "${FEATURE_DIR}/plugins/"*; do
  if [ -f "$plugin" ]; then
    plugin_name="$(basename "$plugin")"
    echo "Installing git plugin: $plugin_name"
    cp "$plugin" "${PLUGIN_DIR}/${plugin_name}"
    chmod 755 "${PLUGIN_DIR}/${plugin_name}"
  fi
done

# Copy on-create script to a global location
cp "${FEATURE_DIR}/scripts/on-create.sh" /usr/local/share/git-on-create.sh
chmod 755 /usr/local/share/git-on-create.sh

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/git-feature.conf
PROVIDER="${PROVIDER:-none}"
USERNAME="${USERNAME:-}"
USEREMAIL="${USEREMAIL:-}"
SIGNINGKEY="${SIGNINGKEY:-}"
EOF
chmod 644 /usr/local/etc/git-feature.conf

echo "Git feature installed successfully!"
