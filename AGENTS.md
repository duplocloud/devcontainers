# Devcontainers

Devcontainer features for DuploCloud customer workspaces. Shell scripts in `src/*/install.sh`.

## Structure

- `src/` - Devcontainer features (aws-cli, gcloud-cli, terraform, openvpn-cli, onepassword-cli)
- `scripts/` - Helper scripts
- `test/` - Test files for features

## Agents

- **@git** - Git operations using GitKraken tools (status, commit, push, branch, etc.)
- **@debug** - Debug GitHub Actions pipelines using gh CLI
