---
name: ship
description: Commit, push, and debug GitHub Actions pipeline
agent: agent
tools:
  ['execute/getTerminalOutput', 'execute/runInTerminal', 'read/problems', 'read/readFile', 'read/terminalSelection', 'read/terminalLastCommand', 'search', 'agent', 'gitkraken/*', 'todo']
---

# Ship Code and Debug Pipeline

This workflow commits your changes, pushes to GitHub, and debugs any pipeline failures.

Use #tool:todo to track progress through each step. Create todos at the start, mark each as in-progress before starting, and mark as completed immediately after finishing.

## Step 1: Commit and Push

Using the git agent to stage, commit with a good message, and push:

#tool:agent/runSubagent @agent:git Please commit and push all current changes. Generate a conventional commit message based on the changes.

## Step 2: Debug Pipeline

Wait for the pipeline to complete, then check for failures:

#tool:agent/runSubagent @agent:debug Check the latest GitHub Actions workflow run for this repository. If there are any failures, analyze the logs and provide a diagnosis with recommended fixes.
