#!/usr/bin/env sh

#
# USAGE:
#   ./install-skaffold.sh
#   ./install-skaffold.sh -r v0.26.0
#   ./install-skaffold.sh --release v0.26.0
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

  release=${release:-$(curl -s https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest | jq -r '.tag_name')}
}

install_skaffold() {
  echo "Installing skaffold ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  file=/usr/local/bin/skaffold

  curl -fsSL "https://github.com/GoogleContainerTools/skaffold/releases/download/${release}/skaffold-${os}-${arch}" -o ${file}
  chmod 755 ${file}

  echo "skaffold ${release} installed successfully!"
}


ensure_command "curl" "jq"
process_args "$@"
install_skaffold
