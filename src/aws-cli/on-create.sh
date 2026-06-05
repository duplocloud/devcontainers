#!/usr/bin/env bash
set -e

echo "Configuring AWS CLI..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Detect the remote user's login shell and pick the matching interactive rc file
USER_NAME="${_REMOTE_USER:-$(whoami)}"
LOGIN_SHELL="$(getent passwd "$USER_NAME" 2>/dev/null | cut -d: -f7)"
LOGIN_SHELL="${LOGIN_SHELL:-${SHELL:-/bin/bash}}"
case "$(basename "$LOGIN_SHELL")" in
  zsh) SHELL_KIND="zsh";  SHELL_RC="${USER_HOME}/.zshrc"  ;;
  *)   SHELL_KIND="bash"; SHELL_RC="${USER_HOME}/.bashrc" ;;
esac
touch "$SHELL_RC"

# Source feature configuration from install-time options
if [[ -f /usr/local/etc/aws-cli-feature.conf ]]; then
  source /usr/local/etc/aws-cli-feature.conf
fi

# Run JIT configuration if enabled
JIT="${JIT:-false}"
if [[ "$JIT" == "true" ]]; then
  bash /usr/local/share/aws-cli-configure-jit.sh
fi

# Source helpers in the user's rc file
cat <<EOF >> "$SHELL_RC"

## Sourced from Duplocloud AWS CLI Feature
if [ -f '/usr/local/share/aws-cli-helpers.sh' ]; then . '/usr/local/share/aws-cli-helpers.sh'; fi

EOF

echo "AWS CLI configured successfully!"
