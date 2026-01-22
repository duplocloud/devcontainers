#!/bin/bash

set -e

# Load feature configuration
if [ -f /usr/local/etc/openvpn-feature.conf ]; then
  source /usr/local/etc/openvpn-feature.conf
fi

# Check if feature is enabled
if [ "${OVPN_ENABLED:-true}" = "false" ]; then
    echo "OpenVPN feature is disabled, skipping initialization."
    exit 0
fi

# Check if autoConnect is disabled
if [ "${OVPN_AUTOCONNECT:-true}" = "false" ]; then
    echo "OpenVPN autoConnect is disabled, skipping initialization."
    exit 0
fi

echo "Initializing OpenVPN configuration..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"

# Determine OpenVPN configuration directory
if [ -n "${OVPN_CONFIG_DIR}" ]; then
  # Use the user-specified config directory
  OVPN_DIR="${OVPN_CONFIG_DIR}"
elif [ -n "${XDG_CONFIG_HOME}" ] && [ -w "${XDG_CONFIG_HOME}" ]; then
  # Use XDG_CONFIG_HOME if set and writable
  OVPN_DIR="${XDG_CONFIG_HOME}/openvpn"
else
  # Fall back to HOME/.config/openvpn
  OVPN_DIR="${USER_HOME}/.config/openvpn"
fi

# Create .ovpn directory if it doesn't exist
mkdir -p "${OVPN_DIR}"

# Switch to the .ovpn folder
cd "${OVPN_DIR}"

# Save the configuration from the secret if it is present
if [ ! -z "${OPENVPN_CONFIG}" ]; then 
    echo "${OPENVPN_CONFIG}" > vpnconfig.ovpn
    echo "OpenVPN configuration saved to ${OVPN_DIR}/vpnconfig.ovpn"
fi
if [ ! -z "${OPENVPN_AUTH}" ]; then 
    echo "${OPENVPN_AUTH}" > auth.txt
    echo "OpenVPN authentication saved to ${OVPN_DIR}/auth.txt"
fi

echo "OpenVPN initialization complete."
