#!/bin/bash
set -e

echo "Installing Terraform DuploCloud helpers..."

# Install fzf dependency
apt-get update
apt-get install -y --no-install-recommends fzf
apt-get clean
rm -rf /var/lib/apt/lists/*

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_NAME="${_REMOTE_USER:-root}"

# Install tf.sh to a standard location
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p /usr/local/share/duplocloud
cp "${FEATURE_DIR}/tf.sh" /usr/local/share/duplocloud/tf.sh
chmod 644 /usr/local/share/duplocloud/tf.sh

# Source tf.sh in bashrc for interactive shells
if [ -f "$USER_HOME/.bashrc" ] && ! grep -q "source /usr/local/share/duplocloud/tf.sh" "$USER_HOME/.bashrc"; then
    cat >> "$USER_HOME/.bashrc" <<'EOF'

# Source DuploCloud Terraform helpers
source /usr/local/share/duplocloud/tf.sh
EOF
fi

# Also add to /etc/bash.bashrc for system-wide availability
if ! grep -q "source /usr/local/share/duplocloud/tf.sh" /etc/bash.bashrc; then
    cat >> /etc/bash.bashrc <<'EOF'

# Source DuploCloud Terraform helpers
source /usr/local/share/duplocloud/tf.sh
EOF
fi

# Add to zshrc if zsh is available
if [ -d "/etc/zsh" ]; then
    if [ ! -f "$USER_HOME/.zshrc" ]; then
        touch "$USER_HOME/.zshrc"
        chown "$USER_NAME:$USER_NAME" "$USER_HOME/.zshrc" 2>/dev/null || true
    fi
    if ! grep -q "source /usr/local/share/duplocloud/tf.sh" "$USER_HOME/.zshrc"; then
        cat >> "$USER_HOME/.zshrc" <<'EOF'

# Source DuploCloud Terraform helpers
source /usr/local/share/duplocloud/tf.sh
EOF
    fi
fi

echo "Terraform DuploCloud helpers installed successfully!"
