#!/usr/bin/env sh

#
# USAGE:
#   ./install-kubectl.sh
#   ./install-kubectl.sh -r v1.14.0
#   ./install-kubectl.sh --release v1.14.0
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

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  file=/usr/local/bin/kubectl

  curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${release}/bin/${os}/${arch}/kubectl" -o ${file}
  chmod 755 ${file}

  echo "kubectl ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_kubectl
