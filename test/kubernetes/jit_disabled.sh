#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Test that configuration file was created
check "config-file-exists" test -f /usr/local/etc/kubernetes-feature.conf

# Test that kubectl is available
check "kubectl-installed" kubectl version --client

# Test feature configuration values
source /usr/local/etc/kubernetes-feature.conf

check "jit-is-disabled" test "${JIT}" = "false"

# Report results
reportResults
