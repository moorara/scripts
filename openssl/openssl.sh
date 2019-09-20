#!/bin/bash

#
# This script generates OpenSSL chain of certificates
# USAGE:
#   -p, --path      The absolute root path for certificates
#   -c, --cert      The certificate type (root, intermediate, server, user)
#   -n, --name      The name for user/client certificate
#
# EXAMPLES:
#   ./openssl.sh -p /path/to/root -c root
#   ./openssl.sh -p /path/to/root -c intermediate
#   ./openssl.sh -p /path/to/root -c server -n server
#   ./openssl.sh -p /path/to/root -c client -n client
#

set -euo pipefail


red='\033[1;31m'
green='\033[1;32m'
yellow='\033[1;33m'
blue='\033[1;36m'
nocolor='\033[0m'


function whitelist_variable {
  if [[ ! $2 =~ (^|[[:space:]])$3($|[[:space:]]) ]]; then
    echo "Invalid $1 $3"
    exit 1
  fi
}

function ensure_available {
  for cmd in "$@"; do
    which $cmd 1> /dev/null || (
      echo "$cmd not available!"
      exit 1
    )
  done
}

function parse_args {
  cert_type=
  root_path=
  cert_name=

  while [[ $# -gt 1 ]]; do
    arg="$1"
    case $arg in
      -c|--cert)
        cert_type="$2"
        shift
        ;;
      -p|--path)
        root_path="$2"
        shift
        ;;
      -n|--name)
        cert_name="$2"
        shift
        ;;
    esac
    shift
  done

  cert_type=${cert_type:-"none"}
  root_path=${root_path:-$(pwd)/root/ca}

  whitelist_variable "certificate type" "root intermediate server user" "$cert_type"

  if [[ "$cert_type" == "server" ]] && [ -z "$cert_name" ]; then
    Echo "Please specify a domain for certificate using -n or --name"
    exit 1
  fi

  if [[ "$cert_type" == "user" ]] && [ -z "$cert_name" ]; then
    Echo "Please specify a name for certificate using -n or --name"
    exit 1
  fi
}

