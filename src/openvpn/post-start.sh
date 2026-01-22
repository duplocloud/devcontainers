#!/bin/bash

set -e

# Load feature configuration
if [ -f /usr/local/etc/openvpn-feature.conf ]; then
  source /usr/local/etc/openvpn-feature.conf
fi

# Check if feature is enabled
if [ "${OVPN_ENABLED:-true}" = "false" ]; then
    echo "OpenVPN feature is disabled, skipping VPN startup."
    exit 0
fi

# Check if autoConnect is disabled
if [ "${OVPN_AUTOCONNECT:-true}" = "false" ]; then
    echo "OpenVPN autoConnect is disabled, skipping VPN startup."
    exit 0
fi

echo "Running OpenVPN post-start script..."

# Determine OpenVPN configuration directory
if [ -n "${OVPN_CONFIG_DIR}" ]; then
  # Use the user-specified config directory
  OVPN_DIR="${OVPN_CONFIG_DIR}"
elif [ -n "${XDG_CONFIG_HOME}" ]; then
  # Use XDG_CONFIG_HOME if set
  OVPN_DIR="${XDG_CONFIG_HOME}/openvpn"
else
  # Fall back to HOME/.config/openvpn
  OVPN_DIR="${HOME}/.config/openvpn"
fi

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
