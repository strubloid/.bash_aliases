#!/bin/bash

# Strubloid::linux::pnpm

## checking if pnpm exists
function doesPnpmExist() {
  if command -v pnpm &>/dev/null; then
    echo "pnpm is already installed."
    return 0
  else
    echo "pnpm is not installed."
    return 1
  fi
}

## installing the pnpm
function check-and-install-pnpm() {

  # if pnpm exists, we don't need to install it
  if doesPnpmExist; then
    return 0
  fi

  echo "pnpm not found. Installing latest binary..."
  curl -fsSL https://get.pnpm.io/install.sh | sh -
}

## checking errors of the pnpm and extracting the dependencies
function check-pnpm(){

  # if pnpm not exists, we will install it
  if ! doesPnpmExist; then
    return 0
  fi

  echo "[] Running pnpm check and extract commands...]"

  ## running the pnpm check command to check for errors
  pnpm check

  echo "[] Running pnpm extract command...]"

  ## running the pnpm extract command to extract the dependencies
  pnpm -r extract

}