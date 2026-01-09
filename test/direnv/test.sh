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

reportResults
