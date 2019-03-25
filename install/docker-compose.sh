#!/usr/bin/env sh

#
# USAGE:
#   ./install-compose.sh
#   ./install-compose.sh -r 1.24.0
#   ./install-compose.sh --release 1.24.0
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

  release=${release:-$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')}
}

install_compose() {
  echo "Installing docker-compose ${release} ..."

  os=$(uname -s)
  arch=$(uname -m)
  file=/usr/local/bin/docker-compose

  curl -fsSL "https://github.com/docker/compose/releases/download/${release}/docker-compose-${os}-${arch}" -o ${file}
  chmod 755 ${file}

  echo "docker-compose ${release} installed successfully!"
}


ensure_command "curl" "jq"
process_args "$@"
install_compose
