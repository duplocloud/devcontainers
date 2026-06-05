## Shell Compatibility

The on-create script detects the remote user's login shell (from `/etc/passwd`, falling back to
`$SHELL`) and writes the direnv configuration to the matching interactive rc file — `~/.zshrc` for
zsh, `~/.bashrc` otherwise. It also installs the shell-appropriate hook: `eval "$(direnv hook zsh)"`
for zsh and `eval "$(direnv hook bash)"` for bash. This makes direnv activate correctly on
zsh-based images (such as the Anthropic secure-AI reference image), where `.bashrc` is never read
and the bash hook would not load.
