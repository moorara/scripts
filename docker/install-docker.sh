#!/bin/bash

#
# USAGE:
#   ./install-docker.sh
#   ./install-docker.sh -r 18.06.1-ce
#   ./install-docker.sh --release 18.06.1-ce
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
purple='\033[1;35m'
blue='\033[1;36m'
nocolor='\033[0m'


function ensure_command {
  for cmd in $@; do
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

  release=${release:-$(curl -s https://download.docker.com/linux/static/stable/x86_64/ | grep -oe '[.0-9]*-ce' | tail -n 1)}
}

function install_docker {
  printf "${blue}Installing docker ${release} ...${nocolor}\n"

  os=$(uname -s | tr [:upper:] [:lower:])
  arch=$(uname -m)
  archive=./docker.tgz
  path=/usr/local/bin/

  curl -fsSL https://download.docker.com/${os}/static/stable/${arch}/docker-${release}.tgz -o ${archive}
  tar -xz --strip-components=1 -C ${path} -f ${archive}
  rm ${archive}

  printf " ${green}docker ${release} installed successfully!${nocolor}\n"
}


ensure_command "grep" "tar" "curl"
process_args
install_docker
