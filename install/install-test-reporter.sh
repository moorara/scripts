#!/usr/bin/env sh

#
# USAGE:
#   ./install-test-reporter.sh
#   ./install-test-reporter.sh -r 0.6.4
#   ./install-test-reporter.sh --release 0.6.4
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

  release=${release:-"latest"}
}

install_test_reporter() {
  echo "Installing test reporter ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  file=/usr/local/bin/test-reporter

  curl -fsSL -o ${file} "https://codeclimate.com/downloads/test-reporter/test-reporter-${release}-${os}-${arch}"
  chmod 755 ${file}

  echo "test reporter ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_test_reporter
