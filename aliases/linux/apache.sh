#!/bin/bash

# Strubloid::linux::apache

apache-modules() {
  apachectl -t -D DUMP_MODULES
}

apache-configs()
{
  sudo apache2ctl -S
}
apache-check-last-errors()
{
  sudo grep -i -r error /var/log/apache2/
}

function getApacheUser()
{
  ps aux | egrep '(apache|httpd)'
}