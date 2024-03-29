DOCKER_USERNAME ?= norkz
APPLICATION_NAME ?= BackupOnePass
GIT_HASH ?= $(shell git log --format="%h" -n 1)

### Help Section ###

# Use 'make help' to display the help section

help:
	@echo "\nCommands available:"
	@echo "--------------------------------------------------------------------------------------"
	@echo "\033[1;35mMain Command:\033[0m"
	@echo "  \033[1;33mmake run\033[0m - Sets up and runs docker service."
	@echo "--------------------------------------------------------------------------------------\n"

### Main Script ###
run:
	docker compose -f docker-compose.dev.yml up -d --force-recreate