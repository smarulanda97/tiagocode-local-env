include .env

BASE_DIR != echo "${ENV_BASE_DIR}" | sed 's/"//g'
DOCKER_DIR != echo "${ENV_BASE_DIR}/${ENV_DOCKER_DIR_NAME}" | sed 's/"//g'
CERTS_DIR != echo "${DOCKER_DIR}/traefik-certs-dumper/.certs" | sed 's/"//g'
DOCKER_COMPOSE_FILE != echo "${DOCKER_DIR}/docker-compose.yml" | sed 's/"//g'
DOCKER_COMPOSE_FILE != echo "${DOCKER_DIR}/docker-compose.yml" | sed 's/"//g'

.PHONY: install
install:
	@sudo chmod +x ./.installer/install.sh && ./.installer/install.sh

.PHONY: start
start:
	@docker compose -f $(DOCKER_COMPOSE_FILE) up -d $(ENV_DOCKER_CONTAINERS)

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
	@docker compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/ workspace bash

.PHONY: logs
logs:
	@docker compose -f $(DOCKER_COMPOSE_FILE) logs --follow

.PHONY: certs
certs:
	@docker compose -f $(DOCKER_COMPOSE_FILE)  up -d traefik-certs-dumper
	@cp -r $(CERTS_DIR) $(BASE_DIR)/code/website/ && cp -r $(CERTS_DIR) $(BASE_DIR)/code/admin/

.PHONY: run-dev
run-dev:
	@docker compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/website workspace npm run dev -- --host

.PHONY: run-test
run-test:
	@docker compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/website workspace npm run test

.PHONY: run-test-ui
run-test-ui:
	@docker compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/website workspace npm run test:ui
