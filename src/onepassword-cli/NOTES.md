## Usage

Add this feature to your devcontainer configuration:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "vault": "Personal",
      "autoSsh": true,
      "sshSecretNames": "GitHub SSH Key"
    }
  }
}
```

## Authentication Methods

The feature supports multiple authentication methods (checked in order):

1. **Connect Server**: Set `OP_CONNECT_HOST` and `OP_CONNECT_TOKEN` environment variables
2. **Service Account**: Set `OP_SERVICE_ACCOUNT_TOKEN` environment variable
3. **Interactive Login**: Prompts for email/password (can be disabled with `disableInteractive: true`)

If no authentication method succeeds, only the CLI is installed and a warning is displayed.

## Environment Variables

The feature configures these environment variables globally:

- `OP_ACCOUNT` - The 1Password account domain
- `OP_VAULT_NAME` - The default vault name (if configured)
- `OP_VAULT` - The vault ID (set at runtime after authentication)

## Auto SSH Configuration

When `autoSsh` is enabled, the feature automatically fetches SSH keys from 1Password.

### Using Secret Names

Specify exact secret names:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "autoSsh": true,
      "sshSecretNames": "GitHub SSH Key,GitLab SSH Key"
    }
  }
}
```

### Using Secret Tags

Search for secrets by tag:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "autoSsh": true,
      "sshSecretTags": "ssh,devcontainer"
    }
  }
}
```

### SSH Secret Requirements

Each 1Password SSH secret must have these fields:

| Field | Required | Description |
|-------|----------|-------------|
| `private key` | Yes | The SSH private key |
| `public key` | Yes | The SSH public key |
| `host` | No | Hostname for automatic SSH config entry |
| `key type` | No | Type of SSH key (ed25519, rsa, etc.) |

### File Naming

SSH key files are named based on the secret name with spaces replaced by underscores:

- Secret: `GitHub SSH Key`
- Private key: `~/.ssh/GitHub_SSH_Key`
- Public key: `~/.ssh/GitHub_SSH_Key.pub`

## Integration with Git Feature

For automatic commit signing, pair with the git feature:

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
