#!/bin/bash

set -e

echo "Initializing OpenVPN configuration..."

# Get the workspace directory - use the containerWorkspaceFolder if available
if [ -z "${_CONTAINER_WORKSPACE_FOLDER}" ]; then
    WORKSPACE_DIR="${_REMOTE_WORKSPACE_FOLDER:-/workspace}"
else
    WORKSPACE_DIR="${_CONTAINER_WORKSPACE_FOLDER}"
fi

OVPN_DIR="${WORKSPACE_DIR}/.ovpn"

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
