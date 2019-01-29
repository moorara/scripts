#!/usr/bin/env sh

#
# USAGE:
#   ./install-kubectl.sh
#   ./install-kubectl.sh -r 1.13.2
#   ./install-kubectl.sh --release 1.13.2
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
      release="v$2"
      shift
      ;;
    esac
    shift
  done

  release=${release:-$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)}
}

install_kubectl() {
  echo "Installing kubectl ${release} ..."

  file=/usr/local/bin/kubectl

  curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${release}/bin/linux/amd64/kubectl" -o ${file}
  chmod 755 ${file}

  echo "kubectl ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_kubectl
