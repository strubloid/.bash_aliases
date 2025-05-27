#!/bin/bash

echoMainHeader() {
  echo -e "\n\033[1;30m🤘 $1\033[0m"
}

echoBasicHeader() {
  echo -e "\033[1;37m $1\033[0m"
}

echoRockHeader() {
  echo -e "\033[1;34m🤘 $1\033[0m"
}

echoPunchHeader() {
  echo -e "\n\033[1;12m👊 $1\033[0m"
}
echoHeader() {
  echo -e "\n\033[1;36m🚀 $1\033[0m"
}

echoOption() {
  echo -e "\n\033[1;36m $1\033[0m"
}

echoCoolPink()
{
  echo -e "\033[1;35m $1\033[0m"
}


echoLine() {
  # Check if this is a DEBUG message
  if [[ "$1" == *"[DEBUG]"* ]] || [[ "$1" == *"[debug]"* ]]; then
    # Only print debug messages if DEBUG=1
    if [[ "$DEBUG" == "1" ]]; then
      echo -e "  \033[1;34m🔍 $1\033[0m"
    fi
  elif [[ "$1" == *"[ERR]"* ]] || [[ "$1" == *"[err]"* ]]; then
    # Error messages in red
    echo -e "  \033[1;31m❌ $1\033[0m"
  elif [[ "$1" == *"[WARN]"* ]] || [[ "$1" == *"[warn]"* ]]; then
    # Warning messages in yellow
    echo -e "  \033[1;33m⚠️  $1\033[0m"
  else
    # Regular messages with a checkmark
    echo -e "  \033[1;32m✅ $1\033[0m"
  fi
}