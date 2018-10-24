#!/bin/sh

#
# USAGE:
#   ./install-docker.sh
#   ./install-docker.sh -d 18.06.1-ce
#   ./install-docker.sh --docker 18.06.1-ce
#   ./install-docker.sh -d 18.06.1-ce -c 1.22.0
#   ./install-docker.sh --docker 18.06.1-ce --compose 1.22.0
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
      -d|--docker)
      docker_version=$2
      shift
      ;;
      -c|--compose)
      compose_version=$2
      shift
      ;;
    esac
    shift
  done

  docker_version=${docker_version:-$(curl -s https://download.docker.com/linux/static/stable/x86_64/ | grep -oe '[.0-9]*-ce' | tail -n 1)}
  compose_version=${compose_version:-$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')}
}

function install_docker {
  printf "${blue}Installing docker ${docker_version} ...${nocolor}\n"

  os=$(uname -s | tr [:upper:] [:lower:])
  arch=$(uname -m)
  file=./docker.tgz
  path=/usr/local/bin/

  curl -fsSL https://download.docker.com/${os}/static/stable/${arch}/docker-${docker_version}.tgz -o ${file}
  tar -xz --strip-components=1 -f ${file} -C ${path}
  rm ${file}

  printf " ${green}docker ${docker_version} installed successfully!${nocolor}\n"
}

function install_docker_compose {
  printf "${blue}Installing docker-compose ${compose_version} ...${nocolor}\n"

  os=$(uname -s)
  arch=$(uname -m)
  path=/usr/local/bin/docker-compose

  curl -fsSL https://github.com/docker/compose/releases/download/${compose_version}/docker-compose-${os}-${arch} -o ${path}
  chmod +x ${path}

  printf " ${green}docker-compose ${compose_version} installed successfully!${nocolor}\n"
}


ensure_command "grep" "tar" "curl" "jq"
process_args
install_docker
install_docker_compose
