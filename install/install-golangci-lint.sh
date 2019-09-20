#!/usr/bin/env bash

#
# USAGE:
#   ./install-golangci-lint.sh
#   ./install-golangci-lint.sh -r v1.15.0
#   ./install-golangci-lint.sh --release v1.15.0
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

  release=${release:-$(curl -s https://api.github.com/repos/golangci/golangci-lint/releases/latest | jq -r '.tag_name')}
  version=${release#v}
}

install_golangci_lint() {
  echo "Installing golangci-lint ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  archive=./golangci-lint.tar.gz
  file="golangci-lint-${version}-${os}-${arch}/golangci-lint"
  path=/usr/local/bin/

  curl -fsSL "https://github.com/golangci/golangci-lint/releases/download/${release}/golangci-lint-${version}-${os}-${arch}.tar.gz" -o ${archive}
  tar --strip-components=1 -C ${path} -xz -f ${archive} ${file}
  rm ${archive}

  echo "golangci-lint ${release} installed successfully!"
}


ensure_command "curl" "jq"
process_args "$@"
install_golangci_lint
