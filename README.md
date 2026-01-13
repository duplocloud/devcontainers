# DuploCloud Devcontainers

A curated list of dev workspace features to help anyone with a DuploCloud powered workspace. 

## Project Structure 

The following sections are each a directory or file in the top level of the repo and a description of what's inside. 

### `src`

A number of features for devcontainers are included for ultimate customization. Each of these are distributed to the Github artifacts and can be used by other devcontainers to add functionality. 

### `tests`

Test scripts for each feature are included here. These can be run locally or in CI to verify the features work as expected.

## Features

The following devcontainer features are available in this repository:

- **[aws-cli](src/aws-cli/)** - Installs AWS CLI with custom aliases
- **[direnv](src/direnv/)** - Installs direnv and a DuploCloud direnvrc
- **[gcloud-cli](src/gcloud-cli/)** - Installs Google Cloud CLI with multi-architecture support
- **[git](src/git/)** - Configures git with user settings, signing keys, plugins, and global gitignore
- **[onepassword-cli](src/onepassword-cli/)** - Installs 1Password CLI with automatic SSH key configuration
- **[openvpn](src/openvpn/)** - Installs OpenVPN client for connecting to VPN networks
- **[terraform](src/terraform/)** - Installs Terraform with DuploCloud-specific helper functions

## Creating Features

Each feature lives in `src/<feature-name>/` with this structure:

```
src/<feature-name>/
├── devcontainer-feature.json  # Metadata, options, dependencies
├── install.sh                 # Installation script (runs as root)
└── (optional files)           # Additional scripts or configs
```

### devcontainer-feature.json

Defines the feature metadata per the [Features Schema](https://containers.dev/implementors/features/):

```json
{
  "id": "my-feature",
  "version": "1.0.0",
  "name": "My Feature",
  "description": "What it does",
  "options": {
    "version": {
      "type": "string",
      "default": "latest"
    }
  },
  "installsAfter": []
}
```

### install.sh

Runs during container build. Access options via environment variables (`$VERSION`).

```bash
#!/usr/bin/env bash
set -e
echo "Installing with version: ${VERSION}"
```

### Testing Features

Tests live in `test/<feature-name>/test.sh`. Run with:

```bash
devcontainer features test -f <feature-name> .
```

See [Feature Starter Repo](https://github.com/devcontainers/feature-starter) for full testing patterns.

## Feature Documentation

### Git Configuration

The **git** feature configures git with user credentials, SSH signing keys, and custom plugins:

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

**Key Features:**
- Configurable user name and email (with fallback to `GIT_USER`/`GIT_EMAIL` environment variables)
- SSH-based commit signing when signing key is provided
- Automatic workspace safe directory configuration
- Global gitignore with common patterns (.DS_Store, *.log, *.tmp)
- Custom git plugins: `git-bump` (semantic versioning) and `git-setenv` (CI environment variables)

Integrates with **onepassword-cli** to automatically fetch and configure SSH keys.

### 1Password CLI

The **onepassword-cli** feature installs 1Password CLI with optional automatic SSH key configuration:

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

**Authentication Methods** (checked in order):
1. Connect Server (`OP_CONNECT_HOST` and `OP_CONNECT_TOKEN`)
2. Service Account Token (`OP_SERVICE_ACCOUNT_TOKEN`)
3. Interactive login (can be disabled with `disableInteractive: true`)

**Auto SSH Configuration:**
- Automatically fetch and configure SSH keys from 1Password secrets
- Supports filtering by secret names (comma-separated) or tags
- Each secret should have `private key` and `public key` fields
- Optional `host` field enables automatic SSH config entries

**Example: Complete Git + 1Password Setup**

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/onepassword-cli:1": {
      "vault": "Work",
      "autoSsh": true,
      "sshSecretNames": "GitHub SSH Key"
    },
    "ghcr.io/duplocloud/devcontainers/git:1": {
      "userName": "Your Name",
      "userEmail": "you@example.com",
      "signingKey": "GitHub_SSH_Key.pub"
    }
  }
}
```

## Devcontainer Base Image

Use **runtime images**, not template artifacts:

| ✅ Use | ❌ Avoid |
|--------|----------|
| `mcr.microsoft.com/vscode/devcontainers/python:3.11` | `ghcr.io/devcontainers/templates/python:*` |

Template images (`application/vnd.devcontainers`) cannot be used as Docker base images.

## Capabilities 

### Syncs to Many Agent Formats

This project keeps the agents and prompts in a generalized format not specific to any tool. 

## References 

### Devcontainer Docs 

Helpful links for learning and understanding devcontainers:

- [Devcontainer CLI Git Repo](https://github.com/devcontainers/cli)
- [Feature Starter Github Repo](https://github.com/devcontainers/feature-starter) - The template repo for building devcontainer features.
- [Developing inside a container - vscode](https://code.visualstudio.com/docs/devcontainers/containers)
- [Github Codespaces Intro to Devcontainers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers)
- [Available Dev Container Templates](https://containers.dev/templates)
- [Available Dev Container Features](https://containers.dev/features)
- [Schema for Features json](https://containers.dev/implementors/features/)

### AWS Docs

Useful docs for AWS CLI in reference to this repo:

- [Configuring environment variables for the AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html)
- [Creating and using aliases in the AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-usage-alias.html)
- [AWS CLI Devcontainer Feature](https://github.com/devcontainers/features/tree/main/src/aws-cli) - This feature installs the AWS CLI in a devcontainer. 
- [AWS Toolkit VSCode Extension](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode)

### Duploctl Docs

Useful docs for duploctl in reference to this repo:

- [Duploctl JIT update_aws_config](https://cli.duplocloud.com/Jit/#duplo_resource.jit.DuploJit.update_aws_config) - Documentation for auto-configuring AWS CLI with JIT credentials

### Terraform Docs

Useful docs for Terraform in reference to this repo:

- [Terraform Devcontainer Feature](https://github.com/devcontainers/features/tree/main/src/terraform) - Official Terraform feature for devcontainers

### 1Password Docs

Useful docs for 1Password in reference to this repo:

- [1Password CLI Documentation](https://developer.1password.com/docs/cli) - Official CLI reference and setup guides
- [1Password Connect Server](https://developer.1password.com/docs/connect) - Deploy Connect server for automated secret access
- [SSH Key Management in 1Password](https://support.1password.com/ssh-agent/) - Setting up SSH keys in 1Password
