#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Test that base AI feature is installed (Node.js and duplo-skills)
check "node installed" node --version
check "duplo-skills installed" command -v duplo-skills

# Test that Gemini CLI is installed
check "gemini installed" command -v gemini

# Test that skills directory exists
check "gemini skills dir exists" test -d "${HOME}/.gemini/skills"

# Test that tf-module skill was installed
check "tf-module skill installed" test -f "${HOME}/.gemini/skills/tf-module.skill"

# Report results
reportResults
