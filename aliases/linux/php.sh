#!/bin/bash

# Strubloid::linux::php

# https://www.cyberciti.biz/faq/installing-php-7-on-debian-linux-8-jessie-wheezy-using-apt-get/
list-installed-php-packages()
{
  dpkg --list | grep php | awk '/^ii/{ print $2}'
}

