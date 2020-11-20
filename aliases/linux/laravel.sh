#!/bin/bash

# Strubloid::linux::laravel

function lv-create-migration-table()
{
    printf "[]: Task name: "
    read taskName
    if [ -z "$taskName" ]
    then
        printf "[Err]: You must inform the task name\m"
    else

        printf "[]: Table name: "
        read tableName
        if [ -z "$tableName" ]
        then
            printf "[Err]: You must inform the table name\m"
        else
             php artisan make:migration $taskName --table="$tableName" --create
        fi
    fi
}

function lv-publish-migration()
{
    vagrant ssh -c 'cd /var/www/cartolytics && php artisan migrate'
}

function lv-rollback-migration()
{
    vagrant ssh -c 'cd /var/www/cartolytics && php artisan migrate:rollback'
}


