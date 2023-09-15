# Define Arguments
DIRECTORY_PATH="/home/hyeyukim"

# Define default action
.PHONY: all
all: build

# Build the Docker images
.PHONY: build
build:
	docker compose -f srcs/docker-compose.yml build $(SERV)

# Start the services defined in docker-compose.yml
.PHONY: up
up:
	mkdir -p ${DIRECTORY_PATH}/mariadb_data
	mkdir -p ${DIRECTORY_PATH}/wordpress_data
	docker compose -f srcs/docker-compose.yml up -d $(SERV)

# Stop the services
.PHONY: down
down:
	docker compose -f srcs/docker-compose.yml down -v $(SERV)

# View logs
.PHONY: logs
logs:
	docker compose -f srcs/docker-compose.yml logs $(SERV)

# Restart services
.PHONY: restart
restart:
	docker compose -f srcs/docker-compose.yml restart $(SERV)

# Remove all containers, networks, and volumes
.PHONY: clean
clean:
	docker compose -f srcs/docker-compose.yml down -v $(SERV)
	sudo rm -rf ${DIRECTORY_PATH}/mariadb_data
	sudo rm -rf ${DIRECTORY_PATH}/wordpress_data

# remove all images
.PHONY: fclean
fclean: clean
	docker system prune -af

# Access shell of a specific service (ex: make shell service=nginx)
.PHONY: shell
shell:
	docker compose -f srcs/docker-compose.yml exec $(SERV) /bin/sh

# Rebuild and restart a service
.PHONY: rebuild
rebuild: clean
	make show
	make build
	make up

# Show all containers, images, volumes
.PHONY: show
show:
	docker ps -a
	@echo
	docker images
	@echo
	docker volume ls
	@echo
	docker network ls

.PHONY: rebuild
re: fclean
	make show
	make build
	make up
