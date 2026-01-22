# OpenVPN CLI Feature

## Required Configuration

This feature automatically adds `NET_ADMIN` and `NET_RAW` capabilities. However, you must manually add the TUN device to your devcontainer.json:

```json
"runArgs": ["--device=/dev/net/tun"]
```

This is required because the devcontainer features spec does not support adding devices directly.

## Full Example

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/openvpn:1": {}
  },
  "runArgs": ["--device=/dev/net/tun"]
}
```

## Configuration Directory

By default, OpenVPN configuration files are stored in:
- `$XDG_CONFIG_HOME/openvpn` if `XDG_CONFIG_HOME` is set
- `$HOME/.config/openvpn` otherwise

You can customize this location using the `configDir` option:

```json
{
  "features": {
    "ghcr.io/duplocloud/devcontainers/openvpn:1": {
      "configDir": "/custom/path/to/openvpn"
    }
  }
}
```

This is useful when you need to store configuration in a specific location for persistence or access control reasons.
