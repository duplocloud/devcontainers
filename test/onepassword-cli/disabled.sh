#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "op is not installed" bash -lc "! command -v op"
check "on-create script exists" test -x /usr/local/share/onepassword-on-create.sh
check "post-start script exists" test -x /usr/local/share/onepassword-post-start.sh
check "op-session-reload script exists" test -x /usr/local/bin/op-session-reload
check "config file exists" test -f /usr/local/etc/onepassword-feature.conf
check "enabled persisted false" grep -q '^OP_ENABLED="false"$' /usr/local/etc/onepassword-feature.conf

check "on-create exits safely when disabled" bash -lc "_REMOTE_USER_HOME=/tmp/onepassword-home bash /usr/local/share/onepassword-on-create.sh"
check ".ssh not created when disabled" test ! -d /tmp/onepassword-home/.ssh
check "post-start exits safely when disabled" bash -lc "bash /usr/local/share/onepassword-post-start.sh"

reportResults
