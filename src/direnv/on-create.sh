#!/usr/bin/env bash
set -e

echo "Configuring direnv..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Add direnv config and bash hook to .bashrc
cat <<EOF >> "${USER_HOME}/.bashrc"

## Sourced from Duplocloud Direnv Feature
export DIRENV_CONFIG="${USER_HOME}/direnv"
eval "\$(direnv hook bash)"

EOF

echo "direnv configured successfully!"
