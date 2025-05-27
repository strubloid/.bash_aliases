#!/bin/bash

# Strubloid::linux::laravel

function lv-create-command() {
    if [ -z "$1" ]; then
      printf "[]: Command Name "
      read commandName

      if [ -z "$commandName" ]; then
          printf "[Err]: You must inform what should be the command to run\n"
      else
          command="$commandName"
      fi
  else
    command="$1"
  fi

  vagrant ssh -c "cd /var/www/work && php artisan make:command $command"
}


function lv-scheduler-list() {
    vagrant ssh -c "cd /var/www/work && php artisan schedule:list"
}

function lv-run-scheduler() {

    printf "[Tip]: This will run all scheduled commands on app/Console/Kernel.php\n\n"
    vagrant ssh -c "cd /var/www/work && php artisan schedule:run"
}

function lv-run-command() {

    printf "[Tip]: You must get whatever will be on the \$signature of the app/console/commands \n\n"

    if [ -z "$1" ]; then
      printf "[]: Command Name "
      read commandName

      if [ -z "$commandName" ]; then
          printf "[Err]: You must inform what should be the command to run\n"
      else
          command="$commandName"
      fi
  else
    command="$1"
  fi

  vagrant ssh -c "cd /var/www/work && php artisan $command"
}


function lv-create-migration-table() {
    printf "[]: Task name: "
    read taskName
    if [ -z "$taskName" ]; then
        printf "[Err]: You must inform the task name\m"
    else

        printf "[]: Table name: "
        read tableName
        if [ -z "$tableName" ]; then
            printf "[Err]: You must inform the table name\m"
        else
            php artisan make:migration $taskName --table="$tableName" --create
        fi
    fi
}

function lv-create-model() {
    printf "[]: Model name: "
    read modelName
    if [ -z "$modelName" ]; then
        printf "[Err]: You must inform the Model name\m"
    else
        vagrant ssh -c "cd /var/www/work && php artisan make:model $modelName"
    fi

}

function lv-create-seeder() {
    printf "[]: Seeder name: "
    read seederName
    if [ -z "$seederName" ]; then
        printf "[Err]: You must inform the Model name\m"
    else
        vagrant ssh -c "cd /var/www/work && php artisan make:seeder $seederName"
    fi

}

function lv-seedrun() {

  if [ -z "$1" ]; then

    if [ ! -f "/tmp/laravel_previous_seed.dat" ] ; then
      seedToRun=0
    else
      seedToRun=`cat /tmp/laravel_previous_seed.dat`
    fi

    if [ -z "$seedToRun" ] ; then
      printf "[]: Seed Object name: "
      read seedToRun
    fi

  else
    seedToRun="$1"
  fi

  # and save it for next time
  echo "${seedToRun}" > /tmp/laravel_previous_seed.dat

  echo "this is running now as debug!"

  # running the thing
  COMMAND_TO_RUN="cd /var/www/work"
  COMMAND_TO_RUN+=" && export XDEBUG_MODE=debug && export XDEBUG_SESSION=1 "
  COMMAND_TO_RUN+=" && echo \$XDEBUG_MODE && echo \$XDEBUG_SESSION "

  echo $COMMAND_TO_RUN;

  vagrant ssh -c "$COMMAND_TO_RUN && php artisan db:seed --class=$seedToRun"

}

function lv-re-run-migration() {

  if [ -z "$1" ]; then

    printf "[]: Migration file name: "
    read migrationName

    if [ -z "$migrationName" ]; then
        printf "[Err]: You must inform the specific migration name (without the extension '.php') name\m"
    else
        path="/database/migrations/$migrationName.php"
    fi

  else
    path="/database/migrations/$1.php"
  fi

  vagrant ssh -c "cd /var/www/work && php artisan migrate:refresh --path=$path"

}

function lv-export-tables() {

    printf "[]: Enter table names (separated by  space): "
    read tablesList
    schema="strubloid"

    if [ -z "$tablesList" ]; then
        printf "[Err]: You must inform at least one table name\m"
    else
        databaseDate=$(date +'%m-%d-%Y')
        vagrant ssh -c "cd /var/www/work && mysqldump -u root -proot $schema $tablesList > ${databaseDate}-exported-database.sql"
    fi

}


function lv-export-all-tables() {
    
    schema="strubloid"
    printf "[]: Inform the DBSchema (default: $schema): "
    read dbSchema
    databaseDate=$(date +'%Y-%m-%d')

    if [ -z "$dbSchema" ]; then
        vagrant ssh -c "cd /var/www/work && mysqldump -u root -proot $schema > ${databaseDate}-exported-database.sql"
    else
        vagrant ssh -c "cd /var/www/work && mysqldump -u root -proot $dbSchema > ${databaseDate}-exported-database.sql"
    fi

}

function lv-create-migration() {
  migrationName=$1
  tableName=$2

  vagrant ssh -c "cd /var/www/work && php artisan make:migration $migrationName --table=$tableName "
}

function lv-publish-migration() {
    vagrant ssh -c 'cd /var/www/work && php artisan migrate'
}

function lv-rollback-1() {
  vagrant ssh -c 'cd /var/www/work && php artisan migrate:rollback --step=1'
}

function lv-rollback-migration() {
    vagrant ssh -c 'cd /var/www/work && php artisan migrate:rollback'
}

function lv-refresh() {
    vagrant ssh -c 'cd /var/www/work && php artisan config:cache'
}


function vagrant-xdebug-enabled() {
    vagrant ssh -c 'cd /var/www/work && php --info | grep xdebug'
}


function lv-cc() {
    vagrant ssh -c 'cd /var/www/work && php artisan route:clear && php artisan route:cache && php artisan config:clear && php artisan cache:clear'
}

function lv-new-service-provider() {
    printf "[]: Service Provider name: "
    read providerName
    if [ -z "$providerName" ]; then
        printf "[Err]: You must inform the Service Provider name\m"
    else
        vagrant ssh -c "cd /var/www/work && php artisan make:provider $providerName"
    fi

}