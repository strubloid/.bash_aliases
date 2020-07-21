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

# this will start the docker sync and the container
alias dk-start="docker-sync start && docker-compose up -d"
