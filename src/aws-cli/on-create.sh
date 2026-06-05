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

# Source helpers in every installed shell's interactive rc file. We can't rely on the login shell
# ($SHELL / getent passwd): images often install zsh as the terminal default without changing the
# user's login shell, so targeting a single shell leaves the actually-used shell unconfigured.
configure_shell() {
  local kind="$1" rc="$2"
  command -v "$kind" >/dev/null 2>&1 || return 0
  touch "$rc"
  # Idempotent: skip if this feature's block is already present.
  grep -qF 'Duplocloud AWS CLI Feature' "$rc" 2>/dev/null && return 0
  cat <<EOF >> "$rc"

## Sourced from Duplocloud AWS CLI Feature
if [ -f '/usr/local/share/aws-cli-helpers.sh' ]; then . '/usr/local/share/aws-cli-helpers.sh'; fi

EOF
  echo "AWS CLI helpers added to ${rc}"
}

configure_shell bash "${USER_HOME}/.bashrc"
configure_shell zsh  "${USER_HOME}/.zshrc"

echo "AWS CLI configured successfully!"
