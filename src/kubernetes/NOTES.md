## Usage

The kubernetes feature configures kubectl to work with DuploCloud managed Kubernetes clusters using JIT (Just-In-Time) authentication.

### Basic Configuration

Add to your `.devcontainer/devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:1": {},
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {}
  }
}
```

This will:
- Install kubectl, helm, and minikube (automatically via dependency)
- Install the Kubernetes VS Code extension
- Generate a kubeconfig on container creation using `duploctl update_kubeconfig`

### Configuration Options

**Note:** This feature installs kubectl 1.32 by default (hardcoded to avoid [known upstream bugs](https://github.com/devcontainers/features/issues/1410) with "latest"). The kubectl version cannot be customized due to devcontainer spec limitations with passing options to dependency features.

#### JIT Authentication

Enable or disable automatic kubeconfig generation:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {
      "jit": true
    }
  }
}
```

**Default:** `true`

#### Admin Access

Use admin privileges when your token has admin rights:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {
      "jitAdmin": true
    }
  }
}
```

**Default:** `false`  
**Note:** Required for using the `plan` option.

#### Interactive Browser Authentication

Enable browser-based authentication flow:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {
      "jitInteractive": true
    }
  }
}
```

**Default:** `false`  
**Warning:** Cannot be used in non-interactive environments (like GitHub Codespaces without attached terminal).

#### Plan/Infrastructure

Specify the DuploCloud plan (infrastructure) to use:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {
      "jitAdmin": true,
      "plan": "prod"
    }
  }
}
```

**Alternative:** Set `DUPLO_PLAN` environment variable (takes precedence)  
**Requires:** `jitAdmin: true`

#### Tenant

Scope into a specific DuploCloud tenant:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {
      "tenant": "my-tenant"
    }
  }
}
```

**Alternative:** Set `DUPLO_TENANT` environment variable (takes precedence)

### Complete Example

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:1": {
      "version": "latest"
    },
    "ghcr.io/duplocloud/devcontainers/kubernetes:1": {
      "jit": true,
      "jitAdmin": true,
      "tenant": "dev-team"
    }
  },
  "containerEnv": {
    "DUPLO_HOST": "https://mycompany.duplocloud.net",
    "DUPLO_TOKEN": "${localEnv:DUPLO_TOKEN}"
  }
}
```

### How It Works

1. **On Install**: The feature stores configuration for later use
2. **On Container Creation**: Runs `duploctl update_kubeconfig` with configured options
3. **Kubeconfig Generation**: 
   - Queries DuploCloud API for K8s cluster details
   - Creates/updates `~/.kube/config`
   - Configures exec-based authentication using `duploctl jit k8s`
4. **kubectl Commands**: Each kubectl command triggers JIT token retrieval via the exec plugin

### Manual Configuration

If you disabled JIT or need to regenerate:

```bash
# Basic tenant access
duploctl update_kubeconfig --tenant my-tenant

# Admin access with plan
duploctl update_kubeconfig --admin --plan prod

# With interactive browser login
duploctl update_kubeconfig --interactive --tenant my-tenant
```

### Troubleshooting

**Kubeconfig not generated:**
- Ensure `duploctl` feature is installed before this feature
- Check that `DUPLO_HOST` and `DUPLO_TOKEN` environment variables are set
- Verify JIT is enabled: `jit: true`

**Interactive mode not working:**
- Interactive mode requires an attached terminal
- Use `jitInteractive: false` for automated environments
- Consider using token-based auth instead

**Permission errors:**
- Admin operations require `jitAdmin: true`
- Verify your DuploCloud token has appropriate permissions
- Check tenant access rights

### References

- [duploctl update_kubeconfig docs](https://cli.duplocloud.com/Jit/#duplo_resource.jit.DuploJit.update_kubeconfig)
- [Kubernetes VS Code Extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
- [kubectl-helm-minikube feature](https://github.com/devcontainers/features/tree/main/src/kubectl-helm-minikube)
