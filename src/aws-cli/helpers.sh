#!/usr/bin/env bash

function aws() {
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
