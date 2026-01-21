#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "openvpn is not installed" bash -lc "! command -v openvpn"
check "on-create script exists" test -x /usr/local/share/openvpn-on-create.sh
check "post-start script exists" test -x /usr/local/share/openvpn-post-start.sh
check "config file exists" test -f /usr/local/etc/openvpn-feature.conf
check "enabled persisted false" grep -q '^OVPN_ENABLED="false"$' /usr/local/etc/openvpn-feature.conf

check "on-create exits safely when disabled" bash -lc "_CONTAINER_WORKSPACE_FOLDER=/tmp/openvpn-test bash /usr/local/share/openvpn-on-create.sh"
check ".ovpn directory not created" test ! -d /tmp/openvpn-test/.ovpn
check "post-start exits safely when disabled" bash -lc "_CONTAINER_WORKSPACE_FOLDER=/tmp/openvpn-test bash /usr/local/share/openvpn-post-start.sh"

reportResults
