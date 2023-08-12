#!/bin/bash

source env

#
# CLEANING QUOTES OF ENV VARIABLES
#
ENVIRONMENT=$(echo ${ENVIRONMENT} | sed 's/"//g')
PROJECT_DIR=$(echo ${PROJECT_DIR} | sed 's/"//g')
PROJECT_NAME=$(echo ${PROJECT_NAME} | sed 's/"//g')
DOCKER_CONTAINERS=$(echo ${DOCKER_CONTAINERS} | sed 's/"//g')
PHP_VERSION=$(echo ${PHP_VERSION} | sed 's/"//g')
MEMCACHED_HOST=$(echo ${MEMCACHED_HOST} | sed 's/"//g')
DATABASE_HOST=$(echo ${DATABASE_HOST} | sed 's/"//g')
DATABASE_PORT=$(echo ${DATABASE_PORT} | sed 's/"//g')
DATABASE_CONNECTION=$(echo ${DATABASE_CONNECTION} | sed 's/"//g')
DATABASE_NAME=$(echo ${DATABASE_NAME} | sed 's/"//g')
DATABASE_USER=$(echo ${DATABASE_USER} | sed 's/"//g')
DATABASE_PASSWORD=$(echo ${DATABASE_PASSWORD} | sed 's/"//g')
REDIS_HOST=$(echo ${REDIS_PORT} | sed 's/"//g')
REDIS_PORT=$(echo ${REDIS_PORT} | sed 's/"//g')
REDIS_PASSWORD=$(echo ${REDIS_PASSWORD} | sed 's/"//g')

#
# CHECKING DEPENDENCIES
#
echo "info: checking dependencies."

if ! [ -x "$(command -v docker)" ]; then
  echo "error: docker is not installed."; exit
fi

if ! [ -x "$(command -v docker-compose)" ]; then
  echo "error: docker-compose is not installed."; exit
fi

#
# SETTING UP WEBSITE AND ADMIN PROJECTS
#
for SITE_NAME in "website" "admin"
do
  cd "$PROJECT_DIR/$SITE_NAME" || exit
  cp .env.example .env
  echo "info: replacing environment variables for ${SITE_NAME} project."
  sed -i "s/APP_NAME=Laravel/APP_NAME=${PROJECT_NAME}-${SITE_NAME}/g" .env
  sed -i "s/APP_ENV=local/APP_ENV=${ENVIRONMENT}/g" .env
  sed -i "s/APP_URL=http\:\/\/localhost/APP_URL=http\:\/\/${SITE_NAME}.${PROJECT_NAME}.test/g" .env
  sed -i "s/DB_CONNECTION=mysql/DB_CONNECTION=${DATABASE_CONNECTION}/g" .env
  sed -i "s/DB_HOST=127.0.0.1/DB_HOST=${DATABASE_HOST}/g" .env
  sed -i "s/DB_PORT=3306/DB_PORT=${DATABASE_PORT}/g" .env
  sed -i "s/DB_DATABASE=${SITE_NAME}/DB_DATABASE=${DATABASE_NAME}/g" .env
  sed -i "s/DB_USERNAME=root/DB_USERNAME=${DATABASE_USER}/g" .env
  sed -i "s/DB_PASSWORD=/DB_PASSWORD=${DATABASE_PASSWORD}/g" .env
  sed -i "s/MEMCACHED_HOST=127.0.0.1/MEMCACHED_HOST=${MEMCACHED_HOST}/g" .env
  sed -i "s/REDIS_HOST=127.0.0.1/REDIS_HOST=${REDIS_HOST}/g" .env
  sed -i "s/REDIS_PASSWORD=null/REDIS_PASSWORD=${REDIS_PASSWORD}/g" .env
  sed -i "s/REDIS_PORT=6379/REDIS_PORT=${REDIS_PORT}/g" .env
done

#
# SETTING UP DOCKER PROJECT
#
cd "$PROJECT_DIR/docker" || exit
cp .env.example .env
echo "info: replacing environment variables for docker project."
sed -i "s/COMPOSE_FILE=docker-compose.yml/COMPOSE_FILE=docker-compose.${ENVIRONMENT}.yml/g" .env
sed -i "s/COMPOSE_PROJECT_NAME=laradock/COMPOSE_PROJECT_NAME=${PROJECT_NAME}/g" .env
sed -i "s/DATA_PATH_HOST=~\/.laradock\/data/DATA_PATH_HOST=~\/.${PROJECT_NAME}\/data/g" .env
sed -i "s/PHP_IDE_CONFIG=serverName=laradock/PHP_IDE_CONFIG=serverName=${PROJECT_NAME}/g" .env
sed -i "s/PHP_VERSION=7.4/PHP_VERSION=${PHP_VERSION}/g" .env
sed -i "s/POSTGRES_DB=default/POSTGRES_DB=${DATABASE_NAME}/g" .env
sed -i "s/POSTGRES_USER=default/POSTGRES_USER=${DATABASE_USER}/g" .env
sed -i "s/POSTGRES_PASSWORD=secret/POSTGRES_PASSWORD=${DATABASE_PASSWORD}/g" .env
sed -i "s/POSTGRES_PORT=5432/POSTGRES_PORT=${DATABASE_PORT}/g" .env
sed -i "s/REDIS_PORT=6379/REDIS_PORT=${REDIS_PORT}/g" .env
sed -i "s/REDIS_PASSWORD=secret_redis/REDIS_PASSWORD=${REDIS_PASSWORD}/g" .env
sed -i "s/WORKSPACE_INSTALL_YARN=true/WORKSPACE_INSTALL_YARN=false/g" .env

rm -f nginx/sites/default.conf

for SITE_NAME in "website" "admin"
do
  echo "info: creating nginx config file for $SITE_NAME.${PROJECT_NAME}.test"
  CONFIG_FILE="nginx/sites/${SITE_NAME}.${PROJECT_NAME}.test.conf"
  cp nginx/sites/laravel.conf.example $CONFIG_FILE
  sed -i "s/server_name laravel.test;/server_name ${SITE_NAME}.${PROJECT_NAME}.test;/g" $CONFIG_FILE
  sed -i "s/# listen /listen /g" $CONFIG_FILE
  sed -i "s/# ssl_certificate/ssl_certificate/g" $CONFIG_FILE
  sed -i "s/\/var\/www\/laravel\/public/\/var\/www\/${SITE_NAME}\/public/g" $CONFIG_FILE
done

#
# LAUNCHING DOCKER CONTAINERS
#
echo "info: starting docker containers"
cp docker-compose.yml "docker-compose.${ENVIRONMENT}.yml"
docker compose -f "docker-compose.${ENVIRONMENT}.yml" down
docker compose -f "docker-compose.${ENVIRONMENT}.yml" build $DOCKER_CONTAINERS
docker compose -f "docker-compose.${ENVIRONMENT}.yml" up -d $DOCKER_CONTAINERS

#
# STARTING APPLICATION
#
cd "${PROJECT_DIR}/docker" || exit

for SITE_NAME in "website" "admin"
do
  docker compose exec --user=root --workdir=/var/www/$SITE_NAME workspace composer install
  docker compose exec --user=root --workdir=/var/www/$SITE_NAME workspace php artisan key:generate
  docker compose exec --user=root --workdir=/var/www/$SITE_NAME workspace php artisan migrate
  docker compose exec --user=root --workdir=/var/www/$SITE_NAME workspace npm install
  docker compose exec --user=root --workdir=/var/www/$SITE_NAME workspace npm run build
done

docker compose -f "docker-compose.${ENVIRONMENT}.yml" ps