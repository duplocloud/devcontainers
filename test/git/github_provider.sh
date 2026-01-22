#!/bin/bash
set -e

source dev-container-features-test-lib
source /usr/local/etc/git-feature.conf

check "provider set" test "${PROVIDER}" = "github"

reportResults
