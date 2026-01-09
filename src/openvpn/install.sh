#!/bin/bash

set -e

echo "Installing OpenVPN client..."

# Use devcontainer environment variables with fallbacks
_REMOTE_USER="${_REMOTE_USER:-root}"
_REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/root}"

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

# Copy init and post-start scripts to a global location
cp -f "$(dirname "${BASH_SOURCE[0]}")/init.sh" /usr/local/share/openvpn-init.sh
cp -f "$(dirname "${BASH_SOURCE[0]}")/post-start.sh" /usr/local/share/openvpn-post-start.sh
chmod +x /usr/local/share/openvpn-init.sh
chmod +x /usr/local/share/openvpn-post-start.sh

echo "OpenVPN client installed successfully!"
