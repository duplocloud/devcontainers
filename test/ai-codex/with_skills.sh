#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
CODEX_HOME="${CODEX_HOME:-${USER_HOME}/.codex}"

# Test that base AI feature is installed (Node.js and duplo-skills)
check "node installed" node --version
check "duplo-skills installed" command -v duplo-skills

# Test that Codex CLI is installed
check "codex installed" command -v codex

# Test that skills directory exists
check "codex skills dir exists" test -d "${CODEX_HOME}/skills"

# Test that tf-module skill was installed (extracted directory)
check "tf-module skill installed" test -f "${CODEX_HOME}/skills/tf-module/SKILL.md"

# Report results
reportResults
