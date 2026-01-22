#!/usr/bin/env bash
set -e

echo "Configuring git..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Create user-specific gitignore if it doesn't exist
GITIGNORE_FILE="${USER_HOME}/.gitignore"
if [ ! -f "$GITIGNORE_FILE" ]; then
  echo "Creating global gitignore at: $GITIGNORE_FILE"
  cat <<EOF > "$GITIGNORE_FILE"
.DS_Store
*.log
*.tmp
.env.local
.env
EOF
  chmod 644 "$GITIGNORE_FILE"
fi

echo "Git configuration complete!"
