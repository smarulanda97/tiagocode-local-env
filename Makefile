.PHONY: install
install:
	sudo chmod +x ./.installer/install.sh && ./.installer/install.sh

.PHONY: start
start:
	docker compose -f .docker/docker-compose.yml up -d traefik postgres nginx php-fpm workspace redis

.PHONY: stop
stop:
	@docker compose -f .docker/docker-compose.yml down

.PHONY: status
status:
	@docker compose -f .docker/docker-compose.yml ps

.PHONY: clean
clean:
	@docker compose -f .docker/docker-compose.yml exec redis redis-cli flushall

.PHONY: exec
exec:
	docker compose -f .docker/docker-compose.yml exec --user=root --workdir=/var/www/ workspace bash

.PHONY: logs
logs:
	@docker compose -f .docker/docker-compose.yml logs --follow