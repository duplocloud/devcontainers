#!/usr/bin/env bash

openv_if_exists() {
  local envfile="${1:-op.env}"
  [[ -f "$envfile" ]] || return 0
  watch_file "$envfile"
  direnv_load op run --env-file="$envfile" --no-masking -- direnv dump
}
