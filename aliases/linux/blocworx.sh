#!/bin/bash

# Strubloid::linux::blocworx


#function createRouteBlocworx()
#{
#
#  # ng g m components/scanStation/data --module app-routing
#
#}

#function thingsThatIranOnTemplateServer2()
#{
#  sudo apt install php7.4-gd
#  #  NOTICE: Not enabling PHP 7.4 FPM by default.
#  #  NOTICE: To enable PHP 7.4 FPM in Apache2 do:
#  #  NOTICE: a2enmod proxy_fcgi setenvif
#  #  NOTICE: a2enconf php7.4-fpm
#  #  NOTICE: You are seeing this message because you have apache2 package installed.
#  sudo apt install php7.4-zip
#  composer update
#}

function thingsThatIranOnStage()
{

  ## changed to root
  sudo su -

  sudo apt-get install software-properties-common python-software-properties && sudo apt-get update

  sudo apt install php7.4-common php7.4-mysql php7.4-xml php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl -y

  ##  tried https://www.digitalocean.com/community/questions/how-to-upgrade-php-7-0-33-to-7-4-7-on-ubuntu-16-04-nginx

  ## tried
  sudo chown -R $USER:www-data vendor/ && sudo apt install php7.4-gd php7.4-zip && composer update

  sudo add-apt-repository ppa:ondrej/php && sudo apt-get update

}

function sourcesListToUpdateLines()
{

  # edit sources.list
#  deb http://us.archive.ubuntu.com/ubuntu/ focal main restricted
#  deb http://us.archive.ubuntu.com/ubuntu/ focal-updates main restricted
#  deb http://us.archive.ubuntu.com/ubuntu/ focal universe
#  deb http://us.archive.ubuntu.com/ubuntu/ focal-updates universe
#  deb http://us.archive.ubuntu.com/ubuntu/ focal multiverse
#  deb http://us.archive.ubuntu.com/ubuntu/ focal-updates multiverse
#  deb http://us.archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
#  deb http://security.ubuntu.com/ubuntu focal-security main restricted
#  deb http://security.ubuntu.com/ubuntu focal-security universe
#  deb http://security.ubuntu.com/ubuntu focal-security multiverse

  sudo apt install -f -y

  ##Restarting services possibly affected by the upgrade:
  ##cron: restarting...done.
  ##snmpd: restarting...done.
  ##postfix: restarting...done.
  ##mysql: restarting...FAILED! (1)
  ##atd: restarting...done.
  ##apache2: restarting...done.

  sudo apt install php7.4-gd php7.4-zip

  ## fix mysql issue
  sudo mkdir /var/run/mysqld
  sudo touch /var/run/mysqld/mysqld.sock
  sudo chown -R mysql /var/run/mysqld
  sudo /etc/init.d/mysql restart

  # reference: https://askubuntu.com/questions/1089310/how-to-resolve-service-start-limit-hit
  sudo systemctl reset-failed mysql.service

  sudo vim /lib/systemd/system/mysql.service
  ## remove line Restart=on-failure
  sudo systemctl daemon-reload

  ## https://support.plesk.com/hc/en-us/articles/213939865

  ## root backup mysql
  # /root/etc-mysql-backup/mysql
  # conf.d  debian.cnf  debian-start  my.cnf  my.cnf.bak  my.cnf.fallback  mysql.cnf  mysql.conf.d

  ## https://askubuntu.com/questions/760724/16-04-upgrade-broke-mysql-server
  sudo mv /etc/mysql/debian.cnf /etc/mysql/debian.cnf.bak
  sudo apt purge mysql-server mysql-server-5.7 mysql-server-core-5.7
  sudo apt purge mysql-server mysql-server-* mysql-server-core-*
  sudo apt install mysql-server

  sudo systemctl enable mysql.service
  sudo apt install -f

  mkdir /var/run/mysqld
  chown mysql.mysql /var/run/mysqld
  chmod 700 /var/run/mysqld

  cd /root/downloads
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.17-1_all.deb
  # pick the option ubuntu focal
  # MySQL Server & Cluster (Currently selected: mysql-5.7)
  # piuck mysql-8.0
  sudo dpkg -i mysql-apt-config_0.8.17-1_all.deb && sudo apt update && sudo apt install mysql-server
  # Use Strong Password Encryption (RECOMMENDED)                                                                                            │

  ## this made it work again (restart systemd on the fly)
  systemctl daemon-reexec

  sudo apt-get purge php5*
  # Perform upgrade on database for phpmyadmin with dbconfig-common?                                                                                                       │
  # no
  sudo apt-get install php-mbstring php-curl php-xml -y

  # changed on composer.json
  # "pusher/pusher-php-server": "^7.0",

  composer require pusher/pusher-php-server
  composer require milon/barcode
  composer require tymon/jwt-auth --ignore-platform-reqs

  composer clearcache
  composer selfupdate
  composer dumpautoload
  composer update

}

