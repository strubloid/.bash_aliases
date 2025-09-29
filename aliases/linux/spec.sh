#!/bin/bash

# Strubloid::linux::spec

# spec starter basic-project 
alias spec-basic-project="uvx --from git+https://github.com/github/spec-kit.git specify init basic-project"

# spec starter here project
alias spec-here-project="uvx --from git+https://github.com/github/spec-kit.git specify init here"

# spec install requirements
spec-install-requirements() {
  
  # Check if uv is already installed
  if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
  else
    echo "uv is already installed"
  fi

  # Check if claude-code is already installed
  if ! npm list -g @anthropic-ai/claude-code &> /dev/null; then
    echo "Installing @anthropic-ai/claude-code..."
    npm install -g @anthropic-ai/claude-code
  else
    echo "@anthropic-ai/claude-code is already installed"
  fi

  # Check if gemini-cli is already installed
  if ! npm list -g @google/gemini-cli &> /dev/null; then
    echo "Installing @google/gemini-cli..."
    npm install -g @google/gemini-cli
  else
    echo "@google/gemini-cli is already installed"
  fi

}

# spec start project
spec-start-project() {

  # Loading the commit message
  if [ -z "$1" ]
  then
      read -p "[Project Name]: " ProjectName
  else
      # mounting the spec name
      ProjectName="$1"
  fi

  # Check if project name is empty
  if [ -z "$ProjectName" ]
  then
      echo "Error: Missing project name"
      return 1
  fi
  
  uvx --from git+https://github.com/github/spec-kit.git specify init "$ProjectName"

}
