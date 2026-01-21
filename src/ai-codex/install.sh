#!/usr/bin/env bash
set -e

echo "Installing OpenAI Codex AI..."

# Install Codex CLI globally
echo "Installing @openai/codex..."
npm install -g @openai/codex

# Verify installation
if command -v codex &> /dev/null; then
  echo "✓ Codex CLI installed successfully"
  codex --version || true
else
  echo "⚠ Codex CLI installation could not be verified"
fi

# Copy on-create script to shared location
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/ai-codex-on-create.sh
chmod +x /usr/local/share/ai-codex-on-create.sh

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/ai-codex-feature.conf
SKILLS="${SKILLS:-}"
EOF
chmod 644 /usr/local/etc/ai-codex-feature.conf

echo "OpenAI Codex AI installed successfully!"
echo ""
echo "Note: Skills will be installed during container creation (on-create hook)"
