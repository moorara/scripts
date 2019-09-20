#!/usr/bin/env bash

#
# This file contains helper functions for GitHub.
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'


function ensure_repo_clean {
  status=$(git status --porcelain | tail -n 1)
  if [[ -n $status ]]; then
    echo -e "${red}Working direcrory is not clean.${nocolor}"
    exit 1
  fi
}

function get_repo_name {
  if [ "$(git remote -v)" == "" ]; then
    echo -e "${red}GitHub repo not fonud.${nocolor}"
    exit 1
  fi

  repo_name=$(
    git remote -v |
    sed -n 's/origin[[:blank:]]git@github.com://; s/.git[[:blank:]](push)// p'
  )
}

# GITHUB_TOKEN should be set
function disable_master_protection {
  echo -e "${yellow}Temporarily disabling master branch protection ...${nocolor}"
  curl "https://api.github.com/repos/$repo_name/branches/master/protection/enforce_admins" \
    -s -o /dev/null \
    -X DELETE \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json"
}

# GITHUB_TOKEN should be set
function enable_master_protection {
  echo -e "${yellow}Re-enabling master branch protection ...${nocolor}"
  curl "https://api.github.com/repos/$repo_name/branches/master/protection/enforce_admins" \
    -s -o /dev/null \
    -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json"
}
