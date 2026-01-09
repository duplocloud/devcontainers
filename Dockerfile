FROM ghcr.io/devcontainers/templates/python:5.0.0 as devcontainer

# common utils
RUN <<EOF 
apt-get update
apt-get -y install --no-install-recommends \
  direnv fzf curl gnupg
EOF
