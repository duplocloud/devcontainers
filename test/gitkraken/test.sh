#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'gitkraken' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "gk command is executable" test -x /usr/local/bin/gk
check "gk command in PATH" bash -lc "command -v gk"
check "gk command works" bash -lc "gk --version"

# Verify git feature dependency is satisfied
check "git is installed" bash -lc "command -v git"
check "git version" bash -lc "git --version"

# Report results
reportResults
