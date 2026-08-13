#!/bin/bash

# Strubloid::general::docker

## docker main commands
alias dk-stop-start="docker stop \$(docker ps -q) && docker-sync-stack start"

## cache related
alias dk-redis-flush="docker-compose exec redis sh -c 'redis-cli flushall'"

## php related
alias dk-php-restart="docker-compose restart php"
alias dk-php-login="docker-compose exec php bash"

# docker-compose exec database mysql -u root -proot -e "SELECT * FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"
# watch -n 1 'docker-compose exec database mysql -u root -proot magento -e "SELECT entity_id, customer_email, status, created_at,updated_at, base_total_invoiced FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"'
alias dk-update="sudo chmod 777 ~/.docker/ -Rf && sudo chown strubloid:strubloid  ~/.docker/ -Rf"

alias ds='docker service'
alias dsls='ds ls'
alias dsi='ds inspect'
alias dsp='ds ps'
alias dsrm='ds rm -f'
alias dsrall='ds rm -f \$(dsls -q)'
alias dslg='ds logs -f'
alias dslgt='ds logs --tail=0 -f'
alias dsf='dsls --filter'
alias clsdv="docker volume rm -f \$(docker volume ls -q)"
alias clsds="docker service rm \$(docker service ls -q)"


# this will start the docker sync and the container
alias dk-start="docker-sync start && docker-compose up -d"

## entering the docker
function docker-enter(){

  # dockerWork=$(docker container ls  | grep 'work-docker_web' | awk '{print $1}')
  dockerWorkId=$(docker container ls  | grep 'work' | awk '{print $1}')

  docker exec -it "$dockerWorkId" /bin/bash
}

# This will be checking all docker commands that list things
function docker-status(){
  docker ps
  docker image ls
  docker image ls -a
  docker container ls
}

## this will make sure to delete all things
function docker-reset(){

  ##  removing all the images
  docker rm $(docker ps -a -q) -f

  docker image prune -a -f

  docker container prune -f

  docker system prune -f
}

## removes only resources tied to the current project's docker-compose
function docker-reset-local(){

  if [ ! -f "docker-compose.yml" ] && [ ! -f "docker-compose.yaml" ]; then
    echo "No docker-compose.yml found in $(pwd)"
    return 1
  fi

  ## stops containers, removes networks, volumes, and all images used by this project
  docker-compose down --rmi all --volumes --remove-orphans

  ## clean up any dangling images left behind
  docker image prune -f
}

## reset only the project
function docker-clean(){
  local project_dir="$(pwd)"

  if [ ! -f "$project_dir/docker-compose.yml" ] && [ ! -f "$project_dir/docker-compose.yaml" ]; then
    echo "No docker-compose.yml or docker-compose.yaml found in $project_dir"
    return 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose v2 is required: sudo apt install docker-compose-v2"
    return 1
  fi

  echo "1) Rebuild and preserve database/exports"
  echo "2) Delete this project's containers, images, database, and exports"
  echo "q) Cancel"
  read -r -p "Choose [1/2/q]: " choice

  case "$choice" in
    1)
      docker compose down --remove-orphans &&
        docker compose build --no-cache &&
        docker compose up -d
      ;;
    2)
      read -r -p "Type DELETE to remove only this project's data: " confirmation
      [ "$confirmation" = "DELETE" ] || { echo "Cancelled."; return 0; }
      docker compose down --volumes --remove-orphans --rmi local &&
        docker compose build --no-cache &&
        docker compose up -d
      ;;
    q|Q|"")
      echo "Cancelled."
      return 0
      ;;
    *)
      echo "Invalid option."
      return 1
      ;;
  esac

  docker compose ps
}

## this will show the total space that docker is consuming
function docker-total-used-space(){
  docker system df
}

# Enable debug for docker
function docker-verbose() {
  export BUILDKIT_PROGRESS=plain
}

# Disable debug for docker
function docker-verbose-off() {
  export BUILDKIT_PROGRESS=
}


function how-to-create-user-docker-compose(){
#  Create the user
#  ARG USER_ID=1005
#  ARG GROUP_ID=1006
#  ARG USERNAME=app
#
#  ## creating the user
#  RUN groupadd --gid $GROUP_ID $USERNAME
#  RUN useradd --uid $USER_ID --gid $GROUP_ID -m $USERNAME
#
#  USER app
  echo "check the code"
}

## resets the current project's docker-compose stack (containers, networks, volumes) and rebuilds
function docker-clean-current-project() {
  local project_dir="$(pwd)"

  ## First check if exist a docker project to clean
  if [ ! -f "$project_dir/docker-compose.yml" ] && [ ! -f "$project_dir/docker-compose.yaml" ]; then
    echo "No docker-compose.yml or docker-compose.yaml found in $project_dir"
    return 1
  fi

  ## Second check if docker compose v2 is installed
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose v2 is required."
    return 1
  fi

  ## Third, doing all the steps to clean the project and rebuild it
  echo "Stopping stack and removing volumes in $project_dir..."
  docker compose down --remove-orphans -v

  echo "Rebuilding and starting stack..."
  docker compose up --build
}

## wipes node_modules contents across a pnpm workspace and reinstalls in each parent
function docker-clean-pnpm-project() {
  local project_dir="$(pwd)"

  ## check we are inside a pnpm workspace
  if [ ! -f "$project_dir/pnpm-workspace.yaml" ]; then
    echo "No pnpm-workspace.yaml found in $project_dir"
    return 1
  fi

  if ! command -v pnpm >/dev/null 2>&1; then
    echo "pnpm is not installed or not in PATH"
    return 1
  fi

  ## collect every node_modules directory under the project
  local -a node_modules_dirs=()
  while IFS= read -r dir; do
    [ -n "$dir" ] && node_modules_dirs+=("$dir")
  done < <(find "$project_dir" -type d -name node_modules 2>/dev/null)

  if [ ${#node_modules_dirs[@]} -eq 0 ]; then
    echo "No node_modules found in $project_dir"
    return 0
  fi

  echo "Found ${#node_modules_dirs[@]} node_modules directory(ies):"
  printf '  - %s\n' "${node_modules_dirs[@]}"
  echo ""

  read -r -p "Wipe contents and run 'pnpm install' in each parent? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    return 0
  fi

  ## wipe contents (keep the directory so pnpm install has a target)
  # for dir in "${node_modules_dirs[@]}"; do
  #   echo "Wiping $dir/ ..."
  #   find "$dir" -mindepth 1 -delete 2>/dev/null
  # done

  # ## dedupe parents and run pnpm install in each
  # declare -A seen=()
  # for dir in "${node_modules_dirs[@]}"; do
  #   local parent
  #   parent="$(dirname "$dir")"
  #   if [ -z "${seen[$parent]+set}" ]; then
  #     seen["$parent"]=1
  #     echo "Running pnpm install in $parent"
  #     (cd "$parent" && pnpm install)
  #   fi
  # done

  echo "Done."
}