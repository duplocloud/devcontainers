#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'github' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "gh is installed" command -v gh
check "gh version" gh --version

# Check config file exists
check "config file exists" test -f /usr/local/etc/github-feature.conf

# Check on-create script exists
check "on-create script exists" test -f /usr/local/share/github-on-create.sh

# Report results
reportResults
