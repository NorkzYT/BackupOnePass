#!/bin/bash

echo "Starting 1Password lock script..."

echo "Sourcing environment variables from .env file..."
# Source the environment variables from the .env file
set -a
source /backuponepass/.env
set +a

echo "Environment variables sourced successfully."

echo "Waiting for a brief moment before locking 1Password..."
sleep 1

echo "Locking 1Password..."
# Lock 1Password
xdotool key Ctrl+Shift+l
echo "1Password lock command issued."

echo "Pausing briefly to ensure the lock command has been processed..."
sleep 0.5

echo "1Password should now be locked."
