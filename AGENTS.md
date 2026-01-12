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

## Documentation Policies

Requirements and Context for writing docs for features: 
- all src/*/README.md files are generated, don't edit these
- add your docs in src/*/NOTES.md files, these are generated into README.md
- when given a task, take notes and docs in the NOTES.md files

When given URL's to read: 
- always save them as markdown references at the bottom of the main ./README.md file
- save URLs under the `## References` section
- use markdown format like `[Title](http://link)`