function changingTheDatabase()
{
  # reference: https://dev.to/kenfai/laravel-artisan-cache-commands-explained-41e1#:~:text=To%20clear%20your%20application%20cache,()%3B%20Facade%20method%20via%20code.
  # first you must change on the .env file in your local folder


  # cleaning the configuration cache
  php artisan config:clear

  # second you must clean the php cache
  php artisan cache:clear

  # this will clean all caches
  php artisan optimize:clear

  # only if necessary
  # clean if a package isn' t showing up
  # composer dump-autoload

  # npm clean
  # npm cache clean --force

  # extra: cleaning the routes cache
  # php artisan route:clear

  # extra: cleaning the views cache
  # php artisan view:clear

  # extra: cleaning the events cache
  # php artisan event:clear

  # extra: cleaning the applciation cache
  # php artisan cache:clear

}

function findingDatabaseLocalhost ()
{
  # 1 check file: app/Http/Middleware/IsUser.php

  # 2 - handle function you must add
  ```
    $databases = \DB::select('show databases');
    $currentDatabase = \DB::select('select database()');
  ```

  # 3 adding user permission to specific pages
  # select of the place that you will be adding data:  select * from stage.cartolytics_customer_shared_station

  # 4 cant find cartolyticsCustomerID user?
  # app/Http/Middleware/SwitchDatabase.php
  # check query: select * from stage.cartolytics_customer


}

function ssh-live-blocworx()
{
  ssh rafael@185.57.119.163 -p 5422
}

function ssh-stage-blocworx()
{
#  80.93.26.128
  ssh rafael@80.93.26.128 -p 22
}

function aws-blocworx()
{
    if [ -z "$1" ]
    then
#        ssh -i /home/strubloid/.ssh/BlocworxTemplateServer.pem ubuntu@172-31-18-120
#        ssh -i /home/strubloid/.ssh/BlocworxTemplateServer.pem ubuntu@52.30.205.57
        ssh -i /home/strubloid/.ssh/BlocworxTemplateServer.pem ubuntu@54.78.239.127
    else
      ssh -i /home/strubloid/.ssh/BlocworxTemplateServer.pem ubuntu@$1
    fi
}


function ssh-aws-blocworx()
{
   ssh -i /home/strubloid/.ssh/BlocworxTemplateServer.pem ubuntu@52.30.205.57
}

function ssh-live-copy-blocworx()
{
  ssh root@185.57.119.34 -p 5422
  ssh strubloid@185.57.119.34 -p 5422
}

function vagrantReload()
{
    vagrant reload
}

function blocworx-setup-step1() {

    # Download of the virutal box
    sudo apt install virtualbox

    # Download of the debian vagrant
    wget https://releases.hashicorp.com/vagrant/2.2.13/vagrant_2.2.13_x86_64.deb

    # Giving execution permission and run
    chmod +x vagrant_2.2.13_x86_64.deb && ./vagrant_2.2.13_x86_64.deb

    # Download from https://box.scotch.io/
    printf "PLease say it what is the name of the app: "
    read appName

    ## Cloning from the scotch.io
    git clone https://github.com/scotch-io/scotch-box $appName

    # Starting the server
    cd $appName && vagrant up &

}

