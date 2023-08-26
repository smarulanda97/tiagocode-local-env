#!/bin/bash

function purge_database() {
  if [ "$ENV_CLEAN_DB_ON_INSTALL" == "TRUE" ]; then
    echo "INFO: removing previous database data '$HOME/.$ENV_DOMAIN_NAME/data/[postgres|mariadb|mysql]'."
    sudo rm -rf "$HOME/.$ENV_DOMAIN_NAME/postgres"
    sudo rm -rf "$HOME/.$ENV_DOMAIN_NAME/mariadb"
    sudo rm -rf "$HOME/.$ENV_DOMAIN_NAME/mysql"
  fi
}