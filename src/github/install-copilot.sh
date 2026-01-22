#!/usr/bin/env bash
set -e

echo "Installing GitHub Copilot CLI..."

# Check if gh is installed
if ! command -v gh &> /dev/null; then
  echo "ERROR: GitHub CLI (gh) is not installed. Install gh first."
  exit 1
fi

# Install the Copilot CLI extension
# This installs gh copilot extension which provides the 'gh copilot' command
# Note: The extension requires authentication to use, but can be installed without it
echo "Installing gh extension: copilot..."

# Try to install, but don't fail if authentication is required
if gh extension install github/gh-copilot --force 2>&1 | tee /tmp/gh-copilot-install.log; then
  echo "✓ GitHub Copilot CLI extension queued for installation"
else
  # Check if the error is about authentication
  if grep -q "authentication\|auth\|login" /tmp/gh-copilot-install.log; then
    echo "⚠ GitHub Copilot CLI extension will be installed after authentication"
    echo "Note: Run 'gh auth login' and then 'gh extension install github/gh-copilot'"
    # Don't fail the installation - this is expected in devcontainers
    exit 0
  else
    echo "WARNING: Could not install GitHub Copilot CLI extension"
    cat /tmp/gh-copilot-install.log
    exit 1
  fi
fi

rm -f /tmp/gh-copilot-install.log

echo ""
echo "Available commands (after gh auth login):"
echo "  gh copilot suggest    - Get command suggestions"
echo "  gh copilot explain    - Explain commands"
echo ""
echo "Note: Authentication and skill installation will happen during onCreate"

