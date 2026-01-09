#!/bin/bash

set -e

# Check if autoConnect is disabled
AUTO_CONNECT=$(cat /usr/local/share/openvpn-autoconnect 2>/dev/null || echo "true")
if [ "${AUTO_CONNECT}" = "false" ]; then
    echo "OpenVPN autoConnect is disabled, skipping VPN startup."
    exit 0
fi

echo "Running OpenVPN post-start script..."

# Get the workspace directory - use the containerWorkspaceFolder if available
if [ -z "${_CONTAINER_WORKSPACE_FOLDER}" ]; then
    WORKSPACE_DIR="${_REMOTE_WORKSPACE_FOLDER:-/workspace}"
else
    WORKSPACE_DIR="${_CONTAINER_WORKSPACE_FOLDER}"
fi

OVPN_DIR="${WORKSPACE_DIR}/.ovpn"

# Switch to the .ovpn folder if it exists
if [ ! -d "${OVPN_DIR}" ]; then
    echo "OpenVPN configuration directory ${OVPN_DIR} does not exist, skipping."
    exit 0
fi

cd "${OVPN_DIR}"

# If we are running as root, we do not need to use sudo
sudo_cmd=""
if [ "$(id -u)" != "0" ]; then
    sudo_cmd="sudo"
fi

# Start up the VPN client using the config stored in vpnconfig.ovpn
# check if vpnconfig.ovpn exists as a file, if it does then start openvpn
if [ -f vpnconfig.ovpn ]; then
    echo "Discovered OpenVPN configuration file, starting OpenVPN..."
    # Touch file to make sure this user can read it
    touch openvpn.log
    nohup ${sudo_cmd} /bin/sh -c "openvpn --config vpnconfig.ovpn --log openvpn.log --auth-user-pass auth.txt &" | tee openvpn-launch.log
else
    echo "No OpenVPN configuration file found, skipping OpenVPN startup."
fi
