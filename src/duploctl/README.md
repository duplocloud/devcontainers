
# duploctl (duploctl)

Installs duploctl CLI via pip (if available) or prebuilt binary.

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version to install (e.g. v0.3.8). If 'latest' and pip is unavailable, falls back to v0.3.8 for binary install. | string | latest |

## Version Selection

The `version` option controls which release of `duploctl` to install. Available versions can be found at [GitHub Releases](https://github.com/duplocloud/duploctl/releases/latest).

- **Default:** `latest`
  - If `python3` + `pip` are available: installs the most recent version available on PyPI
  - If `pip` is not available: installs `v0.3.8` via a prebuilt binary (fallback)
- **Specific version:** e.g., `v0.3.8` or `0.3.8` — installs that exact release via pip (when available) or binary

### Usage Examples

Install default (`latest`):

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:latest": {}
  }
}
```

Install a specific version:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:latest": {
      "version": "v0.3.8"
    }
  }
}
```

## Installation Methods

The feature automatically selects the best installation method based on your container environment:

### Pip Install (Preferred)

If `python3` and `pip` are available in the container, `duploctl` is installed via pip. This is the preferred install method because it can install `latest` without needing to know a specific release tag.

- Uses version specified in the `version` option, or latest if `version: latest`
- Installed via `python3 -m pip`

### Binary Install (Fallback)

If Python is not available, the feature downloads and installs a prebuilt binary from [GitHub Releases](https://github.com/duplocloud/duploctl/releases/latest).

- If `version: latest`, the feature falls back to `v0.3.8` (hardcoded) to keep installs working in minimal images
- Binary is extracted to `/usr/local/bin`
- Automatically detects your system architecture (amd64 or arm64) and OS (linux, darwin, windows)

Choose the binary installation method if your container doesn't include Python or if you prefer a self-contained executable.

## References 

- [Duploctl JIT update_aws_config](https://cli.duplocloud.com/Jit/#duplo_resource.jit.DuploJit.update_aws_config) - Documentation for auto-configuring AWS CLI with JIT credentials


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/duploctl/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
