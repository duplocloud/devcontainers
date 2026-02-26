
# GitKraken (gitkraken)

Installs GitKraken CLI (gk) and GitLens VS Code extension for enhanced git operations

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/gitkraken:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | GitKraken CLI version to install | string | 3.1.51 |

## Customizations

### VS Code Extensions

- `eamodio.gitlens`

## Overview

This feature installs the [GitKraken CLI](https://www.gitkraken.com/cli) and [GitLens VS Code extension](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) for enhanced git operations in your devcontainer.

The GitKraken feature automatically includes the git feature as a dependency, so you get all git configuration capabilities plus GitKraken-specific tools.

> **Note:** While the git feature is automatically installed via `dependsOn`, you must explicitly include it in your devcontainer.json if you want to configure git-specific options (like `userName` or `userEmail`). The `dependsOn` relationship only ensures the git feature is installed—it does not pass options between features.

## Usage

Add this feature to your devcontainer configuration:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/gitkraken:1": {}
  }
}
```

### Version Configuration

Specify a specific GitKraken CLI version:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/gitkraken:1": {
      "version": "3.1.51"
    }
  }
}
```

To configure git options, explicitly include the git feature:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/gitkraken:1": {},
    "ghcr.io/duplocloud/devcontainers/git:1": {
      "userName": "Your Name",
      "userEmail": "you@example.com"
    }
  }
}
```

To use a specific GitKraken CLI version:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/gitkraken:1": {
      "version": "3.2.0"
    }
  }
}
```

## What's Included

### GitKraken CLI

The GitKraken CLI (`gk`) provides enhanced git commands and integrations:

```bash
# View GitKraken CLI version
gk --version

# See available commands
gk --help
```

### GitLens Extension

GitLens supercharges Git inside VS Code, providing:
- Inline blame annotations
- Rich commit search
- File and line history
- Visual commit graph
- And much more

The extension is automatically installed in VS Code when using this feature.

## Platform Support

The GitKraken CLI supports:
- **Architectures**: amd64, arm64, 386
- **Operating Systems**: Linux, macOS

## References

- [GitKraken CLI Documentation](https://www.gitkraken.com/cli)
- [GitLens Extension](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [GitKraken Website](https://www.gitkraken.com/gitlens)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/gitkraken/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