function blocworx-setup-cartolytics() {
    # step 1: add your key to the bitbucket
    # On terminal: check tge ssh key on the directory ~/.ssh/ (must be a file.pub)
    # On bitbucket: click profile name -> Personal Settings -> Ssh Keys
    # Click to add the key and paste the content there

    # step 2: Repo clone
    # git clone git@bitbucket.org:adriandecleir/cartolytics-iqutech.git cartolytics

    # Step 3: Copy the .env file to php source folder

    # Step 4: Copy the /application/js/config-sample.js  to become /application/js/config.js

    # Step 4: Copy the /application/.htaccess-sample  to become /application/.htaccess

    # Step 5: Start the scotch.io environment

    # Copy the configuration files

    # restart vagrant server with: vagrant reload

    # entering the vagrant server with: vagrant ssh
    # now you must access the server folder: vagrant@scotchbox:~$ cd /var/www
    # check your project folder, in this case: vagrant@scotchbox:/var/www$ cd cartolytics/
    # run the composer update inside of the server

    # move the empty_blocworx clean file to vagrant root folder


#    127.0.0.1       scotchbox       scotchbox
#    127.0.0.1       localhost
#    127.0.1.1       vagrant.vm      vagrant
#    ::1     localhost ip6-localhost ip6-loopback
#    ff02::1 ip6-allnodes
#    ff02::2 ip6-allrouters
#
#    127.0.0.1       dev2.blocworx.local
#    192.168.33.10   phpmyadmin.local
#    192.168.33.10   dev.blocworx.local
#    192.168.33.10   demo1.blocworx.local
#    192.168.33.10   angularjs.local


    # Creating the database on local environment
    # vagrant@scotchbox:/var/www$ echo "create database cartolytics" | mysql -u root -proot

    # checking if was created
    # ref: https://stackoverflow.com/questions/2428416/how-to-create-a-database-from-shell-command
    # mysql -u root -e "create database testdb"; another way to run mysql from outside
    # vagrant@scotchbox:/var/www$ echo "show databases" | mysql -u root -proot | grep cartolytics

    # Import the server command
    # vagrant@scotchbox:/var/www$ mysql -u root --p cartolytics < empty_blocworx.sql
    #    vagrant@scotchbox:/var/www$ mysql -u root -p blocworx < empty_blocworx.sql

    # Check your .env file to see if database name is correct: DB_DATABASE=cartolytics
    # File to check: /cartolytics/.env

    # setting up virtual host: /etc/apache2/sites-available/
    # vagrant ssh

    # navigate to the sites enabled folder
    # cd /etc/apache2/sites-available/

    # create files: phpmyadmin.conf and cartolytics.conf
    # activate files doing a2ensite
#     sudo a2ensite phpmyadmin.conf
#     sudo a2ensite cartolytics.conf

    # Restart the server
    # sudo service apache2 restart

    ## changing the hosts to contain the new configurations on localhost
    # sudo vim /etc/hosts

    # Installation of the phpmyadmin and the cartolytics
    #    HOSTFILE="/etc/hosts"
    #    cartolyticsServer="192.168.33.10 demo.cartolytics.local"
    #    EXISTLINE=$(grep -F "$cartolyticsServer" $HOSTFILE)
    #    if [ -z "$EXISTLINE" ]; then
    #        NEWHOST=$(awk -v pattern=".*127.0.1.1.*" -v line1="$cartolyticsServer" "\$0 ~ pattern {print; print line1; next; } 1" "$HOSTFILE")
    #        sudo -- sh -c -e "echo '$NEWHOST' > $HOSTFILE";
    #    else
    #        printf "The server $cartolyticsServer its already installed\n"
    #    fi
    #
    #    phpmyadminServer="192.168.33.10 phpmyadmin.local"
    #    EXISTLINE=$(grep -F "$phpmyadminServer" $HOSTFILE)
    #    if [ -z "$EXISTLINE" ]; then
    #        PHPADMIN=$(awk -v pattern=".*127.0.1.1.*" -v line1="$phpmyadminServer" "\$0 ~ pattern {print; print line1;
    #        next; } 1" "$HOSTFILE")
    #        sudo -- sh -c -e "echo '$PHPADMIN' > $HOSTFILE";
    #    else
    #        printf "The server $phpmyadminServer its already installed\n"
    #    fi

    ## Adding the phpmyadmin inside of the box
    #ref : https://github.com/scotch-io/scotch-box/issues/129
    # vagrant@scotchbox:/etc/apache2/sites-available$ sudo apt-get -y update && sudo apt-get -y install phpmyadmin

    # adding inside of the vargrant project the new php version
    # sudo add-apt-repository ppa:ondrej/php
    # sudo apt-get update

    # deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
    # deb-src http://ppa.launchpad.net/ondrej/php/ubuntu bionic main
    ## sudo apt-get install php7.3

    # cache clean
    # php artisan config:cache

    ## you need to disable the previous one
    sudo a2dismod php7.0 && sudo a2enmod php7.3 && sudo service apache2 restart

    ## extra installations
    # sudo apt-get install php7.3-mysql

    # I had to do that today, check it why on the new installation for php my admin
    ## sudo apt-get install php


## frontend
#/home/strubloid/webroot/blocworx/box/cartolytics/application/index.html

## main routes
#/home/strubloid/webroot/blocworx/box/cartolytics/routes/web.php

## Backend
# /home/strubloid/webroot/blocworx/box/cartolytics/app/Http/Controllers/Auth/LoginController.php

## URLS for time sheets
## /home/strubloid/webroot/blocworx/box/cartolytics/application/js/app.js
#template url, check all files and see where it goes
#
#edit job details
#url loades in the page
#
### views paternt templale url -: use admin... ->
#1 - how the url loads the html template for a form using app.js
#2 - review the associate template for that form
#scan-station.html
#/home/strubloid/webroot/blocworx/box/cartolytics/application/views/front-end/scan-station-fields.html


}
