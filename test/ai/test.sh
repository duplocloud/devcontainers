#!/bin/bash
set -e

# Import test library
# shellcheck disable=SC1091
source dev-container-features-test-lib

# Require a modern Node for these CLIs
check "node >= 18" node -e "process.exit(Number(process.versions.node.split('.')[0]) >= 18 ? 0 : 1)"

# Test that Node.js is installed
check "node installed" node --version

# Test that npm is installed
check "npm installed" npm --version

# Test that duplo-skills is installed
check "duplo-skills installed" command -v duplo-skills

# Test that duplo-skills shows help
check "duplo-skills help" duplo-skills --help

# Test that duplo-skills shows version
check "duplo-skills version" duplo-skills --version

# Test that duplo-skills can download and verify checksums from ai-ops (latest release)
check "duplo-skills download + checksum" bash -lc '
  set -euo pipefail
  INSTALL_DIR=/tmp/duplo-skills-test
  rm -rf "$INSTALL_DIR"

  SKILL="$(
    node -e "
      const https = require(\"https\");
      const req = https.request(
        \"https://api.github.com/repos/duplocloud/ai-ops/releases/latest\",
        { headers: { \"User-Agent\": \"duplo-skills-test\" } },
        (res) => {
          let data = \"\";
          res.on(\"data\", (d) => (data += d));
          res.on(\"end\", () => {
            if (res.statusCode !== 200) process.exit(1);
            const json = JSON.parse(data);
            const skill = (json.assets || [])
              .filter((a) => typeof a.name === \"string\" && a.name.endsWith(\".skill\") && typeof a.digest === \"string\" && a.digest.startsWith(\"sha256:\"))
              .map((a) => a.name.replace(/\\.skill$/, \"\"))[0];
            if (!skill) process.exit(2);
            process.stdout.write(skill);
          });
        }
      );
      req.on(\"error\", () => process.exit(3));
      req.end();
    "
  )"

  out="$(duplo-skills --dir "$INSTALL_DIR" --skill "$SKILL" 2>&1)"
  echo "$out" | grep -q "Checksum verified"
  test -f "$INSTALL_DIR/${SKILL}.skill"
'

# Report results
reportResults
