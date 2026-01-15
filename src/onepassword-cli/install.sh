#!/usr/bin/env bash
set -e

echo "Installing 1Password CLI..."

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install required dependencies (curl/gpg/fzf/jq may not exist on vanilla images)
apt-get update
apt-get install -y --no-install-recommends curl gpg ca-certificates fzf jq

# Add 1Password GPG key
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

# Add 1Password repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
  tee /etc/apt/sources.list.d/1password.list

# Setup debsig verification
mkdir -p /etc/debsig/policies/AC2D62742012EA22/
curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
  tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
  gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

# Install 1Password CLI
apt-get update
apt-get install -y 1password-cli
apt-get clean
rm -rf /var/lib/apt/lists/*

# Copy on-create script to a global location
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/onepassword-on-create.sh
chmod 755 /usr/local/share/onepassword-on-create.sh

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/onepassword-feature.conf
VAULT="${VAULT:-}"
VAULTID="${VAULTID:-}"
ACCOUNT="${ACCOUNT:-my.1password.com}"
USEREMAIL="${USEREMAIL:-}"
DISABLEINTERACTIVE="${DISABLEINTERACTIVE:-false}"
AUTOSSH="${AUTOSSH:-false}"
SSHSECRETNAMES="${SSHSECRETNAMES:-}"
SSHSECRETTAGS="${SSHSECRETTAGS:-ssh}"
EOF
chmod 644 /usr/local/etc/onepassword-feature.conf

# Configure environment variables globally
cat <<EOF >> /etc/environment
OP_ACCOUNT="${ACCOUNT:-my.1password.com}"
EOF

if [ -n "${VAULT:-}" ]; then
  echo "OP_VAULT_NAME=\"${VAULT}\"" >> /etc/environment
fi

if [ -n "${VAULTID:-}" ]; then
  echo "OP_VAULT=\"${VAULTID}\"" >> /etc/environment
fi

echo "1Password CLI installed successfully!"
