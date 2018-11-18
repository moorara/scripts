#!/bin/bash

#
# USAGE:
#   ./install-helm.sh
#   ./install-helm.sh -r 2.11.0
#   ./install-helm.sh --release 2.11.0
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

  release=${release:-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name')}
}

function install_helm {
  printf "${blue}Installing helm ${release} ...${nocolor}\n"

  archive=./helm.tar.gz
  helm=linux-amd64/helm
  tiller=linux-amd64/tiller
  path=/usr/local/bin/

  curl -fsSL "https://storage.googleapis.com/kubernetes-helm/helm-${release}-linux-amd64.tar.gz" -o ${archive}
  tar -xz --strip-components=1 -C ${path} -f ${archive} ${helm}
  tar -xz --strip-components=1 -C ${path} -f ${archive} ${tiller}
  rm ${archive}

  printf " ${green}helm ${release} installed successfully!${nocolor}\n"
}


ensure_command "curl"
process_args "$@"
install_helm
