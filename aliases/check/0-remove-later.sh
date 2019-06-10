# How to see what is going on into a database process
# docker exec -i williamsco_database_1  mysqladmin -u root -proot -i 1 processlist
# how to get into the bash of the php image
# docker-compose exec php bash
# how to run cache clean from outside
# docker-compose exec php n98-magerun cache:clean
# docker setup incremental
# docker-compose exec php n98-magerun sys:setup:incremental

# n98-magerun admin:user:create rafael rafael@monsoonconsulting.com rafa1234 rafael mendes

# create alias later
# pv {filename} | gunzip | mysql -uroot -proot
# pv {filename} | mysql -uroot -proot

# magento aliases

# mage config sync
# alias mageconfigsync='php /home/strubloid/webroot/mageconfigsync/bin/mageconfigsync'

# magento helpers
# alias magerun-setup-incremental='magerun sys:setup:incremental'
# alias magerun-setup-run='magerun sys:setup:run'
# alias magerun-template-hints='magerun dev:template-hints'
# alias magerun-create-user='magerun admin:user:create rafael rafael@test.com rafa1234 rafael mendes'
# alias magerun-apply-price-rules='magerun sys:cron:run catalogrule_apply_all'

# magerun cron commands
# alias magerun-cron-list="magerun sys:cron:list"
# alias magerun-cron-run="magerun sys:cron:run"

# alias to send email each 10 seconds
# alias magento-send-email='watch -n 10 magerun sys:cron:run core_email_queue_send_all'

# issue with m1-invalid form key
# DELETE FROM core_config_data WHERE path='web/cookie/cookie_domain';
# DELETE FROM core_config_data WHERE path='web/cookie/cookie_path';

# show open ports
# alias ports='netstat -tulanp'

# Get server cpu info #
# alias cpuinfo='lscpu'

# how turn on the trackpad
# alias rafa-touchpad-off="synclient TouchpadOff=1"
# alias rafa-touchpad-on="synclient TouchpadOff=0"

# how to check your devices
# alias rafa-devices="inxi -Fxz"
# alias rafa-devices-network="inxi -Nn"

# checkin netwook drivers
# alias rafa-network="lspci -nnk | grep -iA2 net"
# alias rafa-network-service-status="systemctl status networking.service"
# alias rafa-network-status="lshw -c net"

# devices
# alias rafa-devices="rfkill list all"

# how to check kernel version
# alias rafa-kernel="uname -r"

# how to see who is loading in the boot
# alias rafa-boot-time="systemd-analyze blame"

# create alias later
# pv {filename} | gunzip | mysql -uroot -proot
# pv {filename} | mysql -uroot -proot


## CHECK THOSE COMMANDS #

# how to check your devices
# alias rafa-devices="inxi -Fxz"
# alias rafa-devices-network="inxi -Nn"

# checkin network drivers
# alias rafa-network="lspci -nnk | grep -iA2 net"
# alias rafa-network-service-status="systemctl status networking.service"
# alias rafa-network-status="lshw -c net"

# devices
# alias rafa-devices="rfkill list all"

# command to load the phpstorm without so much priority
# nice -n 15 /snap/bin/phpstorm

# system functions
# alias rafa-swap-clean="sudo swapoff -a && swapon -a"
# alias rafa-ran-clean="sudo rafacacheclean.sh"
