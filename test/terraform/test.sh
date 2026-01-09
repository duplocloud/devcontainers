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
check "tf.sh is sourceable" bash -c "source /usr/local/share/duplocloud/tf.sh"
check "tf.sh in system bashrc" grep -q "duplocloud/tf.sh" /etc/bash.bashrc

# Report results
reportResults
