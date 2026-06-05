## Shell Compatibility

The on-create script installs the direnv configuration into **every installed shell's** interactive
rc file — `~/.bashrc` with `eval "$(direnv hook bash)"` when `bash` is present, and `~/.zshrc` with
`eval "$(direnv hook zsh)"` when `zsh` is present (appends are idempotent). It deliberately does not
key off the login shell (`/etc/passwd` / `$SHELL`): images frequently install zsh and make it the
terminal's default shell without changing the user's login shell, so detecting a single shell leaves
the shell the terminal actually launches without the hook. Writing to each installed shell's rc makes
direnv activate regardless of which shell opens — including zsh-based images such as the Anthropic
secure-AI reference image.
