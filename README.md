# Customer Workspace 

A repo that builds the base for customer specific workspaces. This builds the base images that come with all of the common tools and scripts we use. 

## Project Structure 

The following sections are each a directory or file in the top lefvel of the repo and a description of what's inside. 

### `aws`

Contains the AWS CLI Alias extensions. This is to be copied into a users home directory under `~/.aws/cli/alias/` to extend the AWS CLI with custom commands.

### `scripts` 

Contains various helper scripts that are used to setup and manage the workspace environment. Also handles a lot of wrappers around popular tools to do custom tasks.

### `features`

A number of features for devcontainers are included for ultimate customization. Each of these are distributed to the Github artifacts and can be used by other devcontainers to add functionality. 

## Features

The following devcontainer features are available in this repository:

- **[aws-cli](features/aws-cli/)** - Installs AWS CLI with custom aliases and AWS Toolkit extension
- **[gcloud-cli](features/gcloud-cli/)** - Installs Google Cloud CLI with multi-architecture support
- **[onepassword-cli](features/onepassword-cli/)** - Installs 1Password CLI with proper GPG key verification
- **[openvpn-cli](features/openvpn-cli/)** - Installs OpenVPN client for connecting to VPN networks
- **[terraform](features/terraform/)** - Installs Terraform with DuploCloud-specific helper functions for multi-cloud state management

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