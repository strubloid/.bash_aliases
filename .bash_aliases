## create alias later
# pv {filename} | gunzip | mysql -uroot -proot
# pv {filename} | mysql -uroot -proot

# mysql related
alias create-database="echo 'CREATE DATABASE [db_name] CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'" 

# linux commands
alias swap-cache-off="sudo swapoff -a";
alias swap-cache-on="sudo swapon -a";
alias swap-cache-restart="swapoff -a && swapon -a";
alias restart-mate="gsettings reset-recursively org.mate.panel";

# 1. Freeing Up the Page Cache
alias linux-memory-clean-1="sudo echo 1 > /proc/sys/vm/drop_caches"

# 2. Freeing Up the Dentries and Inodes
alias linux-memory-clean-2="sudo echo 2 > /proc/sys/vm/drop_caches"

# 3. Freeing Up the Page Cache, Dentries and Inodes
alias linux-memory-clean-3="sudo echo 3 > /proc/sys/vm/drop_caches"

# you need to add the path to the file to test the google feed
alias google-feed-test="xmllint --schema http://www.gstatic.com/productsearch/static/reviews/5.0/merchant_reviews.xsd --noout"

#mage config sync
alias mageconfigsync='php /home/strubloid/webroot/mageconfigsync/bin/mageconfigsync'

# mercurial tips
alias remove-redis-fpc='rm app/etc/fpc.xml app/etc/redis.xml '
alias revert-redis-fpc='hg revert app/etc/fpc.xml app/etc/redis.xml '

## php helpers
## alias php="time php";

# php cli version changes
alias change-php-version='sudo update-alternatives --list php'
alias change-php56='sudo update-alternatives --set php /usr/bin/php5.6'
alias change-php70='sudo update-alternatives --set php /usr/bin/php7.0'
alias change-php71='sudo update-alternatives --set php /usr/bin/php7.1'

## magento helpers
alias magerun-setup-incremental='magerun sys:setup:incremental'
alias magerun-setup-run='magerun sys:setup:run'
alias magerun-template-hints='magerun dev:template-hints'
alias magerun-create-user='magerun admin:user:create rafael rafael@studioforty9.com rafa1234 rafael mendes'
alias magerun-apply-price-rules='magerun sys:cron:run catalogrule_apply_all'

## magerun cron commands
alias magerun-cron-list="magerun sys:cron:list"
alias magerun-cron-run="magerun sys:cron:run"

## alias for restarting the apache
alias raa='sudo systemctl restart apache2.service php5.6-fpm.service php7.0-fpm.service php7.1-fpm.service && sudo service hhvm restart'
alias saa='sudo systemctl stop apache2.service php5.6-fpm.service php7.0-fpm.service php7.1-fpm.service'

# configuring gulp
alias configuregulp="bower install && npm install"

## clean redis
alias rc="redis-cli flushall"

# git aliases
alias git-revert="git clean -d -f -f"
#alias git-hook="ln -s /var/www/tools/docs/hooks .git/hooks"
#alias pre-commit-all="/var/www/tools/docs/hooks/pre-commit all"
#alias pre-commit="/var/www/tools/docs/hooks/pre-commit"

# Mercurial aliases
alias hg-last-files="hg status --change tip"
alias hgupdate="hg checkout develop && hg pull && hg update"

# mercurial clean 
alias hg-revert="hg clean"

# mysql process list
alias mylist="mysqladmin -u root -proot -i 1 processlist"

## Colorize the ls output ##
alias ls='ls -lap --group-directories-first --color=auto'
 
## Use a long listing format ##
alias ll='ls -la --group-directories-first --color=auto' 
 
## Show hidden files ##
alias l.='ls -lapd .* --group-directories-first --color=auto'

# xdebug turning on in command line
alias terminal-xdebug="export XDEBUG_CONFIG=1"

## Quick way to get out of current directory ##
alias ..='cd ..' 
alias ...='cd ../../../' 
alias ....='cd ../../../../' 
alias .....='cd ../../../../'

# Colorize the grep command output for ease of use (good for log files)##
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# start the calculator with math support
alias bc='bc -l'

# better mkdir
alias mkdir='mkdir -pv'

# install  colordiff package :)
alias diff='colordiff'

# handy short cuts #
alias h='history'
alias j='jobs -l'

# handy commands
# alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# vim alias
alias vi=vim 
alias svi='sudo vi' 
alias vis='vim "+set si"' 
#alias edit='vim'

# Stop after sending count ECHO_REQUEST packets #
alias ping='ping -c 5'
# Do not wait interval 1 second, go fast #
alias fastping='ping -c 100 -s.2'

# show open ports
alias ports='netstat -tulanp'

# get web server headers #
# alias header='curl -I'

# find out if remote server supports gzip / mod_deflate or not #
# alias headerc='curl -I --compress'

# confirmation #
alias mv='mv -i' 
alias cp='cp -i' 
alias ln='ln -i'

# distro specific  - Debian / Ubuntu and friends #
# install with apt-get
alias apt-get="sudo apt-get" 
alias aptitude="sudo aptitude -y" 
alias aptitudey="sudo aptitude" 
alias updatey="sudo apt-get --yes" 
 
# update on one command 
alias update='sudo apt-get update && sudo apt-get upgrade'

# become root #
alias root='sudo -i'
alias su='sudo -i'

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

## Get server cpu info ##
alias cpuinfo='lscpu'
## get GPU ram on desktop / laptop## 
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'
## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
## pass options to free ## 
alias meminfo='free -m -l -t'

## this one saved by butt so many times ##
alias wget='wget -c'

## set some other defaults ##
alias df='df -H'
alias du='du -ch'
 
# top is atop, just like vi is vim
alias top='atop' 

#mercurial 
alias hst="hg status"
alias hs="hg status"
alias hadd="hg addremove"
alias ha="hg addremove"
alias hdiff="hg diff"
alias hd="hg diff"
alias hl="hg log | less"
alias hll="hg log --graph | less"
alias hlf="hs --change"

alias phpstorm="/home/strubloid/sf9/programs/PhpStorm-171.4249.3/bin/phpstorm.sh %f"


#system comands
# how turn on the trackpad
alias rafa-touchpad-off="synclient TouchpadOff=1"
alias rafa-touchpad-on="synclient TouchpadOff=0"

# how to check your devices
alias rafa-devices="inxi -Fxz"
alias rafa-devices-network="inxi -Nn"

# checkin netwook drivers
alias rafa-network="lspci -nnk | grep -iA2 net"
alias rafa-network-service-status="systemctl status networking.service"
alias rafa-network-status="lshw -c net"

# devices
alias rafa-devices="rfkill list all"

#how to check kernel version
alias rafa-kernel="uname -r"

# how to see who is loading in the boot
alias rafa-boot-time="systemd-analyze blame"


# system functions
# alias rafa-swap-clean="sudo swapoff -a && swapon -a"
# alias rafa-ran-clean="sudo rafacacheclean.sh"


#sf9
alias tk-clean-stage-cache='curl --insecure -I0 -X PURGE -H "Host: stage.tonykealys.com" https://stage.tonykealys.com/js/klarna/checkout.js'
alias magento-send-email='watch -n 10 magerun sys:cron:run core_email_queue_send_all'
