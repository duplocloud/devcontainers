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
