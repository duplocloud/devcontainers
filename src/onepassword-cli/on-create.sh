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

# Check if feature is enabled
if [ "${OP_ENABLED:-true}" = "false" ]; then
    echo "1Password CLI feature is disabled, skipping configuration."
    exit 0
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
  # Check if OP_ACCOUNT is set in environment first (takes precedence)
  local account="${OP_ACCOUNT:-${ACCOUNT:-my.1password.com}}"
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

  # Use timeout to prevent hanging when no one is at the terminal
  if timeout 15 bash -c "$cmd" </dev/null; then
    echo "Account added successfully"
    return 0
  else
    echo "Warning: Failed to add account"
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
    # Connect requires JSON format - set globally
    export OP_FORMAT="json"
    # Persist to bashrc
    local bashrc="${USER_HOME}/.bashrc"
    if ! grep -q "^export OP_FORMAT=" "$bashrc" 2>/dev/null; then
      echo 'export OP_FORMAT="json"' >> "$bashrc"
      echo "OP_FORMAT=json persisted to .bashrc"
    fi
    return 0
  fi

  # Check for Service Account Token (works in any terminal type)
  if [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then
    echo "1Password Service Account Token detected"
    OP_AUTH_METHOD="service-account"
    OP_AUTHENTICATED="true"
    # Service accounts require JSON format - set globally
    export OP_FORMAT="json"
    # Persist to bashrc
    local bashrc="${USER_HOME}/.bashrc"
    if ! grep -q "^export OP_FORMAT=" "$bashrc" 2>/dev/null; then
      echo 'export OP_FORMAT="json"' >> "$bashrc"
      echo "OP_FORMAT=json persisted to .bashrc"
    fi
    return 0
  fi

  # Check for Desktop App agent socket (Linux only - works in any terminal type)
  if [ -S "$HOME/.1password/agent.sock" ]; then
    echo "1Password Desktop App agent socket detected"
    OP_AUTH_METHOD="desktop"
    OP_AUTHENTICATED="true"
    return 0
  fi

  # Check if interactive authentication is disabled by configuration FIRST
  # This prevents hanging in test environments or CI/CD pipelines
  if [ "$INTERACTIVE" != "true" ]; then
    echo "Interactive authentication disabled by configuration (interactive=false)"
    return 1
  fi

  # Session-based authentication requires interactive terminal
  if ! is_terminal_interactive; then
    echo "Non-interactive terminal detected, skipping session-based authentication"
    return 1
  fi

  # Get account shorthand
  # Check if OP_ACCOUNT is already set in environment (takes precedence)
  local account="${OP_ACCOUNT:-${ACCOUNT:-my.1password.com}}"
  OP_ACCOUNT_SHORTHAND=$(get_account_shorthand)
  
  # Check if account exists
  if ! account_exists "$account" "$OP_ACCOUNT_SHORTHAND"; then
    echo "1Password account not found, adding: $OP_ACCOUNT_SHORTHAND"
    add_account "$OP_ACCOUNT_SHORTHAND" || return 1
  else
    echo "1Password account found: $OP_ACCOUNT_SHORTHAND"
  fi

  # Sign in via the reloadable session script
  if op-session-reload; then
    OP_AUTH_METHOD="session"
    OP_AUTHENTICATED="true"
    return 0
  fi

  return 1
}

