#!/usr/bin/env sh

#
# This script installs the latest version of ShellCheck
# https://github.com/koalaman/shellcheck
#
# USAGE:
#   ./install-shellcheck.sh
#   ./install-shellcheck.sh -r 0.6.0
#   ./install-shellcheck.sh --release 0.6.0
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
  release="stable"

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
}

install_shellcheck() {
  echo "Installing shellcheck ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)

  archive=./shellcheck.tar.xz
  exec=shellcheck-$release/shellcheck
  path=/usr/local/bin/

  curl -fsSL "https://storage.googleapis.com/shellcheck/shellcheck-$release.$os.$arch.tar.xz" -o ${archive}
  tar --strip-components=1 -C ${path} --xz -xvf ${archive} "$exec"
  # tar -xz -xvf ${archive}
  # mv ${exec} ${path}
  rm -rf ${archive}

  echo "shellcheck ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_shellcheck
