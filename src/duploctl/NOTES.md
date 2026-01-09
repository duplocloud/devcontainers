# duploctl Feature Notes

## Version Selection

The `version` option controls which release of `duploctl` to install. Available versions can be found at [GitHub Releases](https://github.com/duplocloud/duploctl/releases/latest).

- **Default:** `latest` — installs the most recent version available on PyPI (pip only)
- **Specific version:** e.g., `v0.3.8` or `0.3.8` — installs that exact release

### Usage Examples

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:latest": {}
  }
}
```

Install default (latest from pip):

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/duploctl:latest": {
      "version": "v0.3.8"
    }
  }
}
```

Install a specific version.

## Installation Methods

The feature automatically selects the best installation method based on your container environment:

### Pip Install (Preferred)

If `python3` and `pip` are available in the container, `duploctl` is installed via pip to the user's scope (`pip install --user`). This keeps the system package manager clean and avoids conflicts.

- Uses version specified in the `version` option, or latest if `version: latest`
- Installed to `~/.local/bin` (managed by pip)

### Binary Install (Fallback)

If Python is not available, the feature downloads and installs a prebuilt binary from [GitHub Releases](https://github.com/duplocloud/duploctl/releases/latest).

- **Requires a specific version** — `version: latest` will fail with a clear error
- Binary is extracted to `~/.local/bin`
- Automatically detects your system architecture (amd64 or arm64) and OS (linux, darwin, windows)

Choose the binary installation method if your container doesn't include Python or if you prefer a self-contained executable.