# Configure vault environment variable
function configure_vault() {
  local bashrc="${USER_HOME}/.bashrc"
  
  # Handle OP_VAULT (vault ID) - env takes precedence over vaultID option
  if [ -z "${OP_VAULT:-}" ]; then
    # No env var, check for vaultID option from feature config
    if [ -n "${VAULTID:-}" ]; then
      export OP_VAULT="$VAULTID"
      echo "Using vault ID from feature config: $OP_VAULT"
      # Persist to bashrc
      if ! grep -q "^export OP_VAULT=" "$bashrc" 2>/dev/null; then
        echo "export OP_VAULT=\"${OP_VAULT}\"" >> "$bashrc"
      fi
    fi
  else
    echo "Using existing OP_VAULT from environment: $OP_VAULT"
  fi
  
  # Handle OP_VAULT_NAME (vault name) - env takes precedence over vault option
  if [ -z "${OP_VAULT_NAME:-}" ]; then
    # No env var, check for vault option from feature config
    if [ -n "${VAULT:-}" ]; then
      export OP_VAULT_NAME="$VAULT"
      echo "Using vault name from feature config: $OP_VAULT_NAME"
      # Persist to bashrc
      if ! grep -q "^export OP_VAULT_NAME=" "$bashrc" 2>/dev/null; then
        echo "export OP_VAULT_NAME=\"${OP_VAULT_NAME}\"" >> "$bashrc"
      fi
    fi
  else
    echo "Using existing OP_VAULT_NAME from environment: $OP_VAULT_NAME"
  fi
  
  # Try to get vault ID from name if we have name but no ID (desktop/session only)
  if [ -z "${OP_VAULT:-}" ] && [ -n "${OP_VAULT_NAME:-}" ]; then
    if [ "$OP_AUTHENTICATED" = "true" ]; then
      if [ "$OP_AUTH_METHOD" = "desktop" ] || [ "$OP_AUTH_METHOD" = "session" ]; then
        echo "Attempting to resolve vault ID for: $OP_VAULT_NAME"
        local vault_id
        vault_id=$(op vault get "$OP_VAULT_NAME" --format json 2>/dev/null | jq -r '.id' 2>/dev/null || echo "")
        
        if [ -n "$vault_id" ] && [ "$vault_id" != "null" ]; then
          export OP_VAULT="$vault_id"
          echo "Resolved vault ID: $OP_VAULT"
          # Persist to bashrc
          if ! grep -q "^export OP_VAULT=" "$bashrc" 2>/dev/null; then
            echo "export OP_VAULT=\"${OP_VAULT}\"" >> "$bashrc"
          fi
        else
          echo "Warning: Could not resolve vault ID for '$OP_VAULT_NAME'"
        fi
      fi
    fi
  fi
  
  # Validate that at least one vault identifier is set
  if [ -z "${OP_VAULT:-}" ] && [ -z "${OP_VAULT_NAME:-}" ]; then
    echo "Warning: No vault configured!"
    echo "Set OP_VAULT (vault ID) or OP_VAULT_NAME (vault name) environment variable,"
    echo "or configure 'vaultID' or 'vault' option in devcontainer feature."
    echo "SSH secrets will be accessed from the default vault (may fail)."
    return 1
  fi
  
  return 0
}

# Get vault parameter for op commands
function get_vault_param() {
  # Connect and service accounts require --vault parameter
  if [ "$OP_AUTH_METHOD" = "connect" ] || [ "$OP_AUTH_METHOD" = "service-account" ]; then
    # Prefer vault ID over name
    if [ -n "${OP_VAULT:-}" ]; then
      echo "--vault $OP_VAULT"
    elif [ -n "${OP_VAULT_NAME:-}" ]; then
      echo "--vault $OP_VAULT_NAME"
    else
      echo ""
    fi
  else
    echo ""
  fi
}

# Check if SSH agent is available and working
function is_ssh_agent_available() {
  # No SSH_AUTH_SOCK means no agent
  if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    return 1
  fi
  
  # Try to list keys from agent
  if ssh-add -l &>/dev/null; then
    return 0
  fi
  
  # Agent socket exists but ssh-add failed
  return 1
}

# Fetch and configure SSH key from 1Password
function configure_ssh_key() {
  local secret_name="$1"
  local ssh_dir="${USER_HOME}/.ssh"
  
  # Sanitize secret name for filename (replace spaces with underscores)
  local file_name="${secret_name// /_}"
  local private_key_path="${ssh_dir}/${file_name}"
  local public_key_path="${ssh_dir}/${file_name}.pub"
  
  # Determine what keys we need to download
  local download_private=false
  local download_public=false
  
  if is_ssh_agent_available; then
    echo "SSH agent is available for: $secret_name"
    # Only need public key when agent is available
    if [ ! -f "$public_key_path" ]; then
      download_public=true
    fi
  else
    echo "SSH agent not available, will download keys for: $secret_name"
    # Need both keys when no agent
    if [ ! -f "$private_key_path" ]; then
      download_private=true
    fi
    if [ ! -f "$public_key_path" ]; then
      download_public=true
    fi
  fi
  
  # Determine vault for op read (prefer ID over name)
  local vault_for_read=""
  if [ -n "${OP_VAULT:-}" ]; then
    vault_for_read="$OP_VAULT"
  elif [ -n "${OP_VAULT_NAME:-}" ]; then
    vault_for_read="$OP_VAULT_NAME"
  fi
  
  # Get vault parameter for op item commands
  local vault_param
  vault_param=$(get_vault_param)
  
  # Download private key if needed
  if [ "$download_private" = "true" ]; then
    echo "Fetching private key: $secret_name"
    local private_key_ref="op://${vault_for_read}/${secret_name}/private key?ssh-format=openssh"
    echo "Debug: op read reference: $private_key_ref"
    if ! op read "$private_key_ref" > "$private_key_path" 2>/dev/null; then
      echo "Warning: Failed to fetch private key for '$secret_name'"
      rm -f "$private_key_path"
      return 1
    fi
    chmod 600 "$private_key_path"
    echo "Private key downloaded: $file_name"
  fi
  
  # Download public key if needed
  if [ "$download_public" = "true" ]; then
    echo "Fetching public key: $secret_name"
    local public_key_ref="op://${vault_for_read}/${secret_name}/public key"
    echo "Debug: op read reference: $public_key_ref"
    if ! op read "$public_key_ref" > "$public_key_path" 2>/dev/null; then
      echo "Warning: Failed to fetch public key for '$secret_name'"
      rm -f "$public_key_path"
      return 1
    fi
    chmod 644 "$public_key_path"
    echo "Public key downloaded: $file_name"
  fi
  
  
  # Check for host configuration
  local host
  host=$(op item get "$secret_name" --format json $vault_param 2>/dev/null | jq -r '.fields[] | select(.label == "host") | .value' 2>/dev/null || echo "")
  
  if [ -n "$host" ] && [ "$host" != "null" ]; then
    local has_agent=false
    if is_ssh_agent_available; then
      has_agent=true
    fi
    configure_ssh_host "$host" "$file_name" "$secret_name" "$has_agent"
  fi
  
  return 0
}

