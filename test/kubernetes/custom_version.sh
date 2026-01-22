#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Test that kubectl is installed
check "kubectl installed" kubectl version --client

# Test that kubectl version is 1.30.x
check "kubectl version 1.30" bash -c 'kubectl version --client -o json | grep -q "1.30"'

# Test that helm is installed
check "helm installed" helm version

# Test that kubeconfig directory exists
check "kube config dir exists" test -d ~/.kube

# Report results
reportResults
