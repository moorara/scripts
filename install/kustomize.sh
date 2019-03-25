#!/usr/bin/env sh

#
# USAGE:
#   ./install-kustomize.sh
#   ./install-kustomize.sh -r 2.0.3
#   ./install-kustomize.sh --release 2.0.3
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

  release=${release:-$(curl -s https://api.github.com/repos/kubernetes-sigs/kustomize/releases/latest | jq -r '.tag_name')}
  version=${release#v}
}

install_kustomize() {
  echo "Installing kustomize ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  file=/usr/local/bin/kustomize

  curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/${release}/kustomize_${version}_${os}_${arch}" -o ${file}
  chmod 755 ${file}

  echo "kustomize ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_kustomize
