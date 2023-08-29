#!/bin/bash

function docker_compose_up {
  docker_dir=$1

  echo "INFO: building and starting docker compose services '$ENV_DOCKER_SERVICES'."
  docker compose -f $docker_dir/docker-compose.yml build $ENV_DOCKER_SERVICES
  docker compose -f $docker_dir/docker-compose.yml up -d $ENV_DOCKER_SERVICES
}

function docker_compose_down {
  docker_dir=$1

  echo "INFO: removing docker compose services."
  docker compose -f $docker_dir/docker-compose.yml down
}

function docker_compose_ps {
  docker_dir=$1

  docker compose -f $docker_dir/docker-compose.yml ps
}

function docker_compose_exec {
  docker_dir=$1
  workdir=$2
  service=$3
  command=$4

  docker compose -f $docker_dir/docker-compose.yml exec --user=root --workdir=${workdir} ${service} ${command}
}