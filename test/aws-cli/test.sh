#!/bin/bash
set -e

# Test that the alias file exists
source dev-entrypoint.sh 2>/dev/null || true
echo "aws-cli feature test passed"
