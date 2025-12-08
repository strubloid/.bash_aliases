# Strubloid::general::env

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

# This will return where is the project folder
getProjectFolder()
{
  echo "Loading project folder path... "

    # First try: use the environment variable if it exists
  if [[ -n "$BASH_ALIASES_PROJECT_FOLDER" ]]; then
    echo "$BASH_ALIASES_PROJECT_FOLDER"
  fi
  
  # Second try: read directly from ~/.bash_variables without sourcing
  if [[ -f "$HOME/.bash_variables" ]]; then
    local project_path
    project_path=$(grep "^BASH_ALIASES_PROJECT_FOLDER=" "$HOME/.bash_variables" 2>/dev/null | cut -d'=' -f2-)
    if [[ -n "$project_path" ]]; then
      BASH_ALIASES_PROJECT_FOLDER="$project_path"
    fi
  fi
  
  echo "$BASH_ALIASES_PROJECT_FOLDER"
}

# Toggle debug mode on/off
toggleDebug()
{
  if [[ "$DEBUG" == "1" ]]; then
    export DEBUG=0
    echo "Debug mode OFF"
  else
    export DEBUG=1
    echo "Debug mode ON"
  fi
  
  # Add the DEBUG setting to .bash_variables to persist it
  if grep -q "export DEBUG=" "$HOME/.bash_variables"; then
    # Update existing DEBUG line
    sed -i.bak "s/export DEBUG=./export DEBUG=$DEBUG/" "$HOME/.bash_variables"
    rm -f "$HOME/.bash_variables.bak" 2>/dev/null
  else
    # Add DEBUG line if it doesn't exist
    echo "export DEBUG=$DEBUG" >> "$HOME/.bash_variables"
  fi
}

# Show current debug status
debugStatus()
{
  if [[ "$DEBUG" == "1" ]]; then
    echo "Debug mode is currently ON"
  else
    echo "Debug mode is currently OFF"
  fi
}

loadEnvData()
{
  local envVariableName ENV_FILE envData

  OS=$(getOperationalSystem)

  # First argument: variable name (required)
  if [[ -n "$1" ]]; then
    envVariableName="$1"
  else
    echo -n "It is missing the variable name, can you please type it? "
    if [ "$OS" = "linux" ]; then
      read -p "It is missing the variable name, can you please type it? " envVariableName
    else
      # For other OS types, prompt for input
      echo -n "It is missing the variable name, can you please type it? "
      read envVariableName
    fi
  fi

  # Second argument: env file (optional, default to .env)
  if [[ -n "$2" ]]; then
    ENV_FILE="$BASH_ALIASES_PROJECT_FOLDER/$2"
  else
    ENV_FILE="$BASH_ALIASES_PROJECT_FOLDER/.env"
  fi

  # Extract variable value
  if [[ -f "$ENV_FILE" ]]; then
    envData=$(grep -v "^#" "$ENV_FILE" | grep -E "^${envVariableName}=" | head -n1 | cut -d'=' -f2-)
  fi

  echo "$envData"
}