#!/bin/bash

function clone_repository {
  directory=$1
  identifier=$2

  if ! [ -d "${directory}" ]; then
    git clone ${ENV_REPOSITORIES_SOURCE}/${identifier}.git $directory
  else
    echo "INFO: repository ${identifier}.git already exists."
  fi
}

function env_replace_vars() {
  directory=$1
  name=$2
  env_file="${directory}/.env"

  cp ${directory}/.env.example ${env_file}

  echo "INFO: replacing env variables for the file '${name}/.env'."

  if [ "${name}" == "docker" ]; then
    replace_var $env_file "APP_ENV" $ENV_TYPE
    replace_var $env_file "APP_DOMAIN" $ENV_DOMAIN_EXT
    replace_var $env_file "APP_CODE_PATH_HOST" "..\/code\/"
    replace_var $env_file "APP_NAME" $ENV_DOMAIN_NAME
    replace_var $env_file "COMPOSE_PROJECT_NAME" $ENV_DOMAIN_NAME
    replace_var $env_file "DATA_PATH_HOST" "~\/.$ENV_DOMAIN_NAME\/data"
    replace_var $env_file "PHP_IDE_CONFIG" serverName=$ENV_DOMAIN_NAME
    replace_var $env_file "PHP_VERSION" $ENV_PHP_VERSION
    replace_var $env_file "POSTGRES_DB" $ENV_DATABASE_NAME
    replace_var $env_file "POSTGRES_USER" $ENV_DATABASE_USER
    replace_var $env_file "POSTGRES_PASSWORD" $ENV_DATABASE_PASSWORD
    replace_var $env_file "POSTGRES_PORT" $ENV_DATABASE_PORT
    replace_var $env_file "REDIS_PORT" $ENV_REDIS_PORT
    replace_var $env_file "REDIS_PASSWORD" $ENV_REDIS_PASSWORD
    replace_var $env_file "WORKSPACE_INSTALL_YARN" false
    replace_var $env_file "TRAEFIK_HOST_HTTP_PORT" $ENV_TRAEFIK_HTTP_PORT
    replace_var $env_file "TRAEFIK_HOST_HTTPS_PORT" $ENV_TRAEFIK_HTTPS_PORT
    replace_var $env_file "PHP_FPM_INSTALL_EXIF" true
    replace_var $env_file "ACME_EMAIL" $ENV_ACME_EMAIL
    replace_var $env_file "CLOUDFLARE_EMAIL" $ENV_CLOUDFLARE_EMAIL
    replace_var $env_file "CLOUDFLARE_API_KEY" $ENV_CLOUDFLARE_API_KEY
    replace_var $env_file "CLOUDFLARE_DNS" $ENV_CLOUDFLARE_DNS
  else
    replace_var $env_file "APP_NAME" $ENV_NAME-$ENV_DOMAIN_NAME
    replace_var $env_file "APP_DEBUG" true
    replace_var $env_file "APP_ENV" $ENV_TYPE
    replace_var $env_file "APP_URL" "https:\/\/$ENV_TYPE-$ENV_DOMAIN_NAME$ENV_DOMAIN_EXT"
    replace_var $env_file "DB_CONNECTION" $ENV_DATABASE_CONNECTION
    replace_var $env_file "DB_HOST" $ENV_DATABASE_HOST
    replace_var $env_file "DB_PORT" $ENV_DATABASE_PORT
    replace_var $env_file "DB_DATABASE" $ENV_DATABASE_NAME
    replace_var $env_file "DB_USERNAME" $ENV_DATABASE_USER
    replace_var $env_file "DB_PASSWORD" $ENV_DATABASE_PASSWORD
    replace_var $env_file "MEMCACHED_HOST" $ENV_MEMCACHED_HOST
    replace_var $env_file "REDIS_HOST" $ENV_REDIS_HOST
    replace_var $env_file "REDIS_PASSWORD" $ENV_REDIS_PASSWORD
    replace_var $env_file "REDIS_PORT" $ENV_REDIS_PORT
  fi
}