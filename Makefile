.PHONY: build
build:
	docker-compose build --no-cache

.PHONY: run
run:
	-docker network create php-practice-network
	docker-compose up

.PHONY: down
down:
	docker-compose down
