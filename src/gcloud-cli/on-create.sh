#!/usr/bin/env bash
set -e

echo "Configuring Google Cloud CLI..."

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

# Add gcloud CLI setup to the user's rc file with some extra roomy spacing.
# The gcloud SDK ships shell-specific include files (path.bash.inc / path.zsh.inc, etc.)
cat <<EOF >> "$SHELL_RC"

## Sourced from Duplocloud GCloud CLI Feature
# Google Cloud CLI - path setup
if [ -f '${USER_HOME}/google-cloud-sdk/path.${SHELL_KIND}.inc' ]; then . '${USER_HOME}/google-cloud-sdk/path.${SHELL_KIND}.inc'; fi

# Google Cloud CLI - shell command completion
if [ -f '${USER_HOME}/google-cloud-sdk/completion.${SHELL_KIND}.inc' ]; then . '${USER_HOME}/google-cloud-sdk/completion.${SHELL_KIND}.inc'; fi

# Google Cloud CLI - helper functions
if [ -f '/usr/local/share/gcloud-cli-helpers.sh' ]; then . '/usr/local/share/gcloud-cli-helpers.sh'; fi

EOF

echo "Google Cloud CLI configured successfully!"
