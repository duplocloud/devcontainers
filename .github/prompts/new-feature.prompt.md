---
name: new-feature
description: Create a new devcontainer feature with guided workflow
agent: devcontainer
tools:
  ['execute/getTerminalOutput', 'execute/runInTerminal', 'read/problems', 'read/readFile', 'read/terminalSelection', 'read/terminalLastCommand', 'edit/createDirectory', 'edit/createFile', 'edit/editFiles', 'search/changes', 'search/fileSearch', 'search/listDirectory', 'search/searchResults', 'search/textSearch', 'search/usages', 'web', 'todo']
---

# Create New Devcontainer Feature

This workflow guides you through creating a complete devcontainer feature.

## Initialize Todos

Create the todo list to track progress:

#tool:todo Write todos:
1. Gather feature requirements
2. Plan feature structure
3. Implement feature files
4. Create and run tests

---

## Step 1: Gather Requirements

Mark todo 1 as in-progress.

Ask the user these questions (wait for answers before proceeding):

1. **Feature name**: What should this feature be called? (lowercase, hyphenated)
2. **Purpose**: What does this feature install or configure?
3. **Options**: What configurable options should it have? (e.g., version, flags)
4. **Dependencies**: Does it need other features or packages first?
5. **Platforms**: Should it support specific architectures? (amd64, arm64, both)

Mark todo 1 as completed after gathering all answers.

---

## Step 2: Plan Feature Structure

Mark todo 2 as in-progress.

Based on the requirements, outline:

```
src/<feature-name>/
├── devcontainer-feature.json  # Metadata and options
├── install.sh                 # Installation script
└── (optional additional files)

test/<feature-name>/
├── test.sh                    # Test script
└── scenarios.json             # (if multiple test scenarios needed)
```

Present the plan to the user and confirm before implementing.

Reference: [Features Schema](https://containers.dev/implementors/features/)

Mark todo 2 as completed after user confirms.

---

## Step 3: Implement Feature Files

Mark todo 3 as in-progress.

Create the following files:

### `devcontainer-feature.json`
```json
{
  "id": "<feature-name>",
  "version": "1.0.0",
  "name": "<Feature Name>",
  "description": "<description>",
  "options": {},
  "installsAfter": []
}
```

### `install.sh`
```bash
#!/usr/bin/env bash
set -e

echo "Installing <feature-name>..."

# Installation logic here

echo "Done!"
```

Mark todo 3 as completed after creating all files.

---

## Step 4: Create and Run Tests

Mark todo 4 as in-progress.

### Create `test/<feature-name>/test.sh`
```bash
#!/bin/bash
set -e

# Test that the feature installed correctly
source dev-container-features-test-lib

check "<test-name>" <command-to-test>

reportResults
```

### Run tests
```bash
devcontainer features test -f <feature-name> .
```

Mark todo 4 as completed after tests pass.

---

## Completion

All todos should be completed. Summarize what was created and next steps:
- How to use the feature in a devcontainer
- How to publish (if applicable)
- Link to [Feature Starter Repo](https://github.com/devcontainers/feature-starter) for publishing guidance

