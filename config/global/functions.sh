#!/bin/bash

echoHeader() {
  echo -e "\n(Action) $1"
}

echoLine() {
  # Check if this is a DEBUG message
  if [[ "$1" == *"[DEBUG]"* ]] || [[ "$1" == *"[debug]"* ]]; then
    # Only print debug messages if DEBUG=1
    if [[ "$DEBUG" == "1" ]]; then
      echo -e "  $1"
    fi
  else
    # Always print non-debug messages
    echo -e "  $1"
  fi
}