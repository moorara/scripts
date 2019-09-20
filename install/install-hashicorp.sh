#!/usr/bin/env sh

#
# USAGE:
#
#   ./install-hashicorp.sh -k hashicorp.asc -p packer
#   ./install-hashicorp.sh -k hashicorp.asc -p packer -r 1.4.2
#   ./install-hashicorp.sh --key hashicorp.asc --project packer --release 1.4.2
#
#   ./install-hashicorp.sh -k hashicorp.asc -p terraform
#   ./install-hashicorp.sh -k hashicorp.asc -p terraform -r 0.12.3
#   ./install-hashicorp.sh --key hashicorp.asc --project terraform --release 0.12.3
#
#   ./install-hashicorp.sh -k hashicorp.asc -p consul
#   ./install-hashicorp.sh -k hashicorp.asc -p consul -r 1.5.2
#   ./install-hashicorp.sh --key hashicorp.asc --project consul --release 1.5.2
#
#   ./install-hashicorp.sh -k hashicorp.asc -p vault
#   ./install-hashicorp.sh -k hashicorp.asc -p vault -r 1.1.3
#   ./install-hashicorp.sh --key hashicorp.asc --project vault --release 1.1.3
#
#   ./install-hashicorp.sh -k hashicorp.asc -p nomad
#   ./install-hashicorp.sh -k hashicorp.asc -p nomad -r 0.9.3
#   ./install-hashicorp.sh --key hashicorp.asc --project nomad --release 0.9.3
#

set -eu


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
    arg=$1
    case $arg in
      -k|--key)
      key="$2"
      shift
      ;;
      -p|--project)
      project="$2"
      shift
      ;;
      -r|--release)
      release="$2"
      shift
      ;;
    esac
    shift
  done

  key=${key:-"hashicorp.asc"}
  semver_regex='[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}'
  latest_release=$(curl -s "https://releases.hashicorp.com/${project}/" | grep -oE "${project}_${semver_regex}</a>" | grep -oE "$semver_regex" | head -n 1)
  release=${release:-$latest_release}
}

install_project() {
  echo "Installing ${project} ${release} ..."

  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=amd64
  # file="/usr/local/bin/${project}"

  wget -q "https://releases.hashicorp.com/${project}/${release}/${project}_${release}_SHA256SUMS"
  wget -q "https://releases.hashicorp.com/${project}/${release}/${project}_${release}_SHA256SUMS.sig"
  wget -q "https://releases.hashicorp.com/${project}/${release}/${project}_${release}_${os}_${arch}.zip"

  gpg --import "${key}"
  gpg --verify "${project}_${release}_SHA256SUMS.sig" "${project}_${release}_SHA256SUMS"
  sed -i "/${project}_${release}_${os}_${arch}.zip$/!d" "${project}_${release}_SHA256SUMS"
  sha256sum -c "${project}_${release}_SHA256SUMS" | grep "${project}_${release}_${os}_${arch}.zip: OK"
  unzip "${project}_${release}_${os}_${arch}.zip" -d /usr/local/bin/
  chmod 755 "/usr/local/bin/${project}"
  rm "${project}_${release}_SHA256SUMS" "${project}_${release}_SHA256SUMS.sig" "${project}_${release}_${os}_${arch}.zip"

  echo "${project} ${release} installed successfully!"
}


ensure_command "curl"
process_args "$@"
install_project
