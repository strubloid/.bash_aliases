alias dk-database-login="docker-compose exec database bash"
alias dk-php-login="docker-compose exec php bash"
alias dk-query='docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"'
alias dk-query-w='watch -n 1 docker-compose exec database mysql -u root -proot -e "select * from magento.catalogsearch_result"'


alias dk-processlist='docker-compose exec database mysqladmin -u root -proot -i 1 processlist'
alias dk-m2dump="docker-compose exec database sh -c 'mysqldump -h localhost -u root -proot magento --single-transaction' > dump.sql"
alias dk-start="docker stop \$(docker ps -q) && docker-sync-stack start"
alias dk-redis-flush="docker-compose exec redis sh -c 'redis-cli flushall'"
alias dk-cache-clean="docker-compose exec php sh -c 'n98-magerun cache:clean && n98-magerun cache:flush'"

# docker-compose exec database mysql -u root -proot -e "SELECT * FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"
# watch -n 1 'docker-compose exec database mysql -u root -proot magento -e "SELECT entity_id, customer_email, status, created_at,updated_at, base_total_invoiced FROM sales_flat_order ORDER BY created_at DESC LIMIT 2"'


