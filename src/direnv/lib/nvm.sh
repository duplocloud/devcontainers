#!/usr/bin/env bash

use_nvm() {
  local node_version last_version
  
  # if no version provided try and use .nvmrc
  if [[ -z $1 ]]; then
    if [[ -f .nvmrc ]]; then
      echo "using .nvmrc file"
      node_version=$(cat .nvmrc)
    else
      echo "no .nvmrc file found"
      exit 1
    fi
  else
    echo "using provided version"
    node_version=$1
  fi

  # check nvm installed
  nvm_sh=~/.nvm/nvm.sh
  if [[ -e $nvm_sh ]]; then
    source $nvm_sh
  else
    echo "nvm not installed"
    exit 1
  fi

  # check if version is installed
  last_version=$(nvm ls "$node_version" | tail -1 | tr -d '[:space:]')
  if [[ $last_version == "N/A" ]]; then
    echo "version $node_version is not installed"
    nvm install "$node_version"
  else 
    nvm use "$node_version"
  fi

  # builtin direnv node layout to finish
  layout node
}
