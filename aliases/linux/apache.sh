#!/bin/bash

# Strubloid::linux::apache

apache-modules() {
  apachectl -t -D DUMP_MODULES
}
