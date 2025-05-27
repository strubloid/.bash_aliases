#!/bin/bash

# Strubloid::linux::nginx

function getNginxUser()
{
  ps aux | egrep '(apache|httpd)'
}