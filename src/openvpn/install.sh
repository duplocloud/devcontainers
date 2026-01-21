#!/bin/bash

set -e

echo "Installing OpenVPN client..."

# Use devcontainer environment variables with fallbacks
_REMOTE_USER="${_REMOTE_USER:-root}"
_REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/root}"

# Check if feature is enabled
ENABLED="${ENABLED:-true}"

# Always install the lifecycle scripts (required by devcontainer-feature.json)
# but save the enabled state so they can exit early if disabled
mkdir -p /usr/local/share

# Copy lifecycle scripts to a global location
cp -f "$(dirname "${BASH_SOURCE[0]}")/on-create.sh" /usr/local/share/openvpn-on-create.sh
cp -f "$(dirname "${BASH_SOURCE[0]}")/post-start.sh" /usr/local/share/openvpn-post-start.sh
chmod +x /usr/local/share/openvpn-on-create.sh
chmod +x /usr/local/share/openvpn-post-start.sh

# Save feature options to config file for use during lifecycle hooks
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/openvpn-feature.conf
OVPN_ENABLED="${ENABLED}"
OVPN_AUTOCONNECT="${AUTOCONNECT:-true}"
EOF
chmod 644 /usr/local/etc/openvpn-feature.conf

if [ "${ENABLED}" = "false" ]; then
    echo "OpenVPN feature is disabled, skipping installation."
    exit 0
fi

# Install openvpn client and git (git may not exist on vanilla images)
apt-get update
apt-get -y install --no-install-recommends openvpn git
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/library-scripts 

# Remove the OPENVPN_CONFIG variable since we don't need it after it's written to a file 
echo 'OPENVPN_CONFIG=""' >> /etc/environment 
echo "unset OPENVPN_CONFIG" | tee -a /etc/bash.bashrc > /etc/profile.d/999-unset-openvpn-config.sh 
if [ -d "/etc/zsh" ]; then echo "unset OPENVPN_CONFIG" >> /etc/zsh/zshenv; fi

# Add .ovpn to global gitignore
if [ ! -f "${_REMOTE_USER_HOME}/.gitignore_global" ]; then
    touch "${_REMOTE_USER_HOME}/.gitignore_global"
    chown ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.gitignore_global"
    su - ${_REMOTE_USER} -c "git config --global core.excludesfile ~/.gitignore_global"
fi

if ! grep -q "^\.ovpn$" "${_REMOTE_USER_HOME}/.gitignore_global" 2>/dev/null; then
    echo ".ovpn" >> "${_REMOTE_USER_HOME}/.gitignore_global"
    chown ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.gitignore_global"
fi

echo "OpenVPN client installed successfully!"
