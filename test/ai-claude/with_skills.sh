#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Test that base AI feature is installed (Node.js and duplo-skills)
check "node installed" node --version
check "duplo-skills installed" command -v duplo-skills

# Test that Claude Code CLI is installed
check "claude-code installed" command -v claude-code

# Test that skills directory exists
check "claude skills dir exists" test -d "${HOME}/.claude/skills"

# Test that tf-module skill was installed
check "tf-module skill installed" test -f "${HOME}/.claude/skills/tf-module.skill"

# Report results
reportResults
