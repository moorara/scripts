#!/usr/bin/env sh

#
# USAGE:
#   ./install-helm.sh
#   ./install-helm.sh -r 2.12.3
#   ./install-helm.sh --release 2.12.3
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

  release=${release:-$(curl -s https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name')}
}

install_helm() {
  echo "Installing helm ${release} ..."

  archive=./helm.tar.gz
  helm=linux-amd64/helm
  tiller=linux-amd64/tiller
  path=/usr/local/bin/

  curl -fsSL "https://storage.googleapis.com/kubernetes-helm/helm-${release}-linux-amd64.tar.gz" -o ${archive}
  tar --strip-components=1 -C ${path} -xz -f ${archive} ${helm}
  tar --strip-components=1 -C ${path} -xz -f ${archive} ${tiller}
  rm ${archive}

  echo "helm ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_helm
