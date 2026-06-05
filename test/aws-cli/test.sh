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

# The on-create script must source the helpers from the login shell's rc file
# (zsh -> .zshrc, else .bashrc) so they load on zsh-based images too.
check "aws helpers sourced in login-shell rc" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  USER_NAME="${_REMOTE_USER:-$(whoami)}"
  LOGIN_SHELL="$(getent passwd "$USER_NAME" 2>/dev/null | cut -d: -f7)"
  LOGIN_SHELL="${LOGIN_SHELL:-${SHELL:-/bin/bash}}"
  case "$(basename "$LOGIN_SHELL")" in
    zsh) RC="$HOME_DIR/.zshrc" ;;
    *)   RC="$HOME_DIR/.bashrc" ;;
  esac
  grep -q "aws-cli-helpers.sh" "$RC"
'

# Report results
reportResults
