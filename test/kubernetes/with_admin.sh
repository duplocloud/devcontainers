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

check "jit-is-enabled" test "${JIT}" = "true"
check "jit-admin-is-enabled" test "${JIT_ADMIN}" = "true"

# Report results
reportResults
