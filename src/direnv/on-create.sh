#!/usr/bin/env bash
set -e

echo "Configuring direnv..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Install the direnv hook into every installed shell's interactive rc file.
# We can't rely on the login shell ($SHELL / getent passwd): images often install zsh and set it as
# the terminal's default without changing the user's login shell, so detecting a single shell leaves
# the actually-used shell without the hook. Writing to each installed shell's rc is robust to that.
configure_shell() {
  local kind="$1" rc="$2"
  command -v "$kind" >/dev/null 2>&1 || return 0
  touch "$rc"
  # Idempotent: skip if this feature's hook is already present.
  grep -qF "direnv hook ${kind}" "$rc" 2>/dev/null && return 0
  cat <<EOF >> "$rc"

## Sourced from Duplocloud Direnv Feature
export DIRENV_CONFIG="${USER_HOME}/direnv"
eval "\$(direnv hook ${kind})"

EOF
  echo "direnv hook added to ${rc}"
}

configure_shell bash "${USER_HOME}/.bashrc"
configure_shell zsh  "${USER_HOME}/.zshrc"

echo "direnv configured successfully!"
