ifneq (,$(wildcard ./.env))
    include .env
    export
endif

PROJECT_DIR != echo ${PROJECT_DIR} | sed 's/"//g'
DOCKER_CONTAINERS != echo ${DOCKER_CONTAINERS} | sed 's/"//g'
DOCKER_COMPOSE_FILE != echo ${DOCKER_COMPOSE_FILE} | sed 's/"//g'

.PHONY: install
install:
	sudo chmod +x ./install.sh && ./install.sh

.PHONY: start
start:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) up -d $(DOCKER_CONTAINERS)

.PHONY: stop
stop:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) down

.PHONY: status
status:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) ps

.PHONY: clean
clean:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec redis redis-cli flushall

.PHONY: migrate
migrate:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/website/ workspace composer install
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/admin/ workspace composer install
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/website/ workspace npm install
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/admin/ workspace npm install

.PHONY: migrate
migrate:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/website/ workspace php artisan migrate
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/admin/ workspace php artisan migrate

.PHONY: exec
exec:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) exec --user=root --workdir=/var/www/ workspace bash

.PHONY: logs
logs:
	@docker-compose -f $(DOCKER_COMPOSE_FILE) logs --follow