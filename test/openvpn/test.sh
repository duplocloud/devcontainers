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
check "openvpn version" openvpn --version
check "init script exists" test -f /usr/local/share/openvpn-init.sh
check "post-start script exists" test -f /usr/local/share/openvpn-post-start.sh

# Report results
reportResults
