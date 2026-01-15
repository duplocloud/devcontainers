#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Test that configuration file was created
check "config-file-exists" test -f /usr/local/etc/kubernetes-feature.conf

# Test that kubectl is available (from dependent feature)
check "kubectl-installed" kubectl version --client

# Test that on-create script was copied
check "on-create-script-exists" test -f /usr/local/share/kubernetes-on-create.sh
check "on-create-script-executable" test -x /usr/local/share/kubernetes-on-create.sh

# Test feature configuration values are set
source /usr/local/etc/kubernetes-feature.conf

check "jit-config-set" test -n "${JIT}"
check "jit-admin-config-set" test -n "${JIT_ADMIN}"
check "jit-interactive-config-set" test -n "${JIT_INTERACTIVE}"

# Report results
reportResults
