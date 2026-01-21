#!/usr/bin/env bash
set -e

echo "Installing AI base dependencies..."

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install Node.js if not already present
bash "${SCRIPT_DIR}/scripts/install-nodejs.sh"

# Copy duplo-skills package to a temp location for npm install
DUPLO_SKILLS_DIR="${SCRIPT_DIR}/scripts/duplo-skills"
TEMP_INSTALL_DIR="/tmp/duplo-skills-install"

rm -rf "${TEMP_INSTALL_DIR}"
mkdir -p "${TEMP_INSTALL_DIR}"
cp -r "${DUPLO_SKILLS_DIR}"/* "${TEMP_INSTALL_DIR}/"

# Install duplo-skills globally as root
cd "${TEMP_INSTALL_DIR}"
npm install -g .

# Cleanup
rm -rf "${TEMP_INSTALL_DIR}"

# Verify installation
if command -v duplo-skills &> /dev/null; then
  echo "✓ duplo-skills installed successfully"
  duplo-skills --version
else
  echo "⚠ duplo-skills installation could not be verified"
fi

echo "AI base dependencies installed successfully!"
