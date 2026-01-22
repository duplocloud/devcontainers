#!/usr/bin/env bash
set -e

echo "Installing Claude Code AI..."

# Install Claude Code CLI globally
echo "Installing @anthropic-ai/claude-code..."
npm install -g @anthropic-ai/claude-code

# Verify installation
if command -v claude &> /dev/null; then
  echo "✓ Claude Code CLI installed successfully"
  claude --version || true
else
  echo "⚠ Claude Code CLI installation could not be verified"
fi

# Copy on-create script to shared location
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/ai-claude-on-create.sh
chmod +x /usr/local/share/ai-claude-on-create.sh

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/ai-claude-feature.conf
SKILLS="${SKILLS:-}"
EOF
chmod 644 /usr/local/etc/ai-claude-feature.conf

echo "Claude Code AI installed successfully!"
echo ""
echo "Note: Skills will be installed during container creation (on-create hook)"
