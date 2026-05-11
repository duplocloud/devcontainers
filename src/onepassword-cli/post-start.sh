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

echo "Refreshing 1Password session..."
op-session-reload
