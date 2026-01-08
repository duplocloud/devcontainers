FROM ghcr.io/devcontainers/templates/python:5.0.0 as base

# common utils
RUN <<EOF 
apt-get update
apt-get -y install --no-install-recommends \
  direnv fzf curl gnupg
EOF

# Install openvpn client
RUN <<EOF
apt-get -y install --no-install-recommends openvpn
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/library-scripts 
#
# Remove the OPENVPN_CONFIG variable since we don't neeed it after is written to a file 
echo 'OPENVPN_CONFIG=""' >> /etc/environment 
echo "unset OPENVPN_CONFIG" | tee -a /etc/bash.bashrc > /etc/profile.d/999-unset-openvpn-config.sh 
if [ -d "/etc/zsh" ]; then echo "unset OPENVPN_CONFIG" >> /etc/zsh/zshenv; fi
EOF
