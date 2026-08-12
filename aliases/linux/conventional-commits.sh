#!/bin/bash

# Strubloid::linux::conventional-commits

# Internal helper: assembles and executes a conventional commit
cc-commit-run() {
  local TYPE="$1"
  local SCOPE="$2"
  local BREAKING="$3"
  local DESCRIPTION="$4"
  local BODY="$5"
  local BREAKING_DESC="$6"

  # Build the header: <type>[(scope)][!]: <description>
  local HEADER="${TYPE}"
  if [ -n "$SCOPE" ]; then
    HEADER="${HEADER}(${SCOPE})"
  fi
  if [[ "$BREAKING" =~ [yY](es)?$ ]]; then
    HEADER="${HEADER}!"
  fi
  HEADER="${HEADER}: ${DESCRIPTION}"

  # Build the full commit message
  local COMMIT_MESSAGE="${HEADER}"
  if [ -n "$BODY" ]; then
    COMMIT_MESSAGE="${COMMIT_MESSAGE}"$'\n\n'"${BODY}"
  fi
  if [[ "$BREAKING" =~ [yY](es)?$ ]] && [ -n "$BREAKING_DESC" ]; then
    COMMIT_MESSAGE="${COMMIT_MESSAGE}"$'\n\n'"BREAKING CHANGE: ${BREAKING_DESC}"
  fi

  echo "-----------------------------------------------------------------------------"
  echo "  Conventional Commit  ------------------------------------------------------"
  echo "-----------------------------------------------------------------------------"
  echo "[TYPE] - ${TYPE}"
  echo "[SCOPE] - ${SCOPE:-none}"
  echo "[BREAKING] - ${BREAKING}"
  echo "[HEADER] - ${HEADER}"
  echo "-----------------------------------------------------------------------------"

  git commit -m "$COMMIT_MESSAGE"
}

# Internal helper: prompts the user for the conventional commit fields
cc-prompt-and-run() {
  local TYPE="$1"

  # Description (required) - can be passed as $2 to skip the prompt
  local DESCRIPTION="$2"
  if [ -z "$DESCRIPTION" ]; then
    read -p "[Description]: " DESCRIPTION
  fi

  # Optional scope
  local SCOPE
  read -p "[Scope - optional, e.g. (parser)]: " SCOPE

  # Breaking change?
  local BREAKING
  read -p "[Breaking change? y/N]: " BREAKING

  # Optional body
  local BODY
  read -p "[Body - optional, press enter to skip]: " BODY

  # Breaking change description (only if breaking)
  local BREAKING_DESC=""
  if [[ "$BREAKING" =~ [yY](es)?$ ]]; then
    read -p "[Breaking change description]: " BREAKING_DESC
  fi

  cc-commit-run "$TYPE" "$SCOPE" "$BREAKING" "$DESCRIPTION" "$BODY" "$BREAKING_DESC"
}

# feat: introduces a new feature to the codebase (correlates with MINOR in SemVer)
function cc-feat()
{
  cc-prompt-and-run "feat" "$1"
}

# fix: patches a bug in the codebase (correlates with PATCH in SemVer)
function cc-fix()
{
  cc-prompt-and-run "fix" "$1"
}

# build: changes that affect the build system or external dependencies
function cc-build()
{
  cc-prompt-and-run "build" "$1"
}

# chore: other changes that don't modify src or test files
function cc-chore()
{
  cc-prompt-and-run "chore" "$1"
}

# ci: changes to CI configuration files and scripts
function cc-ci()
{
  cc-prompt-and-run "ci" "$1"
}

# docs: documentation only changes
function cc-docs()
{
  cc-prompt-and-run "docs" "$1"
}

# style: changes that do not affect the meaning of the code (whitespace, formatting, etc.)
function cc-style()
{
  cc-prompt-and-run "style" "$1"
}

# refactor: a code change that neither fixes a bug nor adds a feature
function cc-refactor()
{
  cc-prompt-and-run "refactor" "$1"
}

# perf: a code change that improves performance
function cc-perf()
{
  cc-prompt-and-run "perf" "$1"
}

# test: adding missing tests or correcting existing tests
function cc-test()
{
  cc-prompt-and-run "test" "$1"
}

# revert: reverts a previous commit
function cc-revert()
{
  cc-prompt-and-run "revert" "$1"
}
