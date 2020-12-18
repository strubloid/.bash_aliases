#!/bin/bash

# Strubloid::linux::laravel

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
        vagrant ssh -c "cd /var/www/cartolytics && php artisan make:model $modelName"
    fi

}

function lv-re-run-migration() {

    #    2020_11_20_150032_grid_cells_to_grid_cell_data

    printf "[]: Migration file name: "
    read migrationName
    if [ -z "$migrationName" ]; then
        printf "[Err]: You must inform the specific migration name (without the extension '.php') name\m"
    else
        path="/database/migrations/$migrationName.php"
        vagrant ssh -c "cd /var/www/cartolytics && php artisan migrate --path=$path"
    fi

}

function lv-export-tables() {

    printf "[]: Enter table names (separated by  space): "
    read tablesList

    if [ -z "$tablesList" ]; then
        printf "[Err]: You must inform at least one table name\m"
    else
        databaseDate=$(date +'%m-%d-%Y')
        vagrant ssh -c "cd /var/www/cartolytics && mysqldump -u root -proot blocworx $tablesList > ${databaseDate}-exported-database.sql"
    fi

}


function lv-export-all-tables() {

    printf "[]: Inform the DBSchema (default: blocworx): "
    read dbSchema
    databaseDate=$(date +'%Y-%m-%d')

    if [ -z "$dbSchema" ]; then
        vagrant ssh -c "cd /var/www/cartolytics && mysqldump -u root -proot blocworx > ${databaseDate}-exported-database.sql"
    else
        vagrant ssh -c "cd /var/www/cartolytics && mysqldump -u root -proot $dbSchema > ${databaseDate}-exported-database.sql"
    fi

}

function lv-publish-migration() {
    vagrant ssh -c 'cd /var/www/cartolytics && php artisan migrate'
}

function lv-rollback-migration() {
    vagrant ssh -c 'cd /var/www/cartolytics && php artisan migrate:rollback'
}

function lv-refresh() {
    vagrant ssh -c 'cd /var/www/cartolytics && php artisan config:cache'
}


function vagrant-xdebug-enabled() {
    vagrant ssh -c 'cd /var/www/cartolytics && php --info | grep xdebug'
}


function lv-cc() {
    vagrant ssh -c 'cd /var/www/cartolytics && php artisan route:clear && php artisan config:clear && php artisan cache:clear'
}

function lv-new-service-provider() {
    printf "[]: Service Provider name: "
    read providerName
    if [ -z "$providerName" ]; then
        printf "[Err]: You must inform the Service Provider name\m"
    else
        vagrant ssh -c "cd /var/www/cartolytics && php artisan make:provider $providerName"
    fi

}


# check the utility of this command in a new project
# php artisan migrate:fresh
