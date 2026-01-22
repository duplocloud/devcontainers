#!/bin/bash
set -e

source dev-container-features-test-lib
source /usr/local/etc/github-feature.conf

# Check that Copilot is enabled
check "copilot enabled" test "${INSTALLCOPILOT}" = "true"

# Check that gh CLI is installed (Copilot requires it)
check "gh cli installed" command -v gh

# Note: We can't verify the copilot extension is installed without authentication
# The extension installation happens when the user runs 'gh auth login'
echo "Note: Copilot extension installation requires authentication"
echo "Run 'gh auth login' then 'gh extension install github/gh-copilot' to complete setup"

reportResults
