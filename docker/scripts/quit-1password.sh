#!/bin/bash

echo "Starting quit 1Password script..."

echo "Waiting for a brief moment before quitting 1Password..."
sleep 1

echo "Quitting 1Password..."
# Quit 1Password
xdotool key Ctrl+q
echo "Sucessfully quit 1Password."

echo "1Password is now be closed."
