
# Git Configuration (git)

Installs git plugins and configures global gitignore

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/git:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| installGitKraken | Install GitKraken CLI (gk) for enhanced git operations | boolean | false |

## Customizations

### VS Code Extensions

- `eamodio.gitlens`

## Usage

Add this feature to your devcontainer configuration:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/git:1": {
      "userName": "Your Name",
      "userEmail": "you@example.com",
      "signingKey": "github.pub"
    }
  }
}
```

## Environment Variables

The feature respects these environment variables as fallbacks:

- `GIT_USER` - Git user name (used if `userName` option is not set)
- `GIT_EMAIL` - Git email (used if `userEmail` option is not set)

## Git Plugins

This feature installs custom git plugins:

### git-bump

Semantic version bumping for git tags:

```bash
# Bump patch version (1.0.0 -> 1.0.1)
git bump -v patch

# Bump minor version (1.0.0 -> 1.1.0)
git bump -v minor

# Bump major version (1.0.0 -> 2.0.0)
git bump -v major

# Bump and push
git bump -v patch -p
```

### git-setenv

Export CI environment variables for local testing:

```bash
# Export Bitbucket CI variables
eval $(git setenv bitbucket)

# Export GitLab CI variables
eval $(git setenv gitlab)
```

## Signing Configuration

When a signing key is configured, the feature sets up SSH-based commit signing:

```bash
# Commits will be automatically signed
git commit -m "This commit is signed"

# Verify signatures
git log --show-signature
```

## Integration with 1Password

When used with the `onepassword-cli` feature, SSH keys can be automatically fetched and configured. The git feature runs after onepassword-cli to ensure keys are available.

Example configuration:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "autoSsh": true,
      "sshSecretNames": "GitHub SSH Key"
    },
    "ghcr.io/duplocloud/devcontainers/git:1": {
      "signingKey": "GitHub_SSH_Key.pub"
    }
  }
}
```


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/git/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
