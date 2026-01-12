#!/usr/bin/env bash
set -e

# AWS JIT Auto-Configuration Script
# This script uses duploctl to automatically configure AWS CLI with JIT credentials
# It honors AWS_CONFIG_FILE and AWS_PROFILE environment variables

# Source JIT configuration from install-time options
if [[ -f /usr/local/etc/aws-jit.conf ]]; then
  source /usr/local/etc/aws-jit.conf
fi

# Check if JIT configuration is enabled
JIT="${JIT:-false}"

if [[ "$JIT" != "true" ]]; then
  echo "AWS JIT auto-configuration is disabled. Set jit=true to enable."
  exit 0
fi

# Determine the profile name to use
PROFILE_NAME="${AWS_PROFILE:-default}"

echo "Configuring AWS CLI with duploctl JIT credentials for profile: $PROFILE_NAME"

# Verify duploctl is available
if ! command -v duploctl &> /dev/null; then
  echo "Error: duploctl command not found. Please ensure duploctl is installed and in PATH."
  exit 1
fi

# Build command arguments array
DUPLOCTL_ARGS=("jit" "update_aws_config" "$PROFILE_NAME")

# Add admin flag if enabled
JITADMIN="${JITADMIN:-false}"
if [[ "$JITADMIN" == "true" ]]; then
  DUPLOCTL_ARGS+=("--admin")
fi

# Add interactive flag if enabled
JITINTERACTIVE="${JITINTERACTIVE:-false}"
if [[ "$JITINTERACTIVE" == "true" ]]; then
  DUPLOCTL_ARGS+=("--interactive")
fi

# Run the duploctl command to update AWS config
# The command will automatically honor AWS_CONFIG_FILE if set
# It will inherit --host flag from duploctl configuration
if duploctl "${DUPLOCTL_ARGS[@]}" 2>&1; then
  echo "AWS CLI configuration updated successfully for profile: $PROFILE_NAME"
else
  echo "Error: Failed to configure AWS CLI using duploctl."
  echo "This usually means duploctl is not properly configured."
  echo "Please run 'duploctl configure' or ensure your duploctl configuration is set up correctly."
  exit 1
fi
