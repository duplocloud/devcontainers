#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'openvpn' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "openvpn is installed" command -v openvpn
check "openvpn version output" bash -lc "openvpn --version 2>&1 | head -n 1 | grep -q '^OpenVPN '"
check "on-create script exists" test -x /usr/local/share/openvpn-on-create.sh
check "post-start script exists" test -x /usr/local/share/openvpn-post-start.sh
check "config file exists" test -f /usr/local/etc/openvpn-feature.conf
check "enabled persisted true" grep -q '^OVPN_ENABLED="true"$' /usr/local/etc/openvpn-feature.conf

check "on-create runs safely" bash -lc "HOME=/tmp/openvpn-test bash /usr/local/share/openvpn-on-create.sh"
check "on-create created config directory" test -d /tmp/openvpn-test/.config/openvpn
check "post-start runs safely" bash -lc "HOME=/tmp/openvpn-test bash /usr/local/share/openvpn-post-start.sh"

# Report results
reportResults
