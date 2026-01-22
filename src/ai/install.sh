#!/usr/bin/env bash
set -e

echo "Installing AI base dependencies..."
echo "================================================"

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Feature directory: ${SCRIPT_DIR}"

# Install Node.js if not already present
echo ""
echo "Step 1: Installing Node.js..."
bash "${SCRIPT_DIR}/scripts/install-nodejs.sh"
echo "✓ Node.js installation complete"

# Copy duplo-skills package to a temp location for npm install
echo ""
echo "Step 2: Preparing duplo-skills package..."
DUPLO_SKILLS_DIR="${SCRIPT_DIR}/scripts/duplo-skills"
TEMP_INSTALL_DIR="/tmp/duplo-skills-install"
echo "Source: ${DUPLO_SKILLS_DIR}"
echo "Temp location: ${TEMP_INSTALL_DIR}"

rm -rf "${TEMP_INSTALL_DIR}"
mkdir -p "${TEMP_INSTALL_DIR}"
cp -r "${DUPLO_SKILLS_DIR}"/* "${TEMP_INSTALL_DIR}/"
echo "✓ Package copied to temp location"

# Install duplo-skills globally as root from a packed tarball (avoids global symlinks to /tmp)
echo ""
echo "Step 3: Installing duplo-skills globally..."
cd "${TEMP_INSTALL_DIR}"
TARBALL="$(npm pack --silent)"
echo "Created tarball: ${TARBALL}"
echo "Installing globally with npm..."
npm install -g "${TARBALL}"
rm -f "${TARBALL}"
echo "✓ Global installation complete"

# Cleanup
echo ""
echo "Step 4: Cleaning up temporary files..."
rm -rf "${TEMP_INSTALL_DIR}"
echo "✓ Cleanup complete"

# Verify installation
echo ""
echo "Step 5: Verifying installation..."
if command -v duplo-skills &> /dev/null; then
  echo "✓ duplo-skills command found in PATH"
  DUPLO_SKILLS_VERSION=$(duplo-skills --version 2>&1 || echo "unknown")
  echo "Version: ${DUPLO_SKILLS_VERSION}"
  echo "Location: $(which duplo-skills)"
else
  echo "⚠ WARNING: duplo-skills installation could not be verified"
  echo "Command not found in PATH"
fi

echo ""
echo "================================================"
echo "✓ AI base dependencies installed successfully!"
echo "================================================"
