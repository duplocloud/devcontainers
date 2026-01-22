#!/usr/bin/env bash
set -e

echo "Installing OpenAI Codex AI..."
echo "================================================"

# Install Codex CLI globally
echo ""
echo "Step 1: Installing @openai/codex globally..."
npm install -g @openai/codex
echo "✓ npm install complete"

# Verify installation
echo ""
echo "Step 2: Verifying Codex CLI installation..."
if command -v codex &> /dev/null; then
  echo "✓ codex command found in PATH"
  CODEX_VERSION=$(codex --version 2>&1 || echo "version check failed")
  echo "Version: ${CODEX_VERSION}"
  echo "Location: $(which codex)"
else
  echo "⚠ WARNING: Codex CLI installation could not be verified"
  echo "Command not found in PATH"
fi

# Copy on-create script to shared location
echo ""
echo "Step 3: Setting up on-create hook..."
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Copying on-create script to /usr/local/share/ai-codex-on-create.sh"
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/ai-codex-on-create.sh
chmod +x /usr/local/share/ai-codex-on-create.sh
echo "✓ On-create hook configured"

# Save feature options to config file for use during onCreate lifecycle hook
echo ""
echo "Step 4: Saving feature configuration..."
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/ai-codex-feature.conf
SKILLS="${SKILLS:-}"
EOF
chmod 644 /usr/local/etc/ai-codex-feature.conf
echo "Config file: /usr/local/etc/ai-codex-feature.conf"
echo "Skills option: '${SKILLS:-<none>}'"
echo "✓ Configuration saved"

echo ""
echo "================================================"
echo "✓ OpenAI Codex AI installed successfully!"
echo "================================================"
echo ""
echo "Note: Skills will be installed during container creation (on-create hook)"
