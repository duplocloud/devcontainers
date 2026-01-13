#!/usr/bin/env bash
set -e

echo "Configuring git..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"

# Load feature configuration
if [ -f /usr/local/etc/git-feature.conf ]; then
  source /usr/local/etc/git-feature.conf
fi

# Helper function to ensure a line exists in a file
function ensure_line() {
  local file="$1"
  local line="$2"

  touch "$file"
  if ! grep -qxF "$line" "$file"; then
    echo "$line" >> "$file"
  fi
}

# Ensure .ssh directory exists with proper permissions
mkdir -p "${USER_HOME}/.ssh"
chmod 700 "${USER_HOME}/.ssh"

# Configure git user.name
# Priority: feature option > environment variable
git_user="${USERNAME:-${GIT_USER:-}}"
if [ -n "$git_user" ]; then
  echo "Setting git user.name to: $git_user"
  git config --global user.name "$git_user"
fi

# Configure git user.email
# Priority: feature option > environment variable
git_email="${USEREMAIL:-${GIT_EMAIL:-}}"
if [ -n "$git_email" ]; then
  echo "Setting git user.email to: $git_email"
  git config --global user.email "$git_email"
fi

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

# Configure git to use the global gitignore
git config --global core.excludesfile "$GITIGNORE_FILE"

# Add workspace to git safe directory list
if [ -n "${CONTAINER_WORKSPACE_FOLDER:-}" ]; then
  echo "Adding workspace to git safe.directory: $CONTAINER_WORKSPACE_FOLDER"
  git config --global --add safe.directory "$CONTAINER_WORKSPACE_FOLDER"
fi

# Also add common workspace paths
git config --global --add safe.directory "/workspaces/*"

# Configure signing key if provided
signing_key="${SIGNINGKEY:-}"

if [ -n "$signing_key" ]; then
  signing_key_path="${USER_HOME}/.ssh/${signing_key}"
  
  if [ -f "$signing_key_path" ]; then
    echo "Configuring git signing key: $signing_key_path"
    git config --global user.signingkey "$signing_key_path"
    git config --global gpg.format ssh
    git config --global commit.gpgsign true
  else
    echo "Warning: Signing key not found at $signing_key_path, skipping signing configuration"
  fi
fi

# Provider-specific configuration (placeholder for future implementation)
case "$PROVIDER" in
  github)
    echo "GitHub provider configuration: to be implemented"
    ;;
  gitlab)
    echo "GitLab provider configuration: to be implemented"
    ;;
  bitbucket)
    echo "Bitbucket provider configuration: to be implemented"
    ;;
  azuredevops)
    echo "Azure DevOps provider configuration: to be implemented"
    ;;
  none|*)
    # No provider-specific configuration
    ;;
esac

echo "Git configuration complete!"
