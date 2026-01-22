#!/bin/bash
set -e

source dev-container-features-test-lib

# Check GitKraken CLI is installed
check "gk command is installed" command -v gk
check "gk version" gk --version

# Verify gk is executable
check "gk is executable" test -x /usr/local/bin/gk

reportResults
