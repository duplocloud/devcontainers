#!/usr/bin/env bash
set -e

echo "Configuring GitHub feature..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"

# Load feature configuration
if [ -f /usr/local/etc/github-feature.conf ]; then
  source /usr/local/etc/github-feature.conf
fi

# If Copilot is not enabled, exit early
if [ "${INSTALLCOPILOT}" != "true" ]; then
  echo "GitHub Copilot CLI not enabled. Skipping skill installation."
  exit 0
fi

# Check if duplo-skills is available
if ! command -v duplo-skills &> /dev/null; then
  echo "⚠ duplo-skills command not found. Skills will not be installed."
  echo "To use skills, include the 'ai' feature as a dependency."
  exit 0
fi

echo "Installing GitHub Copilot skills..."

# Skills directory for Copilot (user scope)
COPILOT_HOME="${COPILOT_HOME:-${USER_HOME}/.github-copilot}"
SKILLS_DIR="${COPILOT_HOME}/skills"
mkdir -p "${COPILOT_HOME}" "${SKILLS_DIR}"

# Get skills from option
FEATURE_SKILLS="${SKILLS:-}"

# Get skills from environment variable
ENV_SKILLS="${DUPLO_AI_SKILLS:-}"

# Merge skills from both sources
ALL_SKILLS=""
if [ -n "${FEATURE_SKILLS}" ]; then
  ALL_SKILLS="${FEATURE_SKILLS}"
fi
if [ -n "${ENV_SKILLS}" ]; then
  if [ -n "${ALL_SKILLS}" ]; then
    ALL_SKILLS="${ALL_SKILLS},${ENV_SKILLS}"
  else
    ALL_SKILLS="${ENV_SKILLS}"
  fi
fi

# If no skills specified, exit early
if [ -z "${ALL_SKILLS}" ]; then
  echo "No skills specified. Skipping skill installation."
  echo "To install skills, set 'skills' option or DUPLO_AI_SKILLS environment variable."
  exit 0
fi

# Convert comma-separated list to array
IFS=',' read -ra SKILL_ARRAY <<< "${ALL_SKILLS}"

# Install each skill
INSTALLED_COUNT=0
FAILED_COUNT=0

for SKILL in "${SKILL_ARRAY[@]}"; do
  # Trim whitespace
  SKILL="$(echo "${SKILL}" | xargs)"
  
  if [ -z "${SKILL}" ]; then
    continue
  fi
  
  echo ""
  echo "Installing skill: ${SKILL}"
  
  if duplo-skills --dir "${SKILLS_DIR}" --skill "${SKILL}"; then
    ((INSTALLED_COUNT+=1))
  else
    echo "⚠ Failed to install skill: ${SKILL}"
    ((FAILED_COUNT+=1))
  fi
done

echo ""
echo "========================================"
echo "Copilot skills installation complete"
echo "========================================"
echo "Installed: ${INSTALLED_COUNT}"
echo "Failed: ${FAILED_COUNT}"
echo "Location: ${SKILLS_DIR}"
echo ""

if [ ${INSTALLED_COUNT} -gt 0 ]; then
  echo "✓ GitHub Copilot skills are ready to use"
fi

echo "GitHub feature configuration complete!"
