#!/usr/bin/env bash
set -e

echo "Installing Claude Code AI..."
echo "================================================"

# Install Claude Code CLI globally
echo ""
echo "Step 1: Installing @anthropic-ai/claude-code globally..."
npm install -g @anthropic-ai/claude-code
echo "✓ npm install complete"

# Verify installation
echo ""
echo "Step 2: Verifying Claude Code CLI installation..."
if command -v claude &> /dev/null; then
  echo "✓ claude command found in PATH"
  CLAUDE_VERSION=$(claude --version 2>&1 || echo "version check failed")
  echo "Version: ${CLAUDE_VERSION}"
  echo "Location: $(which claude)"
else
  echo "⚠ WARNING: Claude Code CLI installation could not be verified"
  echo "Command not found in PATH"
fi

# Copy on-create script to shared location
echo ""
echo "Step 3: Setting up on-create hook..."
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Copying on-create script to /usr/local/share/ai-claude-on-create.sh"
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/ai-claude-on-create.sh
chmod +x /usr/local/share/ai-claude-on-create.sh
echo "✓ On-create hook configured"

# Save feature options to config file for use during onCreate lifecycle hook
echo ""
echo "Step 4: Saving feature configuration..."
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/ai-claude-feature.conf
SKILLS="${SKILLS:-}"
EOF
chmod 644 /usr/local/etc/ai-claude-feature.conf
echo "Config file: /usr/local/etc/ai-claude-feature.conf"
echo "Skills option: '${SKILLS:-<none>}'"
echo "✓ Configuration saved"

echo ""
echo "================================================"
echo "✓ Claude Code AI installed successfully!"
echo "================================================"
echo ""
echo "Note: Skills will be installed during container creation (on-create hook)"
