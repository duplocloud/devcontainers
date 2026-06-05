#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'direnv' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

check "direnv is installed" command -v direnv
check "direnvrc installed" test -f "${USER_HOME}/direnv/direnvrc"

# The on-create script must write the direnv hook to the login shell's rc file,
# using the shell-appropriate hook (zsh -> .zshrc + 'direnv hook zsh', else .bashrc + bash).
check "direnv hook configured in login-shell rc" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  USER_NAME="${_REMOTE_USER:-$(whoami)}"
  LOGIN_SHELL="$(getent passwd "$USER_NAME" 2>/dev/null | cut -d: -f7)"
  LOGIN_SHELL="${LOGIN_SHELL:-${SHELL:-/bin/bash}}"
  case "$(basename "$LOGIN_SHELL")" in
    zsh) RC="$HOME_DIR/.zshrc"; KIND=zsh ;;
    *)   RC="$HOME_DIR/.bashrc"; KIND=bash ;;
  esac
  grep -q "direnv hook $KIND" "$RC"
'

reportResults
