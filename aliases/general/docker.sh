## docker main commands
alias dk-start="docker stop \$(docker ps -q) && docker-sync-stack start"

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

# docker-compose exec database mysql -u root -proot -e "SELECT * FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"
# watch -n 1 'docker-compose exec database mysql -u root -proot magento -e "SELECT entity_id, customer_email, status, created_at,updated_at, base_total_invoiced FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"'
