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

## basic checks for pnpm
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

  ## would you like to build only the frontend?
  read -p "Would you like to build only the frontend? [y/N]: " CHECK_FRONTEND
  if [[ "$CHECK_FRONTEND" =~ ^[Yy]$ ]]; then
    pnpm --filter web build   ## builds only the frontend 
  else
    pnpm build                ## total build of the project
  fi

}

## checking errors of the pnpm and extracting the dependencies
function pnpm-checks(){

  # if pnpm not exists, we will install it
  if ! doesPnpmExist; then
    return 0
  fi

  echo "[] Running pnpm checks and extract commands...]"

  ## would you like to check the type errors?
  read -p "Would you like to check the type errors? [y/N]: " CHECK_TYPE_ERRORS
  if [[ "$CHECK_TYPE_ERRORS" =~ ^[Yy]$ ]]; then
    pnpm typecheck
  fi

  ## would you like to run the lint?
  read -p "Would you like to run lint? [y/N]: " CHECK_LINT
  if [[ "$CHECK_LINT" =~ ^[Yy]$ ]]; then
    pnpm lint
  fi

  ## would you like to run the tests?
  read -p "Would you like to run tests? [y/N]: " CHECK_TESTS
  if [[ "$CHECK_TESTS" =~ ^[Yy]$ ]]; then
    pnpm test
  fi

  ## would you like to run the security audit?
  read -p "Would you like to run security audit? [y/N]: " CHECK_AUDIT
  if [[ "$CHECK_AUDIT" =~ ^[Yy]$ ]]; then
    pnpm audit
  fi

  ## would you like to run the pnpm doctor?
  read -p "Would you like to run pnpm doctor? [y/N]: " CHECK_DOCTOR
  if [[ "$CHECK_DOCTOR" =~ ^[Yy]$ ]]; then
    pnpm doctor
  fi

  ## would you like to extract the dependencies?
  read -p "Would you like to extract dependencies? [y/N]: " CHECK_EXTRACT
  if [[ "$CHECK_EXTRACT" =~ ^[Yy]$ ]]; then
    pnpm -r extract
  fi

}

## running pnpm extract and detecting if any changes were made
function pnpm-extract() {

  # if pnpm not exists, we will install it
  if ! doesPnpmExist; then
    return 0
  fi

  ## capturing the state of changes before running extract
  local before_status
  before_status=$(git status --porcelain 2>/dev/null)

  echo "[] Running pnpm extract command...]"

  ## running the pnpm extract command to extract the dependencies
  pnpm -r extract

  ## capturing the state of changes after running extract
  local after_status
  after_status=$(git status --porcelain 2>/dev/null)

  ## comparing the states to determine if any changes were made
  if [[ "$before_status" != "$after_status" ]]; then
    echo "[x] Changes detected after extract."
    return 1
  fi

  echo "[✓] No changes detected after extract."
  return 0
}