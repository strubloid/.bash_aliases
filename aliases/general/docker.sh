## docker main commands
alias dk-stop-start="docker stop \$(docker ps -q) && docker-sync-stack start"

## cache related
alias dk-redis-flush="docker-compose exec redis sh -c 'redis-cli flushall'"


## php related
alias dk-php-restart="docker-compose restart php"
alias dk-php-login="docker-compose exec php bash"

## database related
alias dk-database-login="docker-compose exec database bash"
alias dk-database-query='docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"'
alias dk-database-query-watch='watch -n 1 docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"'
alias dk-database-dump="docker-compose exec database sh -c 'mysqldump -h localhost -u root -proot magento --single-transaction' > dump.sql"
alias dk-database-processlist='docker-compose exec database mysqladmin -u root -proot -i 1 processlist'

alias dk-create-admin-user="docker-compose exec php sh -c \"php bin/magento admin:user:create --admin-user='rafael' --admin-password='rafa1234' --admin-email='rafael@monsoonconsulting.com' --admin-firstname='Rafael' --admin-lastname='Mendes' \""

# docker-compose exec database mysql -u root -proot -e "SELECT * FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"
# watch -n 1 'docker-compose exec database mysql -u root -proot magento -e "SELECT entity_id, customer_email, status, created_at,updated_at, base_total_invoiced FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"'

alias dk-update="sudo chmod 777 ~/.docker/ -Rf && sudo chown strubloid:strubloid  ~/.docker/ -Rf"

# this will start the docker sync and the container
alias dk-start="docker-sync start && docker-compose up -d"


# docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"
# docker-compose exec database mysql -u root -proot -e "cat .docker/select.sql" > 2019-07-03-select.txt

