#!/usr/bin/env bash
set -e

echo "Configuring Kubernetes for DuploCloud..."

# Store feature configuration for on-create script
cat <<EOF > /usr/local/etc/kubernetes-feature.conf
JIT="${JIT}"
JIT_ADMIN="${JITADMIN}"
JIT_INTERACTIVE="${JITINTERACTIVE}"
PLAN="${PLAN}"
TENANT="${TENANT}"
EOF

# Copy on-create script to shared location
# Use dirname to get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/on-create.sh" /usr/local/share/kubernetes-on-create.sh
chmod +x /usr/local/share/kubernetes-on-create.sh

echo "Kubernetes configuration prepared. Will generate kubeconfig on container creation."