# Configure SSH host entry
function configure_ssh_host() {
  local host="$1"
  local key_name="$2"
  local secret_name="$3"
  local has_agent="$4"
  local ssh_config="${USER_HOME}/.ssh/config"
  
  # Check if config file already exists and has content
  if [ -f "$ssh_config" ] && [ -s "$ssh_config" ]; then
    echo "Warning: SSH config file already exists with content, will not modify: $ssh_config"
    echo "Please manually add configuration for host: $host"
    return 0
  fi
  
  # Create config file if it doesn't exist
  if [ ! -f "$ssh_config" ]; then
    touch "$ssh_config"
    chmod 600 "$ssh_config"
  fi
  
  echo "Adding SSH config entry for: $host"
  
  # Get vault parameter for op item commands
  local vault_param
  vault_param=$(get_vault_param)
  
  # Get secret details
  local secret_json
  secret_json=$(op item get "$secret_name" --format json $vault_param 2>/dev/null || echo "{}")
  
  # Get username from secret if available
  local username
  username=$(echo "$secret_json" | jq -r '.fields[] | select(.label == "username") | .value' 2>/dev/null || echo "")
  
  # Get port from secret if available
  local port
  port=$(echo "$secret_json" | jq -r '.fields[] | select(.label == "port") | .value' 2>/dev/null || echo "")
  
  # Build SSH config entry
  cat <<EOF >> "$ssh_config"

Host ${host}
    HostName ${host}
EOF
  
  # Add Port if specified
  if [ -n "$port" ] && [ "$port" != "null" ]; then
    echo "    Port ${port}" >> "$ssh_config"
  fi
  
  # Add User if username was found
  if [ -n "$username" ] && [ "$username" != "null" ]; then
    echo "    User ${username}" >> "$ssh_config"
  fi
  
  # Add IdentityFile - public key if agent available, private key otherwise
  if [ "$has_agent" = "true" ]; then
    # Agent available: use public key so agent can lookup private key
    echo "    IdentityFile ~/.ssh/${key_name}.pub" >> "$ssh_config"
    if [ "${SSH_AUTH_SOCK:-}" = "$HOME/.1password/agent.sock" ]; then
      echo "1Password agent detected for SSH host configuration, we must be on Linux"
      echo "    IdentityFile ~/.ssh/${key_name}.pub" >> "$ssh_config"
      echo "    IdentityAgent \"${SSH_AUTH_SOCK}\"" >> "$ssh_config"
    else 
      echo "SSH agent is available, no need to point to it"
      #   echo "    IdentityAgent \"${SSH_AUTH_SOCK}\"" >> "$ssh_config"
    fi
  else
    # No agent: use private key directly
    echo "    IdentityFile ~/.ssh/${key_name}" >> "$ssh_config"
    echo "    IdentitiesOnly yes" >> "$ssh_config"
  fi
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

# Source the session file so subsequent op calls in this script have the token
if [ -f /tmp/op-session.env ]; then
  source /tmp/op-session.env
fi

# Wire .bashrc to source the ephemeral session file on every new shell (idempotent)
bashrc="${USER_HOME}/.bashrc"
session_env_line='[ -f /tmp/op-session.env ] && source /tmp/op-session.env'
if ! grep -qF "$session_env_line" "$bashrc" 2>/dev/null; then
  echo "$session_env_line" >> "$bashrc"
  echo "Added /tmp/op-session.env sourcing to .bashrc"
fi

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
