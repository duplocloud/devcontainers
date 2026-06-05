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

# The on-create script must write the shell-appropriate direnv hook to the rc file of every
# installed shell (bash -> .bashrc + 'direnv hook bash', zsh -> .zshrc + 'direnv hook zsh'),
# so direnv activates regardless of which shell the terminal launches.
check "direnv hook configured for bash" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  grep -q "direnv hook bash" "$HOME_DIR/.bashrc"
'

# zsh is not in every base image; only assert when it is installed.
check "direnv hook configured for zsh when zsh is installed" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  command -v zsh >/dev/null 2>&1 || exit 0
  grep -q "direnv hook zsh" "$HOME_DIR/.zshrc"
'

reportResults
