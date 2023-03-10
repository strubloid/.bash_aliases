#!/bin/bash

# Strubloid::linux::cockroach

# This will install the cockroach
function cockroach-install(){

  # going to the home folder
  cd "$HOME"

  ## creating the new cockroach folder
  mkdir -p cockroach

  ## download the cockroach and moving to a binary folder
  curl https://binaries.cockroachdb.com/cockroach-v22.2.3.linux-amd64.tgz | tar -xz && sudo cp -i cockroach-v22.2.3.linux-amd64/cockroach /usr/local/bin/

}

## This will download the key and save in the correct place under home/.postgresql
function cockroach-download-certificate()
{
  curl --create-dirs -o "$HOME"/.postgresql/root.crt -O https://cockroachlabs.cloud/clusters/92b2110e-3d79-4ab9-af50-88c0b1dd5466/cert
}

# Check for the instruction of DATABASE_BILLS_URL on ~/.bashrc
## passwords
## 1 - tUCY6irv1PL09XuASN5NhQ
## 2 - MhG6t991OfJaKUjuGZMo0A
# cockroach sql --url "postgresql://rafael:MhG6t991OfJaKUjuGZMo0A@hungry-bird-923.8nj.cockroachlabs.cloud:26257/bills?sslmode=verify-full&sslrootcert=$HOME/.postgresql/root.crt"
function cockroach-login()
{
  cockroach sql --url "$DATABASE_BILLS_URL"
}



