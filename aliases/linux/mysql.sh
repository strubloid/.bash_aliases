#!/bin/bash

# Strubloid::general::mysql
databaseDate=$(date +"%Y-%m-%d")

function dump-today() {

  schema="strubloid"
  mysqldump -u root -proot $schema $tablesList >${databaseDate}-exported-database.sql

}

function mysql-show-table-collation() {
  # SHOW TABLE STATUS where name like 'TABLE_NAME'
  echo "SHOW TABLE STATUS where name like 'TABLE_NAME'"
}
function mysql-alter-table-collation() {

  # ALTER TABLE <table> CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
  echo "ALTER TABLE <table> CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
}
