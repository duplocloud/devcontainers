#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'onepassword-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# NOTE: Since this test runs with default options (interactive: false),  
# the onCreateCommand will not attempt interactive authentication.

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests - just verify installation, not authentication
check "op is installed" command -v op
check "op version" op --version
check "jq is installed" command -v jq

# Check on-create script exists
check "on-create script exists" test -f /usr/local/share/onepassword-on-create.sh

# Check post-start script exists
check "post-start script exists" test -f /usr/local/share/onepassword-post-start.sh

# Check op-session-reload is in PATH
check "op-session-reload is executable" test -x /usr/local/bin/op-session-reload

# Check config file exists
check "config file exists" test -f /usr/local/etc/onepassword-feature.conf

# Verify default config values
check "interactive defaults to false" grep -q '^INTERACTIVE="false"$' /usr/local/etc/onepassword-feature.conf

# The on-create script wires the ephemeral session file into the login shell's rc file
# (zsh -> .zshrc, else .bashrc) so op sessions load in new shells on zsh-based images too.
check "session-env sourcing wired into login-shell rc" bash -c '
  HOME_DIR="${_REMOTE_USER_HOME:-$HOME}"
  USER_NAME="${_REMOTE_USER:-$(whoami)}"
  LOGIN_SHELL="$(getent passwd "$USER_NAME" 2>/dev/null | cut -d: -f7)"
  LOGIN_SHELL="${LOGIN_SHELL:-${SHELL:-/bin/bash}}"
  case "$(basename "$LOGIN_SHELL")" in
    zsh) RC="$HOME_DIR/.zshrc" ;;
    *)   RC="$HOME_DIR/.bashrc" ;;
  esac
  grep -qF "/tmp/op-session.env" "$RC"
'

# Report results
reportResults
