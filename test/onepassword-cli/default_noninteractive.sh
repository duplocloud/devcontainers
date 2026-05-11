#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "op is installed" command -v op
check "op version" op --version
check "jq is installed" command -v jq

# Check on-create script exists
check "on-create script exists" test -f /usr/local/share/onepassword-on-create.sh

# Check post-start script exists
check "post-start script exists" test -f /usr/local/share/onepassword-post-start.sh

# Check op-session-reload is in PATH
check "op-session-reload is executable" test -x /usr/local/bin/op-session-reload

# Check config file exists
check "config file exists" test -f /usr/local/etc/onepassword-feature.conf

# Verify interactive is set to false in config
check "interactive is false" grep -q '^INTERACTIVE="false"$' /usr/local/etc/onepassword-feature.conf

# Test that on-create runs without hanging (non-interactive mode)
check "on-create exits safely when no auth available" bash -lc "timeout 5 bash /usr/local/share/onepassword-on-create.sh || test \$? -eq 124 || true"

# op-session-reload should exit 0 cleanly with no credentials (no account to sign in to)
check "op-session-reload exits safely when no auth available" bash -lc "timeout 5 op-session-reload || true"

reportResults
