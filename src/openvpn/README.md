
# OpenVPN Client (openvpn)

Installs OpenVPN client for connecting to VPN networks

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/openvpn:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| autoConnect | Automatically initialize and connect to VPN on container start. Set to false to only install the OpenVPN client. | boolean | true |

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


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/openvpn/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
