#!/bin/bash
set -e

source dev-container-features-test-lib
source /usr/local/etc/git-feature.conf

check "user name set" test "${USERNAME}" = "Test User"
check "user email set" test "${USEREMAIL}" = "test@example.com"

reportResults
