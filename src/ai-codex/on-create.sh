#!/usr/bin/env bash
set -e

echo "Installing Codex skills..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"

# Load feature configuration
if [ -f /usr/local/etc/ai-codex-feature.conf ]; then
  source /usr/local/etc/ai-codex-feature.conf
fi

# Skills directory for Codex (user scope)
# Default CODEX_HOME to ~/.codex if not set
CODEX_HOME="${CODEX_HOME:-${USER_HOME}/.codex}"
SKILLS_DIR="${CODEX_HOME}/skills"
mkdir -p "${CODEX_HOME}" "${SKILLS_DIR}"

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
echo "Skills installation complete"
echo "========================================"
echo "Installed: ${INSTALLED_COUNT}"
echo "Failed: ${FAILED_COUNT}"
echo "Location: ${SKILLS_DIR}"
echo ""

if [ ${INSTALLED_COUNT} -gt 0 ]; then
  echo "✓ Codex skills are ready to use"
fi
