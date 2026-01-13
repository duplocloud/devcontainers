#!/usr/bin/env bash
set -e

echo "Configuring 1Password CLI..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"

# Load feature configuration
if [ -f /usr/local/etc/onepassword-feature.conf ]; then
  source /usr/local/etc/onepassword-feature.conf
fi

# Ensure .ssh directory exists with proper permissions
mkdir -p "${USER_HOME}/.ssh"
chmod 700 "${USER_HOME}/.ssh"

# Track authentication status
OP_AUTHENTICATED="false"
OP_AUTH_METHOD=""
OP_ACCOUNT_SHORTHAND=""

# Extract subdomain from account URL for shorthand
function get_account_shorthand() {
  local account="${ACCOUNT:-my.1password.com}"
  # Extract subdomain (everything before the first dot)
  echo "${account%%.*}"
}

# Check if terminal is interactive
function is_terminal_interactive() {
  # Check if stdin is a terminal and stdout is a terminal
  [ -t 0 ] && [ -t 1 ]
}

# Check if account exists in op account list
function account_exists() {
  local account="$1"
  local shorthand="$2"
  
  # Check by URL or shorthand
  op account list 2>/dev/null | grep -qE "(${account}|${shorthand})"
}

# Add 1Password account
function add_account() {
  local account="${ACCOUNT:-my.1password.com}"
  local shorthand="$1"
  local email="${USEREMAIL:-}"
  
  echo "Adding 1Password account: $account (shorthand: $shorthand)"
  
  local cmd="op account add --address '$account' --shorthand '$shorthand'"
  
  if [ -n "$email" ]; then
    cmd="$cmd --email '$email'"
  fi
  
  if eval "$cmd"; then
    echo "Account added successfully"
    return 0
  else
    echo "Warning: Failed to add account"
    return 1
  fi
}

# Sign in to 1Password account
function signin_account() {
  local shorthand="$1"
  
  echo "Signing in to 1Password account: $shorthand"
  
  if eval "$(op signin --account '$shorthand')"; then
    echo "Successfully signed in"
    return 0
  else
    echo "Warning: Failed to sign in"
    return 1
  fi
}

