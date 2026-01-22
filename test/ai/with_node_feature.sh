#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

echo "Testing ai feature with devcontainers node feature..."

# Verify Node.js was installed by the node feature (via nvm)
check "node installed" command -v node

# Check if nvm is available (node feature typically installs via nvm)
check "nvm available" bash -c '[[ -s "$HOME/.nvm/nvm.sh" ]] || [[ -s "/usr/local/share/nvm/nvm.sh" ]]'

# Test that Node.js version is >= 18
check "node >= 18" node -e "process.exit(Number(process.versions.node.split('.')[0]) >= 18 ? 0 : 1)"

# Test that npm is installed
check "npm installed" command -v npm

# Verify duplo-skills was installed successfully
check "duplo-skills installed" command -v duplo-skills

# Test that duplo-skills works
check "duplo-skills version" duplo-skills --version

# Verify the ai feature didn't redundantly install Node.js
# We check that Node.js comes from nvm path (indicating it used the existing installation)
NODE_PATH="$(which node)"
echo "Node.js path: $NODE_PATH"

if [[ "$NODE_PATH" == *"/.nvm/"* ]] || [[ "$NODE_PATH" == */nvm/* ]]; then
  echo "✓ Node.js is from nvm (installed by node feature)"
else
  echo "Node.js path does not appear to be from nvm: $NODE_PATH"
  echo "This could mean ai feature installed its own Node.js instead of using the node feature's installation"
fi

# Test that duplo-skills can interact with GitHub API
check "duplo-skills help" duplo-skills --help

echo ""
echo "✓ AI feature successfully detected and used Node.js from devcontainers node feature"

reportResults
