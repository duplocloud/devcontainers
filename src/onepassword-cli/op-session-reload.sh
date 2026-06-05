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

# Whether this invocation is allowed to prompt the user. A plain TTY test is NOT a reliable signal:
# the dev container CLI allocates a PTY for the postStart hook, so stdin/stdout look like a terminal
# even though no human is watching. Gate prompting on an EXPLICIT opt-in instead — the shell rc
# passes --interactive because a person just opened a terminal; the postStart hook never does.
ALLOW_INTERACTIVE="false"
for _arg in "$@"; do
  [ "$_arg" = "--interactive" ] && ALLOW_INTERACTIVE="true"
done
[ "${OP_RELOAD_INTERACTIVE:-}" = "true" ] && ALLOW_INTERACTIVE="true"

# True when the account is already enrolled locally (op signin then only needs a password).
account_enrolled() {
  local shorthand="${ACCOUNT%%.*}"
  op account list 2>/dev/null | grep -qE "(${ACCOUNT}|${shorthand})"
}

# Sign-in requires the account to be enrolled first. Enrollment (op account add) prompts for the
# Secret Key and can't be automated, so only an explicitly-interactive invocation may do it. In the
# postStart hook the account is typically not yet enrolled — attempting it there is exactly what
# produced the hanging "add an account manually now? [Y/n]" prompt — so we skip cleanly instead.
if ! account_enrolled; then
  if [ "$ALLOW_INTERACTIVE" = "true" ]; then
    shorthand="${ACCOUNT%%.*}"
    echo "No 1Password account enrolled; adding $ACCOUNT (shorthand: $shorthand)..."
    add_cmd="op account add --address \"$ACCOUNT\" --shorthand \"$shorthand\""
    [ -n "${USEREMAIL:-}" ] && add_cmd="$add_cmd --email \"$USEREMAIL\""
    if ! eval "$add_cmd"; then
      echo "Error: Failed to add 1Password account" >&2
      exit 1
    fi
  else
    echo "No 1Password account enrolled yet; open a terminal to sign in. Skipping."
    exit 0
  fi
fi

echo "Signing in to 1Password account: $ACCOUNT"

# Get raw session token. OP_PASSWD enables a fully non-interactive sign-in (works in postStart once
# the account is enrolled). Without it we may only prompt when explicitly interactive; otherwise skip
# so the hook never blocks on a password prompt.
set +e
local_passwd="${OP_PASSWD:-}"
if [ -n "$local_passwd" ]; then
  session_token=$(echo "$local_passwd" | timeout 30 op signin --account "$ACCOUNT" --raw 2>&1)
  signin_status=$?
elif [ "$ALLOW_INTERACTIVE" = "true" ]; then
  session_token=$(timeout 60 op signin --account "$ACCOUNT" --raw 2>&1)
  signin_status=$?
else
  echo "No OP_PASSWD set and not an interactive invocation; open a terminal to sign in. Skipping."
  exit 0
fi
set -e

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
