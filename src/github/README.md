
# GitHub CLI (github)

Installs GitHub CLI (gh) with optional GitHub Copilot CLI and skills support

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/github:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installCopilot | Install GitHub Copilot CLI extension | boolean | false |
| installGitKraken | Install GitKraken CLI (gk) for enhanced git operations. Requires git feature to be installed. | boolean | false |
| skills | Comma-separated list of Copilot skills to install (e.g., 'tf-module,api-design'). Skills are always downloaded when specified, regardless of authentication status. | string | - |

## Customizations

### VS Code Extensions

- `github.vscode-pull-request-github`



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/github/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
