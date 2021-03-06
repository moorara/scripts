#!/usr/bin/env sh

#
# USAGE:
#   ./install-docker.sh
#   ./install-docker.sh -r 18.09.4
#   ./install-docker.sh --release 18.09.4
#

set -euo pipefail


ensure_command() {
  for cmd in "$@"; do
    hash $cmd 2> /dev/null || (
      echo "$cmd not available!"
      exit 1
    )
  done
}

process_args() {
  while [ $# -gt 1 ]; do
    key=$1
    case $key in
      -r|--release)
      release=$2
      shift
      ;;
    esac
    shift
  done

  release=${release:-$(curl -s https://download.docker.com/linux/static/stable/x86_64/ | grep -oE '[.0-9]{2}\.[0-9]{2}\.[0-9](-ce)?' | tail -n 1)}
}

install_docker() {
  echo "Installing docker ${release} ..."

  os=linux
  arch=x86_64
  archive=./docker.tgz
  path=/usr/local/bin/

  curl -fsSL "https://download.docker.com/${os}/static/stable/${arch}/docker-${release}.tgz" -o ${archive}
  tar --strip-components=1 -C ${path} -xz -f ${archive}
  rm ${archive}

  echo "docker ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_docker
