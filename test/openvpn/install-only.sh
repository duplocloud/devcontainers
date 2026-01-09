#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "openvpn is installed" command -v openvpn
check "init script exists" test -f /usr/local/share/openvpn-init.sh
check "post-start script exists" test -f /usr/local/share/openvpn-post-start.sh
check "autoConnect persisted false" grep -q "false" /usr/local/share/openvpn-autoconnect

reportResults