function gen_root_ca {
  # Clean Workspace
  rm -rf "$root_path"

  # Initialize
  mkdir -p "$root_path"
  cd "$root_path"
  mkdir certs crl newcerts private
  chmod 700 private
  touch index.txt
  echo 1000 > serial
  cd -

  # OpenSSL Configurations
  echo -e "${green}Creating The Root OpenSSL Config File ...${nocolor}"
  root_path_escaped=${root_path//\//\\\/}
  sed "s/BASE_PATH/$root_path_escaped/g" openssl.root.cnf > "$root_path/openssl.cnf"

  # Create Root Key
  echo -e "${green}Creating The Root Key ...${nocolor}"
  openssl genrsa \
    -aes256 \
    -out "$root_path/private/ca.key.pem" 4096
  chmod 400 "$root_path/private/ca.key.pem"

  # Create Root Certificate
  echo -e "${green}Creating The Root Certificate ...${nocolor}"
  openssl req \
    -config "$root_path/openssl.cnf" \
    -extensions v3_ca \
    -new -x509 -days 7300 -sha256 \
    -key "$root_path/private/ca.key.pem" \
    -out "$root_path/certs/ca.cert.pem"
  chmod 444 "$root_path/certs/ca.cert.pem"

  # Verify Root Certificate
  echo -e "${green}Verifying The Root Certificate ...${nocolor}"
  openssl x509 \
    -noout -text \
    -in "$root_path/certs/ca.cert.pem"
}

function gen_intermediate_ca {
  # Clean Workspace
  rm -rf "$root_path/intermediate"

  # Initialize
  mkdir -p "$root_path/intermediate"
  cd "$root_path/intermediate"
  mkdir certs crl csr newcerts private
  chmod 700 private
  touch index.txt
  echo 1000 > serial
  echo 1000 > crlnumber
  cd -

  # OpenSSL Configurations
  echo -e "${blue}Creating The Intermediate OpenSSL Config File ...${nocolor}"
  intermediate_path_escaped=${root_path//\//\\\/}\\\/intermediate
  sed "s/BASE_PATH/$intermediate_path_escaped/g" openssl.intermediate.cnf > "$root_path/intermediate/openssl.cnf"

  # Create Intermediate Key
  echo -e "${blue}Creating The Intermediate Key ...${nocolor}"
  openssl genrsa \
    -aes256 \
    -out "$root_path/intermediate/private/intermediate.key.pem" 4096
  chmod 400 "$root_path/intermediate/private/intermediate.key.pem"

  # Create Intermediate CSR
  echo -e "${blue}Creating The Intermediate Certificate Signing Request (CSR) ...${nocolor}"
  openssl req \
    -config "$root_path/intermediate/openssl.cnf" \
    -new -sha256 \
    -key "$root_path/intermediate/private/intermediate.key.pem" \
    -out "$root_path/intermediate/csr/intermediate.csr.pem"

  # Sign Intermediate CSR
  echo -e "${blue}Signing The Intermediate Certificate Request ...${nocolor}"
  openssl ca \
    -config "$root_path/openssl.cnf" \
    -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 \
    -in "$root_path/intermediate/csr/intermediate.csr.pem" \
    -out "$root_path/intermediate/certs/intermediate.cert.pem"
  chmod 444 "$root_path/intermediate/certs/intermediate.cert.pem"

  # Create Certificate Chain
  echo -e "${blue}Creating The Certificate Chain File ...${nocolor}"
  cat "$root_path/intermediate/certs/intermediate.cert.pem" "$root_path/certs/ca.cert.pem" > "$root_path/intermediate/certs/ca-chain.cert.pem"
  chmod 444 "$root_path/intermediate/certs/ca-chain.cert.pem"

  # Verify Intermediate Certificate
  echo -e "${blue}Verifying The Intermediate Certificate ...${nocolor}"
  openssl x509 \
    -noout -text \
    -in "$root_path/intermediate/certs/intermediate.cert.pem"
  openssl verify \
    -CAfile "$root_path/certs/ca.cert.pem" "$root_path/intermediate/certs/intermediate.cert.pem"
}

function gen_server_cert {
  # Initialize
  mkdir -p "$root_path/intermediate/server"
  cd "$root_path/intermediate/server"
  mkdir certs csr private
  chmod 700 private
  cd -

  # Create Certificate Key
  echo -e "${red}Creating The Certificate Key ...${nocolor}"
  openssl genrsa \
    -out "$root_path/intermediate/server/private/$cert_name.key.pem" 2048
  chmod 400 "$root_path/intermediate/server/private/$cert_name.key.pem"

  # Create Certificate CSR
  echo -e "${red}Creating The Certificate Signing Request (CSR) ...${nocolor}"
  openssl req \
    -config "$root_path/intermediate/openssl.cnf" \
    -new -sha256 \
    -key "$root_path/intermediate/server/private/$cert_name.key.pem" \
    -out "$root_path/intermediate/server/csr/$cert_name.csr.pem"

  # Sign Certificate CSR
  echo -e "${red}Signing The Certificate Request ...${nocolor}"
  openssl ca \
    -config "$root_path/intermediate/openssl.cnf" \
    -extensions server_cert \
    -days 375 -notext -md sha256 \
    -in "$root_path/intermediate/server/csr/$cert_name.csr.pem" \
    -out "$root_path/intermediate/server/certs/$cert_name.cert.pem"
  chmod 444 "$root_path/intermediate/server/certs/$cert_name.cert.pem"

  # Verify Certificate
  echo -e "${red}Verifying The Certificate ...${nocolor}"
  openssl x509 \
    -noout -text \
    -in "$root_path/intermediate/server/certs/$cert_name.cert.pem"
  openssl verify \
    -CAfile "$root_path/intermediate/certs/ca-chain.cert.pem" "$root_path/intermediate/server/certs/$cert_name.cert.pem"
}

function gen_user_cert {
  # Initialize
  mkdir -p "$root_path/intermediate/user"
  cd "$root_path/intermediate/user"
  mkdir certs csr private
  chmod 700 private
  cd -

  # Create Certificate Key
  echo -e "${yellow}Creating The Certificate Key ...${nocolor}"
  openssl genrsa \
    -out "$root_path/intermediate/user/private/$cert_name.key.pem" 2048
  chmod 400 "$root_path/intermediate/user/private/$cert_name.key.pem"

  # Create Certificate CSR
  echo -e "${yellow}Creating The Certificate Signing Request (CSR) ...${nocolor}"
  openssl req \
    -config "$root_path/intermediate/openssl.cnf" \
    -new -sha256 \
    -key "$root_path/intermediate/user/private/$cert_name.key.pem" \
    -out "$root_path/intermediate/user/csr/$cert_name.csr.pem"

  # Sign Certificate CSR
  echo -e "${yellow}Signing The Certificate Request ...${nocolor}"
  openssl ca \
    -config "$root_path/intermediate/openssl.cnf" \
    -extensions user_cert \
    -days 375 -notext -md sha256 \
    -in "$root_path/intermediate/user/csr/$cert_name.csr.pem" \
    -out "$root_path/intermediate/user/certs/$cert_name.cert.pem"
  chmod 444 "$root_path/intermediate/user/certs/$cert_name.cert.pem"

  # Verify Certificate
  echo -e "${yellow}Verifying The Certificate ...${nocolor}"
  openssl x509 \
    -noout -text \
    -in "$root_path/intermediate/user/certs/$cert_name.cert.pem"
  openssl verify \
    -CAfile "$root_path/intermediate/certs/ca-chain.cert.pem" "$root_path/intermediate/user/certs/$cert_name.cert.pem"
}


parse_args "$@"
ensure_available "sed" "openssl"

case $cert_type in
  root)
    gen_root_ca
    ;;
  intermediate)
    gen_intermediate_ca
    ;;
  server)
    gen_server_cert
    ;;
  user)
    gen_user_cert
    ;;
esac
