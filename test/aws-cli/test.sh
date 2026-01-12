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
check "configure-aws-jit.sh script exists" test -f "/usr/local/bin/configure-aws-jit.sh"
check "configure-aws-jit.sh is executable" test -x "/usr/local/bin/configure-aws-jit.sh"

# Report results
reportResults
