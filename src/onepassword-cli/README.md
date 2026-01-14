
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
3. **Desktop App Agent** (Linux only): Automatically detected if `~/.1password/agent.sock` exists
4. **Interactive Login**: Prompts for email/password (can be disabled with `disableInteractive: true`)

If no authentication method succeeds, only the CLI is installed and a warning is displayed.

**Important**: When using Connect Server or Service Account authentication, you **must** specify a vault using either:
- The `vault` feature option in devcontainer.json
- The `OP_VAULT` environment variable (takes precedence)

These authentication methods require `--vault` parameter for all item operations and automatically set `OP_FORMAT=json`.

### Desktop App Agent Authentication

The Desktop App authentication method works by detecting the 1Password agent socket at `~/.1password/agent.sock`. This method is **only available on Linux** because:
- macOS and Windows run containers in a VM, preventing socket mounting
- The 1Password socket directory is privileged on macOS/Windows
- On Linux, the socket can be mounted directly into the container

To enable Desktop App authentication on Linux:
1. Install 1Password desktop app on your Linux host
2. Enable the SSH agent in 1Password settings
3. Mount the socket in your devcontainer.json:
   ```json
   {
     "mounts": [
       "source=${localEnv:HOME}/.1password,target=/home/vscode/.1password,type=bind"
     ]
   }
   ```

This authentication method allows biometric authentication within the devcontainer on Linux hosts.

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
| `username` | No | SSH username for the host (defaults to no User if omitted) |
| `port` | No | SSH port for the host (defaults to 22 if omitted) |
| `key type` | No | Type of SSH key (ed25519, rsa, etc.) |

### How SSH Authentication Works

The feature intelligently configures SSH based on whether an SSH agent is available:

**With SSH Agent Available:**
- Downloads only the **public key** (`.pub`)
- `IdentityFile` points to the public key
- `IdentityAgent` is configured to use the agent
- Private key is accessed securely through the agent

**Without SSH Agent:**
- Downloads both **private and public keys**
- `IdentityFile` points to the private key (no `.pub` extension)
- No `IdentityAgent` directive
- Private key is used directly from disk

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

## Configuring SSH Agent
The feature automatically configures SSH to use the 1Password SSH agent when available. The SSH config generation follows this logic:

1. **If `SSH_AUTH_SOCK` is set**: Uses `IdentityAgent` pointing to the SSH agent socket
2. **If no agent**: Falls back to `IdentityFile` with the downloaded key

### SSH Agent Setup (macOS)

To enable the 1Password SSH agent on macOS, you need to configure a Launch Agent to expose the socket. Create this plist file on your **host machine**:

**File**: `~/Library/LaunchAgents/com.1password.SSH_AUTH_SOCK.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.1password.SSH_AUTH_SOCK</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>-c</string>
    <string>/bin/ln -sf ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock $SSH_AUTH_SOCK</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
```

Then mount the socket into your devcontainer:

```json
{
  "containerEnv": {
    "SSH_AUTH_SOCK": "/tmp/.1password-ssh-auth.sock"
  },
  "mounts": [
    "source=${localEnv:HOME}/.1password/agent.sock,target=/tmp/.1password-ssh-auth.sock,type=bind"
  ]
}
```

The feature will verify the SSH agent is working by running `ssh-add -l` before configuring `IdentityAgent` in the SSH config.

### Verifying SSH Agent

After the container starts, verify the SSH agent is configured:

```bash
ssh-add -l
```

This should list the keys available in your 1Password SSH agent.

For more information, see: [1Password SSH Agent Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/#ssh-auth-sock)
Here are some docs on how to get the 1Password SSH Agent to work in a container on mac: https://developer.1password.com/docs/ssh/agent/compatibility/#ssh-auth-sock



## References 

- [1Password CLI Documentation](https://developer.1password.com/docs/cli) - Official CLI reference and setup guides
- [1Password Connect Server](https://developer.1password.com/docs/connect) - Deploy Connect server for automated secret access
- [SSH Key Management in 1Password](https://support.1password.com/ssh-agent/) - Setting up SSH keys in 1Password



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/onepassword-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
