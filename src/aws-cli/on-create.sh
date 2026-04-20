#!/usr/bin/env bash
set -e

echo "Configuring AWS CLI..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Source feature configuration from install-time options
if [[ -f /usr/local/etc/aws-cli-feature.conf ]]; then
  source /usr/local/etc/aws-cli-feature.conf
fi

# Run JIT configuration if enabled
JIT="${JIT:-false}"
if [[ "$JIT" == "true" ]]; then
  bash /usr/local/share/aws-cli-configure-jit.sh
fi

# Source helpers in .bashrc
cat <<EOF >> "${USER_HOME}/.bashrc"

## Sourced from Duplocloud AWS CLI Feature
if [ -f '/usr/local/share/aws-cli-helpers.sh' ]; then . '/usr/local/share/aws-cli-helpers.sh'; fi

EOF

echo "AWS CLI configured successfully!"
