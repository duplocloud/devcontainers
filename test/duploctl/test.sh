#!/bin/bash
set -e

source dev-container-features-test-lib

check "duploctl available" bash -c "command -v duploctl || python3 -c 'import duplocloud'"

reportResults
