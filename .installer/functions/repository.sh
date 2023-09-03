#!/bin/bash

function clone_repository {
  repo_dir=$1
  repos_id=$2

  if ! [ -d "${repo_dir}" ]; then
    git clone ${ENV_REPOSITORIES_SOURCE}${repos_id}.git $repo_dir
  else
    echo "INFO: repository ${repos_id}.git already exists."
  fi
}

function env_replace_vars() {
  project_dir=$1
  project_name=$2
  env_file="${project_dir}/.env"

  cp ${project_dir}/.env.example ${env_file}

  echo "INFO: replacing env variables for the file '${project_name}/.env'."

  if [ "${project_name}" == "docker" ]; then
    replace_var $env_file "APP_ENV_TYPE" $ENV_TYPE
    replace_var $env_file "APP_DOMAIN_NAME" $ENV_DOMAIN_NAME
    replace_var $env_file "BACKEND_APP_CODE_PATH_HOST" "$ENV_BACKEND_APP_CODE_PATH_HOST"
    replace_var $env_file "BACKEND_APP_CODE_PATH_CONTAINER" "$ENV_BACKEND_APP_CODE_PATH_CONTAINER"
    replace_var $env_file "FRONTEND_APP_CODE_PATH_HOST" "$ENV_FRONTEND_APP_CODE_PATH_HOST"
    replace_var $env_file "FRONTEND_APP_CODE_PATH_CONTAINER" "$ENV_FRONTEND_APP_CODE_PATH_CONTAINER"
    replace_var $env_file "COMPOSE_PROJECT_NAME" $ENV_NAME
    replace_var $env_file "DATA_PATH_HOST" "~\/.$ENV_NAME\/data"
    replace_var $env_file "PHP_IDE_CONFIG" serverName=$ENV_DOMAIN_NAME
    replace_var $env_file "PHP_VERSION" $ENV_PHP_VERSION
    replace_var $env_file "POSTGRES_VERSION" $ENV_DATABASE_VERSION
    replace_var $env_file "POSTGRES_DB" $ENV_DATABASE_NAME
    replace_var $env_file "POSTGRES_USER" $ENV_DATABASE_USER
    replace_var $env_file "POSTGRES_PASSWORD" $ENV_DATABASE_PASSWORD
    replace_var $env_file "POSTGRES_PORT" $ENV_DATABASE_PORT
    replace_var $env_file "REDIS_PORT" $ENV_REDIS_PORT
    replace_var $env_file "REDIS_PASSWORD" $ENV_REDIS_PASSWORD
    replace_var $env_file "WORKSPACE_INSTALL_YARN" false
    replace_var $env_file "PHP_FPM_INSTALL_EXIF" true
    replace_var $env_file "TRAEFIK_WEB_PORT" $ENV_TRAEFIK_WEB_PORT
    replace_var $env_file "TRAEFIK_WEBSECURE_PORT" $ENV_TRAEFIK_WEBSECURE_PORT
    replace_var $env_file "TRAEFIK_DATABASE_PORT" $ENV_TRAEFIK_DATABASE_PORT
    replace_var $env_file "TRAEFIK_REDIS_PORT" $ENV_TRAEFIK_REDIS_PORT
    replace_var $env_file "TRAEFIK_VITE_PORT" $ENV_TRAEFIK_VITE_PORT
    replace_var $env_file "TRAEFIK_DASHBOARD_PORT" $ENV_TRAEFIK_DASHBOARD_PORT
    replace_var $env_file "TRAEFIK_DASHBOARD_USER" "$ENV_TRAEFIK_DASHBOARD_USER"
    replace_var $env_file "TRAEFIK_ACME_EMAIL" $ENV_TRAEFIK_ACME_EMAIL
    replace_var $env_file "TRAEFIK_CLOUDFLARE_EMAIL" $ENV_TRAEFIK_CLOUDFLARE_EMAIL
    replace_var $env_file "TRAEFIK_CLOUDFLARE_API_KEY" $ENV_TRAEFIK_CLOUDFLARE_API_KEY
    replace_var $env_file "TRAEFIK_CLOUDFLARE_DNS" $ENV_TRAEFIK_CLOUDFLARE_DNS
  else
    replace_var $env_file "APP_NAME" $project_name-$ENV_NAME
    replace_var $env_file "APP_DEBUG" $ENV_DEBUG
    replace_var $env_file "APP_ENV" $ENV_TYPE
    replace_var $env_file "APP_URL" "https:\/\/$ENV_TYPE-$project_name.$ENV_DOMAIN_NAME"
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