#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'terraform' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "tf.sh helper exists" test -f /usr/local/share/duplocloud/tf.sh
check "tf.sh is readable" test -r /usr/local/share/duplocloud/tf.sh
check "tf command is executable" test -x /usr/local/bin/tf
check "tf command in PATH" bash -lc "command -v tf"
check "tf command works" bash -lc "tf --version"

# Report results
reportResults
