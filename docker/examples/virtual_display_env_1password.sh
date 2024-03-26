#!/bin/bash

# Start Xvfb on display :99
Xvfb :99 -screen 0 1920x1080x24 &

# Wait for Xvfb to start
sleep 2

# Export the DISPLAY variable
export DISPLAY=:99

# Source the environment variables from the .env file
set -a
source /backuponepass/.env
set +a

# Start 1Password without sandboxing and send it to the background
su "$USER" -c '1password --no-sandbox &'

# Give 1Password some time to start
sleep 5

# ...
