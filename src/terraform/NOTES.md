## Usage

This feature installs DuploCloud Terraform helpers that simplify working with Terraform in DuploCloud environments.

### Commands Available

After installation, you can use either:
- `tf` - DuploCloud-enhanced Terraform wrapper with automatic configuration
- `terraform` - Standard Terraform CLI

### Using the `tf` Command

The `tf` command is a wrapper around Terraform that provides automatic DuploCloud integration:

```bash
# Use tf instead of terraform for DuploCloud-aware operations
tf init
tf plan
tf apply
tf destroy

# Switch workspace interactively with fzf
tf ctx

# All standard terraform commands still work
tf validate
tf state list
```

### Features

**Automatic Variable File Detection:**
- Automatically finds and applies the correct `.tfvars` file based on workspace
- Searches for `config/{workspace}/{module}.tfvars` in the project hierarchy
- Supports both `.tfvars` and `.tfvars.json` formats

**DuploCloud Token Integration:**
- Exports `duplo_token` and `duplo_host` environment variables
- Integrates with `duploctl` for authentication

**Multi-Cloud Backend Configuration:**
- Automatically configures Terraform backend for AWS, GCP, or Azure
- Detects cloud provider from DuploCloud portal settings
- Sets up state locking and remote state storage

**Interactive Workspace Selection:**
- Use `tf ctx` to interactively select workspace using fzf
- Creates new workspaces on-the-fly if they don't exist

### Environment Variables

- `TF_WORKSPACE_DIR` - Override the default config directory search path
- `DUPLO_TF_BUCKET` - Override the default Terraform state bucket name
- `DUPLO_TOKEN` - DuploCloud API token (set automatically by duploctl)
- `DUPLO_HOST` - DuploCloud portal URL (set automatically by duploctl)

### Examples

**Basic workflow:**
```bash
# Initialize with DuploCloud backend
tf init

# Select workspace
tf ctx

# Plan with automatic tfvars
tf plan

# Apply changes
tf apply
```

**Working with modules:**
```bash
# Use with -chdir for module-specific operations
tf -chdir=modules/vpc plan
tf -chdir=modules/vpc apply
```

**Custom workspace directory:**
```bash
export TF_WORKSPACE_DIR=/path/to/config
tf plan
```

## Implementation Details

The feature installs `tf.sh` in two locations:
- `/usr/local/bin/tf` - Executable wrapper (use as `tf` command)
- `/usr/local/share/duplocloud/tf.sh` - Sourceable shell script (for functions)

Both files are sourced in shell rc files (`.bashrc`, `.zshrc`, `/etc/bash.bashrc`) to make the helper functions available in interactive shells.

## References 

- [Terraform Devcontainer Feature](https://github.com/devcontainers/features/tree/main/src/terraform) - Official Terraform feature for devcontainers
- [Duplocloud Docs for Provider](https://docs.duplocloud.com/docs/automation-platform/terraform-support/duplocloud-terraform-provider) - Describes the DuploCloud Terraform methodology when using our provider. 
