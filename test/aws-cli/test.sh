#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'aws-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "aws alias file exists" test -f "${_REMOTE_USER_HOME:-$HOME}/.aws/cli/alias"
check "alias file is readable" cat "${_REMOTE_USER_HOME:-$HOME}/.aws/cli/alias"
check "configure-aws-jit.sh script exists" test -f "/usr/local/share/aws-cli-configure-jit.sh"
check "configure-aws-jit.sh is executable" test -x "/usr/local/share/aws-cli-configure-jit.sh"

# The on-create script must source the helpers from every installed shell's rc file
# (bash -> .bashrc, zsh -> .zshrc) so they load regardless of which shell the terminal launches.
check "aws helpers sourced in bash rc" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  grep -q "aws-cli-helpers.sh" "$HOME_DIR/.bashrc"
'
check "aws helpers sourced in zsh rc when zsh is installed" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  command -v zsh >/dev/null 2>&1 || exit 0
  grep -q "aws-cli-helpers.sh" "$HOME_DIR/.zshrc"
'

# Report results
reportResults
