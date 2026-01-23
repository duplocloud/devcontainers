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

For service accounts or Connect Server, you can specify the vault ID directly:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "vaultID": "4icvhuuvzrssdm276agt5eldae",
      "autoSsh": true,
      "sshSecretNames": "GitHub SSH Key"
    }
  }
}
```

### Disabling the Feature

To completely disable the 1Password CLI feature (skip installation entirely), set the `enabled` option to `false`:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "enabled": false
    }
  }
}
```

This is useful when you want to temporarily disable 1Password integration without removing the feature configuration from your devcontainer.json. When disabled:
- No packages are installed
- No authentication is attempted
- No SSH configuration is performed
- The on-create script exits immediately

## Use Local Environment Variables

It's recommended to use the following template to use environment variables for injecting the features options. This way each user can configure the functionality from their own env. The localEnv is also how to read secrets from codespaces, ie each secret is an env var. 

```json
"ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
  "enabled": "${localEnv:OP_CLI_ENABLED}",
  "autoSsh": "${localEnv:OP_AUTO_SSH}",
  "sshSecretNames": "${localEnv:OP_SSH_SECRET}",
  "vault": "${localEnv:OP_VAULT_NAME}",
  "account": "${localEnv:OP_ACCOUNT}",
  "userEmail": "${localEnv:USER_EMAIL}"
}
```

Set these env vars in your user environment in one of: `.bashrc`, `.zshrc`, `.bash_profile`. You can even set these values in the Codespaces secrets UI for secure storage.

## Authentication Methods

The feature supports multiple authentication methods (checked in order):

