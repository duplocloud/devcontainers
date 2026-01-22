#!/bin/bash
set -e

source dev-container-features-test-lib
source /usr/local/etc/github-feature.conf

# Check that skills were configured
check "skills configured" test "${SKILLS}" = "tf-module"

# Check that gh CLI is installed
check "gh cli installed" command -v gh

# Check that duplo-skills command is available
check "duplo-skills available" command -v duplo-skills

# Verify skills directory was created
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
COPILOT_HOME="${COPILOT_HOME:-${USER_HOME}/.github-copilot}"
SKILLS_DIR="${COPILOT_HOME}/skills"

check "skills directory exists" test -d "${SKILLS_DIR}"

# Check that tf-module skill was downloaded even without Copilot enabled
check "tf-module skill exists" test -d "${SKILLS_DIR}/tf-module"

# Verify that Copilot is NOT enabled
check "copilot not enabled" test "${INSTALLCOPILOT}" != "true"

echo "✓ Skills downloaded successfully without Copilot CLI"

reportResults
