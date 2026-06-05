#!/usr/bin/env bash
set -e

echo "Configuring direnv..."

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

# Add direnv config and the shell-appropriate hook to the user's rc file
cat <<EOF >> "$SHELL_RC"

## Sourced from Duplocloud Direnv Feature
export DIRENV_CONFIG="${USER_HOME}/direnv"
eval "\$(direnv hook ${SHELL_KIND})"

EOF

echo "direnv configured successfully!"
