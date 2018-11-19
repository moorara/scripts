#!/bin/bash

#
# USAGE:
#   ./install-compose.sh
#   ./install-compose.sh -r 1.22.0
#   ./install-compose.sh --release 1.22.0
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'


function ensure_command {
  for cmd in "$@"; do
    which $cmd &> /dev/null || (
      printf "${red}$cmd not available!${nocolor}\n"
      exit 1
    )
  done
}

function process_args {
  while [[ $# > 0 ]]; do
    key=$1
    case $key in
      -r|--release)
      release=$2
      shift
      ;;
    esac
    shift
  done

  release=${release:-$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')}
}

function install_compose {
  printf "${blue}Installing docker-compose ${release} ...${nocolor}\n"

  os=$(uname -s)
  arch=$(uname -m)
  file=/usr/local/bin/docker-compose

  curl -fsSL "https://github.com/docker/compose/releases/download/${release}/docker-compose-${os}-${arch}" -o ${file}
  chmod 755 ${file}

  printf " ${green}docker-compose ${release} installed successfully!${nocolor}\n"
}


ensure_command "curl" "jq"
process_args "$@"
install_compose