# Check for authentication methods
function check_authentication() {
  # Check for Connect server (works in any terminal type)
  if [ -n "${OP_CONNECT_HOST:-}" ] && [ -n "${OP_CONNECT_TOKEN:-}" ]; then
    echo "1Password Connect environment detected"
    OP_AUTH_METHOD="connect"
    OP_AUTHENTICATED="true"
    return 0
  fi

  # Check for Service Account Token (works in any terminal type)
  if [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then
    echo "1Password Service Account Token detected"
    OP_AUTH_METHOD="service-account"
    OP_AUTHENTICATED="true"
    return 0
  fi

  # Session-based authentication requires interactive terminal
  if ! is_terminal_interactive; then
    echo "Non-interactive terminal detected, skipping session-based authentication"
    return 1
  fi
  
  if [ "$DISABLEINTERACTIVE" = "true" ]; then
    echo "Interactive authentication disabled by configuration"
    return 1
  fi

  # Get account shorthand
  OP_ACCOUNT_SHORTHAND=$(get_account_shorthand)
  local account="${ACCOUNT:-my.1password.com}"
  
  # Check if account exists
  if account_exists "$account" "$OP_ACCOUNT_SHORTHAND"; then
    echo "1Password account found: $OP_ACCOUNT_SHORTHAND"
    # Account exists, just sign in
    if signin_account "$OP_ACCOUNT_SHORTHAND"; then
      OP_AUTH_METHOD="session"
      OP_AUTHENTICATED="true"
      return 0
    fi
  else
    # Account doesn't exist, add it then sign in
    echo "1Password account not found, adding: $OP_ACCOUNT_SHORTHAND"
    if add_account "$OP_ACCOUNT_SHORTHAND"; then
      if signin_account "$OP_ACCOUNT_SHORTHAND"; then
        OP_AUTH_METHOD="session"
        OP_AUTHENTICATED="true"
        return 0
      fi
    fi
  fi

  return 1
}

# Configure vault environment variable
function configure_vault() {
  if [ -n "${VAULT:-}" ] && [ "$OP_AUTHENTICATED" = "true" ]; then
    echo "Configuring vault: $VAULT"
    vault_id=$(op vault get "$VAULT" --format json 2>/dev/null | jq -r '.id' 2>/dev/null || echo "")
    
    if [ -n "$vault_id" ]; then
      export OP_VAULT="$vault_id"
      export OP_VAULT_NAME="$VAULT"
      echo "Vault ID: $vault_id"
    else
      echo "Warning: Could not retrieve vault ID for '$VAULT'"
    fi
  fi
}

# Fetch and configure SSH key from 1Password
function configure_ssh_key() {
  local secret_name="$1"
  local ssh_dir="${USER_HOME}/.ssh"
  
  # Sanitize secret name for filename (replace spaces with underscores)
  local file_name="${secret_name// /_}"
  local private_key_path="${ssh_dir}/${file_name}"
  local public_key_path="${ssh_dir}/${file_name}.pub"
  
  # Skip if key already exists
  if [ -f "$private_key_path" ]; then
    echo "SSH key already exists: $private_key_path"
    return 0
  fi
  
  echo "Fetching SSH key: $secret_name"
  
  # Determine vault path prefix
  local vault_prefix=""
  if [ -n "${OP_VAULT_NAME:-}" ]; then
    vault_prefix="${OP_VAULT_NAME}/"
  fi
  
  # Fetch private key
  if ! op read "op://${vault_prefix}${secret_name}/private key?ssh-format=openssh" > "$private_key_path" 2>/dev/null; then
    echo "Warning: Failed to fetch private key for '$secret_name'"
    rm -f "$private_key_path"
    return 1
  fi
  chmod 600 "$private_key_path"
  
  # Fetch public key
  if ! op read "op://${vault_prefix}${secret_name}/public key" > "$public_key_path" 2>/dev/null; then
    echo "Warning: Failed to fetch public key for '$secret_name'"
    rm -f "$public_key_path"
    return 1
  fi
  chmod 644 "$public_key_path"
  
  echo "SSH key configured: $file_name"
  
  # Check for host configuration
  local host
  host=$(op item get "$secret_name" --format json 2>/dev/null | jq -r '.fields[] | select(.label == "host") | .value' 2>/dev/null || echo "")
  
  if [ -n "$host" ] && [ "$host" != "null" ]; then
    configure_ssh_host "$host" "$file_name"
  fi
  
  return 0
}

# Configure SSH host entry
function configure_ssh_host() {
  local host="$1"
  local key_name="$2"
  local ssh_config="${USER_HOME}/.ssh/config"
  
  # Create config file if it doesn't exist
  if [ ! -f "$ssh_config" ]; then
    touch "$ssh_config"
    chmod 600 "$ssh_config"
  fi
  
  # Check if host entry already exists
  if grep -q "^Host ${host}$" "$ssh_config" 2>/dev/null; then
    echo "SSH config entry for '$host' already exists"
    return 0
  fi
  
  echo "Adding SSH config entry for: $host"
  cat <<EOF >> "$ssh_config"

Host ${host}
    HostName ${host}
    User git
    IdentityFile ~/.ssh/${key_name}
    IdentitiesOnly yes
EOF
}

# Search for SSH secrets by tag
function find_ssh_secrets_by_tag() {
  local tags="$1"
  local secrets=()
  
  # Search for items with the specified tags
  local items
  items=$(op item list --tags "$tags" --format json 2>/dev/null || echo "[]")
  
  if [ "$items" = "[]" ]; then
    echo ""
    return
  fi
  
  # Extract item titles
  echo "$items" | jq -r '.[].title'
}

# Configure auto SSH
function configure_auto_ssh() {
  if [ "$AUTOSSH" != "true" ]; then
    return 0
  fi
  
  if [ "$OP_AUTHENTICATED" != "true" ]; then
    echo "Warning: Cannot configure auto SSH without authentication"
    return 1
  fi
  
  echo "Configuring automatic SSH keys..."
  
  # Validate that only one method is used
  if [ -n "${SSHSECRETNAMES:-}" ] && [ -n "${SSHSECRETTAGS:-}" ] && [ "$SSHSECRETTAGS" != "ssh" ]; then
    echo "Error: Cannot specify both sshSecretNames and sshSecretTags"
    return 1
  fi
  
  local secrets=()
  
  if [ -n "${SSHSECRETNAMES:-}" ]; then
    # Parse comma-separated list of secret names
    IFS=',' read -ra secrets <<< "$SSHSECRETNAMES"
  else
    # Search by tags
    local tag_results
    tag_results=$(find_ssh_secrets_by_tag "${SSHSECRETTAGS:-ssh}")
    
    if [ -n "$tag_results" ]; then
      while IFS= read -r line; do
        secrets+=("$line")
      done <<< "$tag_results"
    fi
  fi
  
  if [ ${#secrets[@]} -eq 0 ]; then
    echo "No SSH secrets found"
    return 0
  fi
  
  echo "Found ${#secrets[@]} SSH secret(s) to configure"
  
  for secret in "${secrets[@]}"; do
    # Trim whitespace
    secret=$(echo "$secret" | xargs)
    if [ -n "$secret" ]; then
      configure_ssh_key "$secret" || true
    fi
  done
  
  echo "SSH key configuration complete"
}

# Ensure known_hosts file exists
function ensure_known_hosts() {
  local known_hosts="${USER_HOME}/.ssh/known_hosts"
  
  if [ ! -f "$known_hosts" ]; then
    touch "$known_hosts"
    chmod 644 "$known_hosts"
  fi
}

# Main execution
check_authentication || true

if [ "$OP_AUTHENTICATED" = "true" ]; then
  echo "1Password authenticated via: $OP_AUTH_METHOD"
  configure_vault
  ensure_known_hosts
  configure_auto_ssh
else
  echo "Warning: No 1Password authentication available"
  echo "Only the CLI has been installed. To use 1Password features, configure one of:"
  echo "  - OP_CONNECT_HOST and OP_CONNECT_TOKEN environment variables"
  echo "  - OP_SERVICE_ACCOUNT_TOKEN environment variable"
  echo "  - Interactive login (if terminal is interactive)"
fi

echo "1Password CLI configuration complete!"
