#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Test that base AI feature is installed (Node.js and duplo-skills)
check "node installed" node --version
check "duplo-skills installed" command -v duplo-skills

# Test that Gemini CLI is installed
check "gemini installed" command -v gemini

# Test that skills directory exists
check "gemini skills dir exists" test -d "${USER_HOME}/.gemini/skills"

# Test that tf-module skill was installed
check "tf-module skill installed" test -f "${USER_HOME}/.gemini/skills/tf-module.skill"

# Report results
reportResults
