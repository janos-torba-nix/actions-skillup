#!/bin/env bash

function backup_database {
  if [ "$#" -ne "2" ]; then
    echo 'Usage: backup_database "[DB_TYPE]" "[DB1] ([DB2] [DB3] ...)"'
    return 1
  fi
  DB_TYPE="$1"
  DB_LIST="$2"
  if [ "$DB_TYPE" == "mysql" ]; then
    DUMP_APP_NAME="mariadb-dump"
  elif [ "$DB_TYPE" == "postgresql" ]; then
    DUMP_APP_NAME="sudo -u postgres pg_dump"
  else
    echo "Unknown database type."
    return 2
  fi
  BACKUP_DIR="/backup/$DB_TYPE/$(date +'%d-%m-%Y')/"
  mkdir -p "$BACKUP_DIR"
  (
    cd "$BACKUP_DIR" || return
    echo "In dir ${BACKUP_DIR} using '$DUMP_APP_NAME' to create backups from '$DB_TYPE' server."
    for DB in $DB_LIST; do
        echo "Creating backup for '${DB}' database."
        $DUMP_APP_NAME "${DB}" >"${DB}".sql
        tar czf "${DB}".sql.tgz "${DB}".sql
        rm -f "${DB}".sql
    done
    echo "Created backups today from '$DB_TYPE' server:"
    find . -maxdepth 1 -type f
    echo "Done."
  )
  (
    cd "/backup/$DB_TYPE/" || return
    if [ "$(find . -maxdepth 1 -type d ! -name '\.' | wc -l)" -gt "30" ]; then
        echo "Deleting old backups. Leaving the latest 30."
        for OLD_DIR in $(find . -maxdepth 1 -type d ! -name '\.' | head -n -30); do
          rm -rf "${OLD_DIR}"
        done
    fi
  )
}

yum install mariadb-server
systemctl start mariadb.service
systemctl enable mariadb.service

echo 'CREATE DATABASE postfixadmin;
CREATE USER postfixadmin@localhost IDENTIFIED BY "strong_password";
GRANT ALL PRIVILEGES ON postfixadmin.* TO postfixadmin@localhost;
FLUSH PRIVILEGES;' | mariadb --force

backup_database "mysql" "$(echo 'SHOW DATABASES;'  | mariadb | tail -n +2 | grep -vE '(performance_schema|information_schema)')"

BAD_VARIABLE="bad value"
echo $BAD_VARIABLE
