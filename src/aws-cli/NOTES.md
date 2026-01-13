# AWS CLI Feature Notes

## Auto Configuration with Duploctl JIT

This feature supports automatic AWS CLI configuration using duploctl's Just-In-Time (JIT) credentials.

### How It Works

When `jit` is enabled, the feature will automatically run `duploctl jit update_aws_config` during container creation to configure AWS CLI with JIT credentials.

### Configuration

Set `jit` to `true` in your devcontainer.json:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/aws-cli": {
      "jit": true
    }
  }
}
```

To use admin credentials, set `jitAdmin` to `true`:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/aws-cli": {
      "jit": true,
      "jitAdmin": true
    }
  }
}
```

To enable interactive mode (useful for caching credentials), set `jitInteractive` to `true`:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/aws-cli": {
      "jit": true,
      "jitInteractive": true
    }
  }
}
```

### Requirements

- Duploctl must be installed and properly configured
- The duploctl feature should be installed before aws-cli (handled automatically via `installsAfter`)

### Environment Variables

- `AWS_PROFILE`: Specifies the profile name to create (defaults to `default`)
- `AWS_CONFIG_FILE`: Specifies the AWS config file location (honored by duploctl automatically)

### Options

- `jit` (boolean, default: false): Enable JIT AWS CLI configuration on container creation
- `jitAdmin` (boolean, default: false): Use admin credentials with the `--admin` flag
- `jitInteractive` (boolean, default: false): Enable interactive mode with the `--interactive` flag

### Generated Configuration

The auto-configuration generates an AWS CLI profile with a credential process that uses duploctl:

```ini
[profile default]
region = us-west-2
credential_process = duploctl jit aws --host https://yourportal.duplocloud.net --admin
```

The generated command inherits the `--host`, `--admin`, and `--interactive` flags from your duploctl configuration.

### Troubleshooting

If you see errors during container creation, you probably don't have [Duplocloud credentials configured](https://cli.duplocloud.com/). 

### Manual Configuration

You can also manually configure AWS JIT credentials after container creation. This uses the [duploctl update_aws_config](https://cli.duplocloud.com/Jit/#duplo_resource.jit.DuploJit.update_aws_config) command to generate the profile.

Quick create your profile:
```bash
duploctl jit update_aws_config myprofile
```

## References

- [Duploctl JIT Documentation](https://cli.duplocloud.com/Jit/#duplo_resource.jit.DuploJit.update_aws_config)
- [Configuring environment variables for the AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html)
- [Creating and using aliases in the AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-usage-alias.html)
- [AWS CLI Devcontainer Feature](https://github.com/devcontainers/features/tree/main/src/aws-cli) - This feature installs the AWS CLI in a devcontainer. 
- [AWS Toolkit VSCode Extension](https://marketplace.visualstudio.com/items?itemName=AmazonWebServices.aws-toolkit-vscode)