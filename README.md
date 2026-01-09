# DuploCloud Devcontainers

A curated list of dev workspace features to help anyone with a DuploCloud powered workspace. 

## Project Structure 

The following sections are each a directory or file in the top level of the repo and a description of what's inside. 

### `src`

A number of features for devcontainers are included for ultimate customization. Each of these are distributed to the Github artifacts and can be used by other devcontainers to add functionality. 

## Features

The following devcontainer features are available in this repository:

- **[aws-cli](src/aws-cli/)** - Installs AWS CLI with custom aliases
- **[direnv](src/direnv/)** - Installs direnv and a DuploCloud direnvrc
- **[gcloud-cli](src/gcloud-cli/)** - Installs Google Cloud CLI with multi-architecture support
- **[onepassword-cli](src/onepassword-cli/)** - Installs 1Password CLI with proper GPG key verification
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

### Terraform Docs

Useful docs for Terraform in reference to this repo:

- [Terraform Devcontainer Feature](https://github.com/devcontainers/features/tree/main/src/terraform) - Official Terraform feature for devcontainers
