## Shell Compatibility

The on-create script detects the remote user's login shell (from `/etc/passwd`, falling back to
`$SHELL`) and configures the matching interactive rc file — `~/.zshrc` for zsh, `~/.bashrc`
otherwise. It sources the shell-appropriate gcloud SDK include files (`path.zsh.inc` /
`completion.zsh.inc` for zsh, the `.bash.inc` variants for bash) plus the gcloud helper functions.
This makes the gcloud CLI path and completion load correctly on zsh-based images (such as the
Anthropic secure-AI reference image), where `.bashrc` is never read.
