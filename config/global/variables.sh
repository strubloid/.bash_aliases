#!/bin/bash

## This will check what is the operational system loaded
function getOperationalSystem() {
  case "$OSTYPE" in
  linux*)
    # Check if running in WSL
    if grep -qi microsoft /proc/version 2>/dev/null || uname -r | grep -qi microsoft; then
      echo "wsl"
    else
      echo "linux"
    fi
    ;;
  darwin*) echo "mac" ;;
  win*) echo "windows" ;;
  msys*) echo "msys" ;;
  cygwin*) echo "cygwin" ;;
  bsd*) echo "bsd" ;;
  solaris*) echo "solaris" ;;
  *) echo "unknown" ;;
  esac
}

# Operational System
OS=$(getOperationalSystem)

# Root folder for the bash_aliases project
PWD_PROJECT_FOLDER=$(pwd)

## It will be adding variables to the bash_profile file
if [ "$OS" = "mac" ]; then
  BASHRC_FILE="$HOME/.zshrc"
else
  BASHRC_FILE="$HOME/.bashrc"
fi

# Project separator lines
SEPARATOR_BEGIN="#strubloid# .bash_aliases project global variables"
SEPARATOR_END="#strubloid# .bash_aliases project global variables end"

## Build PATH lines based on OS
build_path_lines() {
  local lines=""

  # Base PATH
  lines+='export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'$'\n'

  if [ "$OS" = "wsl" ]; then
    # WSL-specific paths
    lines+='export PATH="$PATH:/usr/lib/wsl/lib"'$'\n'

    # Python
    lines+='export PATH="$PATH:/mnt/c/Program Files/Python311/Scripts"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/Python311"'$'\n'

    # Java
    lines+='export PATH="$PATH:/mnt/c/Program Files/Common Files/Oracle/Java/javapath"'$'\n'

    # NVIDIA / GPU
    lines+='export PATH="$PATH:/mnt/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.5/bin"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v12.5/libnvvp"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files (x86)/NVIDIA Corporation/PhysX/Common"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/NVIDIA Corporation/Nsight Compute 2024.2.1"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/NVIDIA Corporation/NVIDIA NvDLISR"'$'\n'

    # Windows system
    lines+='export PATH="$PATH:/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/WINDOWS/System32/Wbem"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/WINDOWS/System32/OpenSSH"'$'\n'

    # Development tools
    lines+='export PATH="$PATH:/mnt/c/Program Files/nodejs"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Roaming/npm"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/docker"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/Git/cmd"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/ProgramData/chocolatey/bin"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/usbipd-win"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/socialstream"'$'\n'

    # Android
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Local/Android/Sdk/platform-tools"'$'\n'

    # Touch Portal
    lines+='export PATH="$PATH:/mnt/c/Program Files (x86)/Touch Portal/plugins/adb/platform-tools"'$'\n'

    # PyEnv
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/.pyenv/pyenv-win/bin"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/.pyenv/pyenv-win/shims"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/.pyenv/bin"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/.pyenv/shims"'$'\n'

    # User apps
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Local/Microsoft/WindowsApps"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Local/Programs/Hyper/resources/bin"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/.dotnet/tools"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Program Files/Microsoft VS Code/bin"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Local/Programs/Python/Python311"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Local/Programs/Python/Python311/Scripts"'$'\n'
    lines+='export PATH="$PATH:/mnt/c/Users/strubloid/AppData/Roaming/Code/User/globalStorage/github.copilot-chat/debugCommand"'$'\n'

  elif [ "$OS" = "linux" ]; then
    # Linux-specific extras
    lines+='export PATH="$PATH:/usr/games:/usr/local/games:/snap/bin"'$'\n'
    lines+='export PATH="/usr/local/git/bin:/usr/local/mysql/bin:$PATH"'$'\n'

  elif [ "$OS" = "mac" ]; then
    # Mac-specific extras (add as needed)
    lines+='export PATH="/usr/local/git/bin:$PATH"'$'\n'
  fi

  echo "$lines"
}

## Build the full block to insert
VARIABLE_BLOCK="$SEPARATOR_BEGIN
$(build_path_lines)
export BASH_ALIASES_PROJECT_FOLDER=${PWD_PROJECT_FOLDER}
$SEPARATOR_END"

## Insert or update the block in bashrc
if grep -q "$SEPARATOR_BEGIN" "$BASHRC_FILE" && grep -q "$SEPARATOR_END" "$BASHRC_FILE"; then
  # Update: replace the first block, remove any duplicates
  tmp_file=$(mktemp)
  awk -v begin="$SEPARATOR_BEGIN" -v end="$SEPARATOR_END" -v block="$VARIABLE_BLOCK" '
    $0 == begin && !replaced { print block; replaced=1; skip=1; next }
    $0 == begin && replaced { skip=1; next }
    $0 == end { skip=0; next }
    !skip { print }
  ' "$BASHRC_FILE" > "$tmp_file"
  mv "$tmp_file" "$BASHRC_FILE"
else
  # First install: insert before bash_profile sourcing or append
  BASH_PROFILE_LINE_CHECK="if [ -f ~/.bash_profile ]; then"
  if grep -qF "$BASH_PROFILE_LINE_CHECK" "$BASHRC_FILE"; then
    tmp_file=$(mktemp)
    awk -v pattern="if.*.bash_profile.*then" -v block="$VARIABLE_BLOCK" -v done=0 '
      $0 ~ pattern && !done { print ""; print block; print ""; done=1 }
      { print }
    ' "$BASHRC_FILE" > "$tmp_file"
    mv "$tmp_file" "$BASHRC_FILE"
  else
    printf "\n%s\n" "$VARIABLE_BLOCK" >> "$BASHRC_FILE"
  fi
fi
