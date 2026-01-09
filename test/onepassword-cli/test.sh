#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'onepassword-cli' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "op is installed" command -v op
check "op version" op --version

# Report results
reportResults
