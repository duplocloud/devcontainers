#!/bin/bash
set -e

echo "Installing Terraform DuploCloud helpers..."

# Install tf.sh to a standard location
FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p /usr/local/share/duplocloud
cp "${FEATURE_DIR}/tf.sh" /usr/local/share/duplocloud/tf.sh
chmod 644 /usr/local/share/duplocloud/tf.sh

# Source tf.sh in bashrc for interactive shells
if ! grep -q "source /usr/local/share/duplocloud/tf.sh" /home/vscode/.bashrc; then
    cat >> /home/vscode/.bashrc <<'EOF'

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
    if [ ! -f /home/vscode/.zshrc ]; then
        touch /home/vscode/.zshrc
        chown vscode:vscode /home/vscode/.zshrc
    fi
    if ! grep -q "source /usr/local/share/duplocloud/tf.sh" /home/vscode/.zshrc; then
        cat >> /home/vscode/.zshrc <<'EOF'

# Source DuploCloud Terraform helpers
source /usr/local/share/duplocloud/tf.sh
EOF
    fi
fi

echo "Terraform DuploCloud helpers installed successfully!"
