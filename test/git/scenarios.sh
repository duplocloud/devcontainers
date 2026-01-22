#!/bin/bash
set -e

source dev-container-features-test-lib

source /usr/local/etc/git-feature.conf

check "scenario config valid" bash -c "\
if [ \"${PROVIDER}\" = \"github\" ]; then \
  exit 0; \
fi; \
if [ \"${USERNAME}\" = \"Test User\" ] && [ \"${USEREMAIL}\" = \"test@example.com\" ]; then \
  exit 0; \
fi; \
exit 1 \
"

reportResults
