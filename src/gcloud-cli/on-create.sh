#!/usr/bin/env bash
set -e

echo "Configuring Google Cloud CLI..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Add gcloud CLI setup to .bashrc with some extra roomy spacing
cat <<EOF >> "${USER_HOME}/.bashrc"

## Sourced from Duplocloud GCloud CLI Feature
# Google Cloud CLI - path setup
if [ -f '${USER_HOME}/google-cloud-sdk/path.bash.inc' ]; then . '${USER_HOME}/google-cloud-sdk/path.bash.inc'; fi

# Google Cloud CLI - shell command completion
if [ -f '${USER_HOME}/google-cloud-sdk/completion.bash.inc' ]; then . '${USER_HOME}/google-cloud-sdk/completion.bash.inc'; fi

EOF

echo "Google Cloud CLI configured successfully!"
