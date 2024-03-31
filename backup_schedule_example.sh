#!/bin/bash

# Path to the docker-compose file
DOCKER_COMPOSE_FILE="/opt/BackupOnePass/docker-compose.yml"

# Function to perform docker operations
run_docker_operations() {
    # Start the docker containers with force recreate
    if ! docker compose -f "$DOCKER_COMPOSE_FILE" up -d --force-recreate; then
        printf "Failed to start docker containers.\n" >&2
        return 1
    else
        echo "Successfully started container."
    fi
}

# Main function
main() {
    # Set pipefail to ensure errors in a pipeline are captured
    set -o pipefail

    # Execute docker operations
    if ! run_docker_operations; then
        printf "An error occurred during docker operations.\n" >&2
        exit 1
    else
        printf "Docker operations completed successfully.\n"
    fi
}

# Call the main function to start the script
main
