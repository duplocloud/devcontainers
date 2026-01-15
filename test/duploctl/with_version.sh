#!/bin/bash
set -e

source dev-container-features-test-lib

check "duploctl available" command -v duploctl
check "duploctl version" duploctl version

reportResults
