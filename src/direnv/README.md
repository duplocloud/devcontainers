
# Direnv (direnv)

Installs direnv and places a DuploCloud direnvrc at $HOME/direnv/direnvrc

## Example Usage

```json
"features": {
    "ghcr.io/duplocloud/devcontainers/direnv:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Shell Compatibility

The on-create script installs the direnv configuration into **every installed shell's** interactive
rc file — `~/.bashrc` with `eval "$(direnv hook bash)"` when `bash` is present, and `~/.zshrc` with
`eval "$(direnv hook zsh)"` when `zsh` is present (appends are idempotent). It deliberately does not
key off the login shell (`/etc/passwd` / `$SHELL`): images frequently install zsh and make it the
terminal's default shell without changing the user's login shell, so detecting a single shell leaves
the shell the terminal actually launches without the hook. Writing to each installed shell's rc makes
direnv activate regardless of which shell opens — including zsh-based images such as the Anthropic
secure-AI reference image.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/duplocloud/devcontainers/blob/main/src/direnv/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
