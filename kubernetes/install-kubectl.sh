#!/bin/bash

#
# USAGE:
#   ./install-kubectl.sh
#   ./install-kubectl.sh -r 1.12.1
#   ./install-kubectl.sh --release 1.12.1
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
      release="v$2"
      shift
      ;;
    esac
    shift
  done

  release=${release:-$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)}
}

function install_kubectl {
  printf "${blue}Installing kubectl ${release} ...${nocolor}\n"

  file=/usr/local/bin/kubectl

  curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${release}/bin/linux/amd64/kubectl" -o ${file}
  chmod +x ${file}

  printf " ${green}kubectl ${release} installed successfully!${nocolor}\n"
}


ensure_command "curl"
process_args "$@"
install_kubectl