1. **Connect Server**: Set `OP_CONNECT_HOST` and `OP_CONNECT_TOKEN` environment variables
2. **Service Account**: Set `OP_SERVICE_ACCOUNT_TOKEN` environment variable
3. **Desktop App Agent** (Linux only): Automatically detected if `~/.1password/agent.sock` exists
4. **Interactive Login**: Prompts for email/password (can be disabled with `disableInteractive: true`)
   - Supports automated password via `OP_PASSWD` environment variable (see [Interactive Login Requirements](#interactive-login-requirements))

If no authentication method succeeds, only the CLI is installed and a warning is displayed.

**Important**: When using Connect Server or Service Account authentication, you **must** specify a vault using either:
- The `vault` feature option (vault name) in devcontainer.json
- The `vaultID` feature option (vault ID) in devcontainer.json  
- The `OP_VAULT` environment variable (vault ID - takes precedence over a name)
- The `OP_VAULT_NAME` environment variable (vault name)

Some authentication methods require a vault to be specified for all item operations and automatically set `OP_FORMAT=json` for all terminal sessions. Mainly service accounts and Connect Server.

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

### Session Persistence (available in all terminal sessions):

- `OP_ACCOUNT` - The 1Password account domain (from `account` option or env var)
- `OP_VAULT_NAME` - The vault name (from `vault` option or env var)
- `OP_VAULT` - The vault ID (from `vaultID` option, env var, or resolved from vault name)
- `OP_FORMAT` - Set to `"json"` automatically for Connect/Service Account auth methods

**Precedence**: Environment variables already set take precedence over devcontainer feature options.

**Vault Configuration**: You can specify either:
- `vault`: The vault name (human-readable)
- `vaultID`: The vault ID (UUID format)
- Both ID and name are interchangeable in 1Password CLI commands
- When both are provided, the ID is preferred for better performance

**Important**: When using Connect Server or Service Account authentication, you **must** specify a vault using either the `vault` or `vaultID` option, or set the corresponding environment variable.
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

These can also be set manually in `containerEnv` to override the options in the feature. 

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

Search for secrets by tag (defaults to `ssh` tag):

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

**Note:** If both `sshSecretNames` and `sshSecretTags` are specified, `sshSecretNames` takes precedence.

### SSH Secret Requirements

**Built-in Fields from 1Password SSH Secret Type:**

When you import an SSH private key into 1Password, the SSH secret type automatically includes these fields:

| Field | Automatically Added | Description |
|-------|---------------------|-------------|
| `private key` | ✅ Yes | The SSH private key |
| `public key` | ✅ Yes | The SSH public key (derived from private key) |
| `fingerprint` | ✅ Yes | The SSH key fingerprint |
| `key type` | ✅ Yes | Type of SSH key (ed25519, rsa, etc.) |
| `key generated on` | ✅ If applicable | Date the key was generated (if created via extension) |

**Required Custom Fields for Auto SSH Config:**

For the feature to automatically create SSH config entries, you must manually add these custom fields to your SSH secret in 1Password:

| Field | Required for Auto Config | Description | Example Value |
|-------|--------------------------|-------------|---------------|
| `host` | ✅ Yes | The hostname for SSH connection | `github.com` |
| `username` | Recommended | SSH username (typically `git` for Git hosting) | `git` |
| `port` | Optional | SSH port (defaults to 22 if omitted) | `22` |

**Important Note:** Without the `host` field, the feature will only download the SSH keys but will not create SSH config entries. The `username` field is almost always `git` for Git hosting services like GitHub, GitLab, and Bitbucket.

### How SSH Authentication Works

The feature intelligently configures SSH based on whether an SSH agent is available. 

**SSH Agent in Devcontainers:**

VS Code devcontainers automatically forward the host's SSH agent into the container by binding the `SSH_AUTH_SOCK` socket. This means if you have an SSH agent running on your host (such as the 1Password SSH agent), it will be available inside the devcontainer without additional configuration.

For specific platform setup instructions, see [1Password SSH Agent Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/#ssh-auth-sock) which covers configuration for macOS, Linux, and Windows with devcontainers.

**With SSH Agent Available:**
- Downloads only the **public key** (`.pub`)
- `IdentityFile` points to the public key
- `IdentityAgent` is configured to use the agent (when 1Password agent is detected)
- Private key is accessed securely through the agent
- Biometric authentication can be used (on supported platforms)

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

## Interactive Login Requirements

When using interactive login (method 4 in the authentication methods), the feature will prompt you to add your 1Password account if it's not already configured. The interactive login process requires:

### Account Setup Prompts

When adding a new 1Password account, you will be prompted for:

1. **Email address** - Your 1Password account email
   - Can be pre-configured with the `userEmail` option to skip this prompt
   - required on first login
2. **Secret Key** - Your 1Password Secret Key (34-character key)
   - This is always required interactively on first login
3. **Master Password** - Your 1Password master password
   - Required twice on first login(once to add account, once to sign in (unless `OP_PASSWD` is set, see below))

**Example with pre-configured email:**
```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "userEmail": "user@example.com",
      "account": "my.1password.com"
    }
  }
}
```

### Automated Password Authentication with OP_PASSWD

To avoid manual password entry during interactive login, set the `OP_PASSWD` environment variable:

```json
{
  "containerEnv": {
    "OP_PASSWD": "${localEnv:OP_PASSWD}"
  },
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "userEmail": "user@example.com",
      "account": "my.1password.com"
    }
  }
}
```

**When OP_PASSWD is set:**
- Password is passed via stdin to `op signin` command
- Eliminates interactive password prompts
- Useful for automated devcontainer startup without manual interaction
- **Especially powerful when combined with persisted op data** (via `XDG_CONFIG_HOME` on a mounted volume) - enables fully automatic login on every container restart

**When OP_PASSWD is not set:**
- Falls back to interactive password prompt
- User must manually enter password twice (add account + sign in)

**Security Warning:** Be cautious when using `OP_PASSWD` as it exposes your password in environment variables. Consider using more secure authentication methods like Service Account tokens or Connect Server.

## Session Persistence Across Container Restarts

### Preventing Repeated Account Setup with XDG_CONFIG_HOME

By default, 1Password CLI stores account data in the home directory. When the devcontainer is rebuilt or restarted, this data is lost and you must re-add your account.

To persist 1Password data across container restarts, configure `XDG_CONFIG_HOME` to point to a directory within your workspace:

```json
{
  "containerEnv": {
    "XDG_CONFIG_HOME": "${containerWorkspaceFolder}/.config"
  },
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "userEmail": "user@example.com",
      "account": "my.1password.com"
    }
  }
}
```

**How it works:**
- 1Password CLI respects the `XDG_CONFIG_HOME` environment variable
- Account data is stored in `$XDG_CONFIG_HOME/op/` instead of `~/.config/op/`
- When pointing to a workspace directory, account data persists in your workspace
- Subsequent container restarts will find the existing account configuration

**Benefits:**
- No need to re-add your account every time the container restarts
- Account configuration is preserved across container rebuilds
- Sign-in is faster (only need to authenticate, not re-add account)

**Important:** Make sure to add `.config/` to your `.gitignore` to avoid committing 1Password account data to version control:

```bash
echo ".config/" >> .gitignore
```

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

On macOS, you need to configure a Launch Agent to properly expose the 1Password SSH agent socket to your devcontainer. Follow the macOS-specific instructions at [1Password SSH Agent Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/#ssh-auth-sock).

### Verifying SSH Agent

After the container starts, verify the SSH agent is configured:

```bash
ssh-add -l
```

This should list the keys available in your 1Password SSH agent.

## References 

- [1Password CLI Documentation](https://developer.1password.com/docs/cli) - Official CLI reference and setup guides
- [1Password Connect Server](https://developer.1password.com/docs/connect) - Deploy Connect server for automated secret access
- [1Password SSH Agent Compatibility](https://developer.1password.com/docs/ssh/agent/compatibility/#ssh-auth-sock) - SSH agent setup for macOS, Linux, and Windows with devcontainers
- [SSH Key Management in 1Password](https://support.1password.com/ssh-agent/) - Setting up SSH keys in 1Password

