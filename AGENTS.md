# Devcontainers

Devcontainer features for DuploCloud customer workspaces. Shell scripts in `features/*/install.sh`.

## Structure

- `features/` - Devcontainer features (aws-cli, gcloud-cli, terraform, openvpn-cli, onepassword-cli)
- `scripts/` - Helper scripts

## Agents

- **@commit** - Use for committing and pushing changes. Generates conventional commit messages from chat context.
