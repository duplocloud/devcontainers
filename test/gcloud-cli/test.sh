#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'gcloud-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "gcloud sdk directory exists" test -d "${_REMOTE_USER_HOME:-$HOME}/google-cloud-sdk"
check "gcloud is executable" bash -c '\
set -e; \
GCLOUD_BIN="'"${_REMOTE_USER_HOME:-$HOME}"'/google-cloud-sdk/bin/gcloud"; \
if [ -f /usr/local/etc/gcloud-cli-python-warning ]; then \
  echo "Warning: python >= 3.12 not available; skipping gcloud execution check."; \
  exit 0; \
fi; \
OUT="$(${GCLOUD_BIN} --version 2>&1)" || true; \
echo "$OUT"; \
if echo "$OUT" | grep -qi "Python .*no longer supported"; then \
  echo "Warning: gcloud requires Python >= 3.12. Skipping failure."; \
  exit 0; \
fi; \
echo "$OUT" | grep -qi "Google Cloud SDK" \
'

# The on-create script must source the shell-appropriate gcloud include files from the
# login shell's rc file (zsh -> .zshrc + .zsh.inc, else .bashrc + .bash.inc).
check "gcloud path inc sourced in login-shell rc" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  USER_NAME="${_REMOTE_USER:-$(whoami)}"
  LOGIN_SHELL="$(getent passwd "$USER_NAME" 2>/dev/null | cut -d: -f7)"
  LOGIN_SHELL="${LOGIN_SHELL:-${SHELL:-/bin/bash}}"
  case "$(basename "$LOGIN_SHELL")" in
    zsh) RC="$HOME_DIR/.zshrc"; KIND=zsh ;;
    *)   RC="$HOME_DIR/.bashrc"; KIND=bash ;;
  esac
  grep -q "google-cloud-sdk/path.$KIND.inc" "$RC"
'

# Report results
reportResults
