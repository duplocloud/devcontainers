## Shell Compatibility

The on-create script configures **every installed shell's** interactive rc file — `~/.bashrc` when
`bash` is present and `~/.zshrc` when `zsh` is present (appends are idempotent). Each rc sources the
shell-appropriate gcloud SDK include files (`path.bash.inc` / `completion.bash.inc` for bash, the
`.zsh.inc` variants for zsh) plus the gcloud helper functions. It deliberately does not key off the
login shell (`/etc/passwd` / `$SHELL`), because images often install zsh as the terminal's default
without changing the user's login shell, which would leave the actually-used shell unconfigured. This
makes the gcloud CLI path and completion load correctly on zsh-based images (such as the Anthropic
secure-AI reference image) as well as bash.
