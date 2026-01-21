#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Test that base AI feature is installed (Node.js and duplo-skills)
check "node installed" node --version
check "duplo-skills installed" command -v duplo-skills

# Test that Codex CLI is installed
check "codex installed" command -v codex

# Test that skills directory exists
check "codex skills dir exists" test -d "${HOME}/.codex/skills"

# Test that tf-module skill was installed
check "tf-module skill installed" test -f "${HOME}/.codex/skills/tf-module.skill"

# Report results
reportResults
