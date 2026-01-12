
# AWS CLI with Custom Aliases (aws-cli)

Installs AWS CLI with custom aliases and AWS Toolkit extension

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/aws-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| jit | Enable Just-In-Time (JIT) AWS CLI configuration using duploctl on container creation. Requires duploctl to be properly configured. | boolean | false |
| jitAdmin | Use admin credentials when configuring JIT. Adds --admin flag to duploctl command. | boolean | false |
| jitInteractive | Enable interactive mode when configuring JIT. Adds --interactive flag to duploctl command. | boolean | false |

## Customizations

### VS Code Extensions

- `amazonwebservices.aws-toolkit-vscode`

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

If you see errors during container creation:
- Ensure duploctl is properly configured with `duploctl configure`
- Verify you have the necessary permissions in your Duplo portal
- Check that the duploctl feature is installed

### Manual Configuration

You can also manually configure AWS JIT credentials after container creation:

```bash
duploctl jit update_aws_config myprofile
```

Or for admin access:

```bash
duploctl jit update_aws_config myportal --admin --interactive
```

## References

- [Duploctl JIT Documentation](https://cli.duplocloud.com/Jit/#duplo_resource.jit.DuploJit.update_aws_config)


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/aws-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
