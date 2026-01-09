# Devcontainers

Devcontainer features for DuploCloud customer workspaces. Shell scripts in `src/*/install.sh`.

## Structure

 - `src/` - Devcontainer features (aws-cli, gcloud-cli, terraform, openvpn, onepassword-cli)
- `scripts/` - Helper scripts
- `test/` - Test files for features

## Agents

- **@git** - Git operations using GitKraken tools (status, commit, push, branch, etc.)
- **@debug** - Debug GitHub Actions pipelines using gh CLI
- **@devcontainer** - Devcontainer features expert (create, test, use features)

## Prompts

- **new-feature** - Guided workflow to create a new devcontainer feature

## Agent Guidance

When troubleshooting or modifying this repo:

| Topic | See README Section |
|-------|--------------------|
| Devcontainer build failures / base image selection | `## Devcontainer Base Image` |
| Feature installation scripts | `## Features` |
| Project layout | `## Project Structure` |

For feature-specific notes, check `NOTES.md` in the repo root.
