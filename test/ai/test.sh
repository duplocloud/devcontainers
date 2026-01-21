#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Test that Node.js is installed
check "node installed" node --version

# Test that npm is installed
check "npm installed" npm --version

# Test that duplo-skills is installed
check "duplo-skills installed" command -v duplo-skills

# Test that duplo-skills shows help
check "duplo-skills help" duplo-skills --help

# Test that duplo-skills shows version
check "duplo-skills version" duplo-skills --version

# Report results
reportResults
