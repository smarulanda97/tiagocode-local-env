include .env

CERTS_DIR != echo "${ENV_BASE_DIR}/docker/traefik-certs-dumper/.certs" | sed 's/"//g'
DOCKER_COMPOSE_FILE != echo "${ENV_BASE_DIR}/docker/docker-compose.yml" | sed 's/"//g'
DOCKER_COMPOSE_FILE != echo "${ENV_BASE_DIR}/docker/docker-compose.yml" | sed 's/"//g'

.PHONY: install
install:
	sudo chmod +x ./.installer/install.sh && ./.installer/install.sh

.PHONY: start
start:
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d $(ENV_DOCKER_CONTAINERS)

.PHONY: stop
stop:
	docker compose -f $(DOCKER_COMPOSE_FILE) down

.PHONY: status
status:
	docker compose -f $(DOCKER_COMPOSE_FILE) ps

.PHONY: clean
clean:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec redis redis-cli flushall

.PHONY: exec
exec:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/ workspace bash

.PHONY: logs
logs:
	docker compose -f $(DOCKER_COMPOSE_FILE) logs --follow

.PHONY: certs
certs:
	docker compose -f $(DOCKER_COMPOSE_FILE)  up -d traefik-certs-dumper
	cp -r $(CERTS_DIR) $(BASE_DIR)/code/website/ && cp -r $(CERTS_DIR) $(BASE_DIR)/code/admin/

.PHONY: dev
dev:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec next npm run dev

.PHONY: test
test:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec next npm run test

.PHONY: test-watch
test-watch:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec next npm run test:watch

.PHONY: build
build:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec next npm run build

.PHONY: generate-css-types
generate-css-types:
	docker compose -f $(DOCKER_COMPOSE_FILE) exec next npm run generate-css-types