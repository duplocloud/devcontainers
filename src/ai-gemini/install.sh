#!/usr/bin/env bash
set -e

echo "Installing Gemini CLI AI..."

# Install Gemini CLI globally
echo "Installing @google/gemini-cli..."
npm install -g @google/gemini-cli

# Verify installation
if command -v gemini &> /dev/null; then
  echo "✓ Gemini CLI installed successfully"
  gemini --version || true
else
  echo "⚠ Gemini CLI installation could not be verified"
fi

# Copy on-create script to shared location
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/ai-gemini-on-create.sh
chmod +x /usr/local/share/ai-gemini-on-create.sh

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/ai-gemini-feature.conf
SKILLS="${SKILLS:-}"
EOF
chmod 644 /usr/local/etc/ai-gemini-feature.conf

echo "Gemini CLI AI installed successfully!"
echo ""
echo "Note: Skills will be installed during container creation (on-create hook)"
