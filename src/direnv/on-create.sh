#!/usr/bin/env bash
set -e

echo "Configuring direnv..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Add direnv bash hook to .bashrc
cat <<EOF >> "${USER_HOME}/.bashrc"

## Sourced from Duplocloud Direnv Feature
eval "\$(direnv hook bash)"

EOF

echo "direnv configured successfully!"
