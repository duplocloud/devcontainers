#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Test that base AI feature is installed (Node.js and duplo-skills)
check "node installed" node --version
check "duplo-skills installed" command -v duplo-skills

# Test that Claude Code CLI is installed
check "claude installed" command -v claude

# Test that npm has claude-code package
check "claude-code npm package" npm list -g @anthropic-ai/claude-code

# Test that skills directory exists
check "claude skills dir exists" test -d "${USER_HOME}/.claude/skills"

# Report results
reportResults
