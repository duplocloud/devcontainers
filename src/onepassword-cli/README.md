
# 1Password CLI (onepassword-cli)

Installs 1Password CLI with optional auto SSH key configuration

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| vault | Default vault name to use. Sets OP_VAULT_NAME environment variable. | string | - |
| account | 1Password account domain. Sets OP_ACCOUNT environment variable. | string | my.1password.com |
| userEmail | User email for 1Password account (optional, used when adding account). | string | - |
| disableInteractive | Disable interactive login prompt when no auth method is detected. | boolean | false |
| autoSsh | Automatically fetch and configure SSH keys from 1Password. | boolean | false |
| sshSecretNames | Comma-separated list of 1Password secret names containing SSH keys. | string | - |
| sshSecretTags | Tags to search for SSH secrets (used when sshSecretNames is empty). | string | ssh |

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

### Session Persistence

When using interactive login, the session token is persisted to `~/.bashrc` as `OP_SESSION_<UUID>` where `<UUID>` is the user's account UUID. This ensures the session remains valid across terminal sessions without requiring re-authentication.

The session token is automatically:
- Extracted during the sign-in process using `op signin --raw`
- Mapped to the correct account UUID from `op account list`
- Exported to the current script environment for immediate use
- Appended to `.bashrc` for persistence across terminal sessions

**Note**: The account URL may be specified with or without the `https://` prefix. The feature handles both formats when looking up the account UUID.

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

## References 

- [1Password CLI Documentation](https://developer.1password.com/docs/cli) - Official CLI reference and setup guides
- [1Password Connect Server](https://developer.1password.com/docs/connect) - Deploy Connect server for automated secret access
- [SSH Key Management in 1Password](https://support.1password.com/ssh-agent/) - Setting up SSH keys in 1Password



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/onepassword-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
