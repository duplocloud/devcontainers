#!/usr/bin/env bash
set -e

SESSION_ENV="/tmp/op-session.env"

# Load feature configuration (account, etc.)
if [ -f /usr/local/etc/onepassword-feature.conf ]; then
  source /usr/local/etc/onepassword-feature.conf
fi

# Connect server and service account auth don't use session tokens — skip silently
if [ -n "${OP_CONNECT_HOST:-}" ] && [ -n "${OP_CONNECT_TOKEN:-}" ]; then
  echo "1Password Connect auth detected, no session token needed."
  exit 0
fi

if [ -n "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]; then
  echo "1Password Service Account auth detected, no session token needed."
  exit 0
fi

if [ -S "${HOME}/.1password/agent.sock" ]; then
  echo "1Password Desktop App agent detected, no session token needed."
  exit 0
fi

ACCOUNT="${OP_ACCOUNT:-${ACCOUNT:-my.1password.com}}"

# Source existing session file so op whoami can use the current token
if [ -f "$SESSION_ENV" ]; then
  source "$SESSION_ENV"
fi

# Idempotency check: already authenticated and token is still valid
if op whoami --account "$ACCOUNT" &>/dev/null 2>&1; then
  echo "1Password session is already valid, skipping sign-in."
  exit 0
fi

echo "Signing in to 1Password account: $ACCOUNT"

# Get raw session token
local_passwd="${OP_PASSWD:-}"
if [ -n "$local_passwd" ]; then
  session_token=$(echo "$local_passwd" | timeout 30 op signin --account "$ACCOUNT" --raw 2>&1)
else
  session_token=$(timeout 15 op signin --account "$ACCOUNT" --raw 2>&1)
fi
signin_status=$?

if [ $signin_status -ne 0 ]; then
  echo "Error: Failed to sign in to 1Password" >&2
  echo "$session_token" >&2
  exit 1
fi

# Resolve account UUID for the session variable name
account_clean="${ACCOUNT#https://}"
account_info=$(op account list --format=json 2>/dev/null)

account_uuid=$(echo "$account_info" | jq -r --arg acct "$ACCOUNT" --arg acct_clean "$account_clean" \
  '.[] | select(.url == $acct or .url == ("https://" + $acct) or .url == $acct_clean or .url == ("https://" + $acct_clean)) | .user_uuid' 2>/dev/null | head -n 1)

# Fall back to matching by shorthand
if [ -z "$account_uuid" ] || [ "$account_uuid" = "null" ]; then
  shorthand="${ACCOUNT%%.*}"
  account_uuid=$(echo "$account_info" | jq -r --arg sh "$shorthand" \
    '.[] | select(.shorthand == $sh) | .user_uuid' 2>/dev/null | head -n 1)
fi

if [ -z "$account_uuid" ] || [ "$account_uuid" = "null" ]; then
  echo "Error: Could not determine account UUID" >&2
  exit 1
fi

session_var="OP_SESSION_${account_uuid}"

# Write to ephemeral session file (not persisted to host volume)
echo "export ${session_var}=\"${session_token}\"" > "$SESSION_ENV"
chmod 600 "$SESSION_ENV"

# Export for the current process
export "${session_var}=${session_token}"

echo "1Password session token written to ${SESSION_ENV} as ${session_var}"
