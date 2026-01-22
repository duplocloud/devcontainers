#!/usr/bin/env bash
set -e

# Import common test functions
source dev-container-features-test-lib

# Feature-specific tests
check "gh is installed" gh --version
check "gk is installed" gk --version
check "gk installed from git feature" test -f /usr/local/share/install-gitkraken.sh

# Report results
reportResults
