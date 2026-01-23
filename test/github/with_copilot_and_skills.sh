#!/bin/bash
set -e

source dev-container-features-test-lib
source /usr/local/etc/github-feature.conf

# Check that Copilot is enabled
check "copilot enabled" test "${INSTALLCOPILOT}" = "true"

# Check that skills were configured
check "skills configured" test "${SKILLS}" = "tf-module"

# Check that gh CLI is installed (Copilot requires it)
check "gh cli installed" command -v gh

# Check that duplo-skills command is available
check "duplo-skills available" command -v duplo-skills

# Verify skills directory was created
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
COPILOT_HOME="${COPILOT_HOME:-${USER_HOME}/.copilot}"
SKILLS_DIR="${COPILOT_HOME}/skills"

check "skills directory exists" test -d "${SKILLS_DIR}"

# Check that tf-module skill was downloaded
check "tf-module skill exists" test -d "${SKILLS_DIR}/tf-module"

# Note: We can't verify the copilot extension is installed without authentication
# The extension installation happens when the user runs 'gh auth login'
echo "Note: Copilot extension installation requires authentication"
echo "Run 'gh auth login' then 'gh extension install github/gh-copilot' to complete setup"

reportResults
