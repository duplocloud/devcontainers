#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "op is installed" command -v op
check "op version" op --version
check "jq is installed" command -v jq

# Check on-create script exists
check "on-create script exists" test -f /usr/local/share/onepassword-on-create.sh

# Check config file exists
check "config  file exists" test -f /usr/local/etc/onepassword-feature.conf

# Verify interactive is set to true in config
check "interactive is true" grep -q '^INTERACTIVE="true"$' /usr/local/etc/onepassword-feature.conf

# Note: We don't test actual authentication here because it would require credentials
# The on-create command will have tried to run but should have detected no auth method

reportResults
