#!/usr/bin/env bash
set -e

echo "Installing Claude Code skills..."
echo "================================================"

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"
echo "User: ${USER_NAME}"
echo "Home directory: ${USER_HOME}"

# Load feature configuration
echo ""
echo "Loading feature configuration..."
if [ -f /usr/local/etc/ai-claude-feature.conf ]; then
  source /usr/local/etc/ai-claude-feature.conf
  echo "✓ Configuration loaded from /usr/local/etc/ai-claude-feature.conf"
else
  echo "⚠ Configuration file not found, using defaults"
fi

# Skills directory for Claude Code (user scope)
echo ""
echo "Setting up skills directory..."
SKILLS_DIR="${USER_HOME}/.claude/skills"
echo "Skills directory: ${SKILLS_DIR}"
mkdir -p "${USER_HOME}/.claude" "${SKILLS_DIR}"
echo "✓ Directory created"

# Get skills from option
echo ""
echo "Resolving skills to install..."
FEATURE_SKILLS="${SKILLS:-}"
echo "Skills from feature option: '${FEATURE_SKILLS:-<none>}'"

# Get skills from environment variable
ENV_SKILLS="${DUPLO_AI_SKILLS:-}"
echo "Skills from DUPLO_AI_SKILLS env: '${ENV_SKILLS:-<none>}'"

# Merge skills from both sources
ALL_SKILLS=""
if [ -n "${FEATURE_SKILLS}" ]; then
  ALL_SKILLS="${FEATURE_SKILLS}"
fi
if [ -n "${ENV_SKILLS}" ]; then
  if [ -n "${ALL_SKILLS}" ]; then
    ALL_SKILLS="${ALL_SKILLS},${ENV_SKILLS}"
    echo "Merged skills from both sources"
  else
    ALL_SKILLS="${ENV_SKILLS}"
  fi
fi
echo "Final skills list: '${ALL_SKILLS:-<none>}'"

# If no skills specified, exit early
if [ -z "${ALL_SKILLS}" ]; then
  echo ""
  echo "================================================"
  echo "No skills specified. Skipping skill installation."
  echo "================================================"
  echo ""
  echo "To install skills, set 'skills' option or DUPLO_AI_SKILLS environment variable."
  echo "Example: \"skills\": \"tf-module,api-design\""
  exit 0
fi

# Convert comma-separated list to array
echo ""
echo "Parsing skills list..."
IFS=',' read -ra SKILL_ARRAY <<< "${ALL_SKILLS}"
echo "Found ${#SKILL_ARRAY[@]} skill(s) to install"

# Install each skill
echo ""
echo "================================================"
echo "Starting skill installation..."
echo "================================================"
INSTALLED_COUNT=0
FAILED_COUNT=0

for SKILL in "${SKILL_ARRAY[@]}"; do
  # Trim whitespace
  SKILL="$(echo "${SKILL}" | xargs)"
  
  if [ -z "${SKILL}" ]; then
    echo "Skipping empty skill entry"
    continue
  fi
  
  echo ""
  echo "[$(date +'%H:%M:%S')] Installing skill: ${SKILL}"
  echo "Target directory: ${SKILLS_DIR}"
  
  if duplo-skills --dir "${SKILLS_DIR}" --skill "${SKILL}"; then
    ((INSTALLED_COUNT+=1))
    echo "✓ Successfully installed: ${SKILL}"
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
  echo "✓ Claude Code skills are ready to use"
fi
