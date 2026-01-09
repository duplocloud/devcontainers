#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'aws-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "aws alias file exists" test -f "${_REMOTE_USER_HOME:-$HOME}/.aws/alias"
check "alias file is readable" cat "${_REMOTE_USER_HOME:-$HOME}/.aws/alias"

# Report results
reportResults
