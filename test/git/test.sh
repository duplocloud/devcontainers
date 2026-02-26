#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'git' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "git is installed" command -v git
check "git version" git --version

# Check git plugins are installed
check "git-bump is installed" command -v git-bump
check "git-setenv is installed" command -v git-setenv

# Check on-create script exists
check "on-create script exists" test -f /usr/local/share/git-on-create.sh

# Report results
reportResults
