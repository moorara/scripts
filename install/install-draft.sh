#!/usr/bin/env sh

#
# USAGE:
#   ./install-draft.sh
#   ./install-draft.sh -r v0.16.0
#   ./install-draft.sh --release v0.16.0
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

  release=${release:-$(curl -s https://api.github.com/repos/Azure/draft/releases/latest | jq -r '.tag_name')}
}

install_draft() {
  echo "Installing draft ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  archive=./draft.tar.gz
  draft="${os}-${arch}/draft"
  path=/usr/local/bin/

  curl -fsSL "https://azuredraft.blob.core.windows.net/draft/draft-${release}-${os}-${arch}.tar.gz" -o ${archive}
  tar --strip-components=1 -C ${path} -xz -f ${archive} ${draft}
  rm ${archive}

  echo "draft ${release} installed successfully!"
}


ensure_command "curl" "jq"
process_args "$@"
install_draft
