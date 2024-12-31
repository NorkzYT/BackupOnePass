#!/bin/bash

echo "Starting 1Password lock script..."

echo "Waiting for a brief moment before locking 1Password..."
sleep 2

echo "Locking 1Password..."
# Lock 1Password
xdotool key Ctrl+Shift+l
echo "1Password lock command issued."

echo "Pausing briefly to ensure the lock command has been processed..."
sleep 2

echo "1Password should now be locked."
