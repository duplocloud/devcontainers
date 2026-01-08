#!/usr/bin/env bash  

function exists_in_list() {
    [[ $1 =~ (^|[[:space:]])$2($|[[:space:]]) ]]
}

function duplo-rdp-master() {
    local profile="${1:-$AWS_PROFILE}" instance_id
    [ -z "$profile" ] && echo "missing AWS profile" && return 1

    echo -n "$profile: duplo-master: searching .. "
    instance_id="$(
        aws --profile="$profile" ec2 describe-instances --filters "Name=tag:Name,Values=Duplo-Master" \
            --output=json | jq -r '.Reservations[].Instances[].InstanceId'
    )"
    [ -z "$instance_id" ] && echo NOT FOUND && return 1
    echo $instance_id
    
    echo -n "$profile: duplo-master: starting RDP session .. "
    if aws --profile="$1" ssm start-session --target "$instance_id" --document-name AWS-StartPortForwardingSession --parameters portNumber="3389",localPortNumber="56789"
    then echo done
    else echo FAILED ; return 1
    fi
}

function aws() {
  # check if the first param is ctx
  if [ "$1" == "ctx" ]; then
    aws-ctx
  elif [ "$1" == "region" ]; then
    aws-region
  else
    command aws "$@"
  fi
}

function aws-ctx() {
  export AWS_PROFILE="$(aws configure list-profiles | fzf)"
  export AWS_ACCOUNT_ID="$(aws id)"
  echo "Switched to profile \"$AWS_PROFILE\"."
}
function aws-region() {
  export AWS_REGION="$(aws ec2 describe-regions --query "Regions[].[RegionName]" --output text | fzf)"
  echo "Switched to region \"$AWS_REGION\"."
}

function gcloud() {
  # check if the first param is ctx
  if [ "$1" == "ctx" ]; then
    local selected project_id
    selected="$(gcloud config configurations list --format="value(name)" | fzf)"
    command gcloud config configurations activate "$selected"
    project_id="$(gcloud config get project)"
    command gcloud auth application-default set-quota-project "${project_id}"
  else
    command gcloud "$@"
  fi
}



function chrome() {
  local chrome_profile="${CHROME_PROFILE:-Default}"
  open -n -a "Google Chrome" --args --profile-directory=$chrome_profile $1
}

function workspace_list() {
  find "$WORKSPACE_HOME" -type d -maxdepth 1 | sed 's|.*/||'
}

function workspace() {
  local wksp_select wksp
  wksp_select="${1:-$(fzf --print-query <<< "$(workspace_list)" | tail -1)}"
  # if nothing was chosen then let the user know
  [ -z "$wksp_select" ] && echo "No workspace selected or it does not exist" && return 1
  wksp="$WORKSPACE_HOME/$wksp_select"

  # check if the workspace exists
  if [ ! -d "$wksp" ]; then
    read -r -p "$wksp_select does not exist, create it now? [Y/n]" answer
    if [[ $answer =~ ^[Yy]$ || $answer == "" ]]; then
        new_customer "$wksp_select"
    else
        echo "Never mind"
        return 1
    fi
  fi
  echo "Loading $wksp_select"
  AWS_CONFIG_FILE="$wksp/config/aws" \
  WORKSPACE="$wksp_select" \
  code "$wksp/$wksp_select.code-workspace"
}

_workspace() {
  local workspaces cur
  workspaces="$(workspace_list)"
  cur=${COMP_WORDS[COMP_CWORD]}
  mapfile -t COMPREPLY < <(compgen -W "${workspaces}" -- "${cur}")
  return 0
}

complete -F _workspace workspace
complete -C aws_completer aws

function new_customer() {
  local wrkdir="$WORKSPACE_HOME/$1"
  local wkspc="$wrkdir/$1.code-workspace"
  mkdir -p "$wrkdir" "$wrkdir/config" "$wrkdir/.vscode"
  cat <<EOF > "$wrkdir/.envrc"
export CONF_DIR="\$(pwd)/config"
export AWS_CONFIG_FILE="\${CONF_DIR}/aws"
export KUBECONFIG="\${CONF_DIR}/kubeconfig.yaml"
export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
export AWS_PROFILE=$1
EOF
  cat <<EOF > "$wrkdir/config/aws"
[profile $1]
region = $AWS_DEFAULT_REGION
output = json
credential_process=duplo-jit aws --admin --host https://$1.duplocloud.net --interactive
EOF
  cat <<EOF > "$wkspc"
{
	"folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "vs-kubernetes": {
      "vs-kubernetes.kubeconfig": "$wrkdir/config/kubeconfig.yaml",
    }
  }
}
EOF
  cat <<EOF > "$wrkdir/.vscode/settings.json"
{
  "files.exclude": {}
}
EOF
}
