include .env

DOCKER_COMPOSE_FILE != echo "${ENV_DOCKER_DIR_NAME}/docker-compose.yml" | sed 's/"//g'
ENV_DOCKER_CONTAINERS != echo "${ENV_DOCKER_CONTAINERS}" | sed 's/"//g'

.PHONY: install
install:
	sudo chmod +x ./.installer/install.sh && ./.installer/install.sh

.PHONY: start
start:
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d $(ENV_DOCKER_CONTAINERS)

.PHONY: stop
stop:
	@docker compose -f $(DOCKER_COMPOSE_FILE) down

.PHONY: status
status:
	@docker compose -f $(DOCKER_COMPOSE_FILE) ps

.PHONY: clean
clean:
	@docker compose -f $(DOCKER_COMPOSE_FILE) exec redis redis-cli flushall

.PHONY: exec
exec:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/ workspace bash

.PHONY: logs
logs:
	@docker compose -f $(DOCKER_COMPOSE_FILE) logs --follow