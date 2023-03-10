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

  # dockerBlocworx=$(docker container ls  | grep 'blocworx-docker_web' | awk '{print $1}')
  dockerBlocworxId=$(docker container ls  | grep 'blocworx' | awk '{print $1}')

  docker exec -it "$dockerBlocworxId" /bin/bash
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