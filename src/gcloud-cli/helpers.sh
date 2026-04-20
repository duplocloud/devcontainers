#!/usr/bin/env bash

function gcloud() {
  if [ "$1" == "ctx" ]; then
    local selected project_id
    selected="$(command gcloud config configurations list --format="value(name)" | fzf)"
    command gcloud config configurations activate "$selected"
    project_id="$(command gcloud config get project)"
    command gcloud auth application-default set-quota-project "${project_id}"
  else
    command gcloud "$@"
  fi
}
