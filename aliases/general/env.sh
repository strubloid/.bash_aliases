# Strubloid::general::env
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