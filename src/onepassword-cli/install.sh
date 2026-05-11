#!/usr/bin/env bash
set -e

echo "Installing 1Password CLI..."

FEATURE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENABLED="${ENABLED:-true}"

# Always install the on-create script (required by devcontainer-feature.json)
# Copy on-create script to a global location
cp "${FEATURE_DIR}/on-create.sh" /usr/local/share/onepassword-on-create.sh
chmod 755 /usr/local/share/onepassword-on-create.sh

# Install post-start script (runs on every container start / window reload)
cp "${FEATURE_DIR}/post-start.sh" /usr/local/share/onepassword-post-start.sh
chmod 755 /usr/local/share/onepassword-post-start.sh

# Install op-session-reload as a PATH command
cp "${FEATURE_DIR}/op-session-reload.sh" /usr/local/bin/op-session-reload
chmod 755 /usr/local/bin/op-session-reload

# Save feature options to config file for use during onCreate lifecycle hook
mkdir -p /usr/local/etc
cat <<EOF > /usr/local/etc/onepassword-feature.conf
OP_ENABLED="${ENABLED}"
VAULT="${VAULT:-}"
VAULTID="${VAULTID:-}"
ACCOUNT="${ACCOUNT:-my.1password.com}"
USEREMAIL="${USEREMAIL:-}"
INTERACTIVE="${INTERACTIVE:-false}"
AUTOSSH="${AUTOSSH:-false}"
SSHSECRETNAMES="${SSHSECRETNAMES:-}"
SSHSECRETTAGS="${SSHSECRETTAGS:-ssh}"
EOF
chmod 644 /usr/local/etc/onepassword-feature.conf

if [ "${ENABLED}" = "false" ]; then
    echo "1Password CLI feature is disabled, skipping installation."
    exit 0
fi

# Remove or disable problematic repositories that may have missing GPG keys
# This is a workaround for yarn and other repositories that may be present in the base image
if [ -f /etc/apt/sources.list.d/yarn.list ]; then
    echo "Disabling yarn repository due to missing GPG key..."
    mv /etc/apt/sources.list.d/yarn.list /etc/apt/sources.list.d/yarn.list.disabled || true
fi

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
