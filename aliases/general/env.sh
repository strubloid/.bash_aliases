# Strubloid::general::env

# This will return where is the project folder
getProjectFolder()
{
  echo $BASH_ALIASES_PROJECT_FOLDER
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

  # First argument: variable name (required)
  if [[ -n "$1" ]]; then
    envVariableName="$1"
  else
    read -p "It is missing the variable name, can you please type it? " envVariableName
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