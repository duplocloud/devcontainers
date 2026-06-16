#!/usr/bin/env bash
set -e

# Load feature configuration
if [ -f /usr/local/etc/onepassword-feature.conf ]; then
  source /usr/local/etc/onepassword-feature.conf
fi

if [ "${OP_ENABLED:-true}" = "false" ]; then
  echo "1Password CLI feature is disabled, skipping session refresh."
  exit 0
fi

# Refresh non-interactively (no --interactive flag): connect/service-account/desktop refresh, or an
# OP_PASSWD sign-in once the account is enrolled. Anything needing a human (enrollment, a password
# prompt) is deferred to the first interactive shell. Never let a refresh hiccup block container
# start — op-session-reload exits 0 on the deferral paths, and we tolerate genuine failures here.
echo "Refreshing 1Password session..."
op-session-reload || echo "1Password session not refreshed now; sign in from a terminal with: op-session-reload --interactive"
