#!/bin/bash

echo "Starting 1Password auto-login script..."

source "/backuponepass/scripts/functions.sh"
echo "Loaded functions.sh..."

source "/backuponepass/scripts/monitor-1password-logs.sh"
echo "Loaded monitor-1password-logs.sh..."

echo "Sourcing environment variables from .env file..."
# Source the environment variables from the .env file
set -a
source /backuponepass/.env
set +a

echo "Searching for 1Password startup window..."
# Try to find the 1Password first-time startup window
FIRST_STARTUP=$(xdotool search --name "Welcome — 1Password" | head -1)

echo "Searching for 1Password lock screen window..."
# Try to find the 1Password lock screen window
LOCK_SCREEN_WINDOW_ID=$(xdotool search --name "Lock Screen — 1Password" | head -1)

# Check for a specific GUI state that indicates a first-time login
if [ -n "$FIRST_STARTUP" ]; then
    echo "Detected first-time setup, initiating login sequence..."
    # Activate the window
    xdotool windowactivate "$FIRST_STARTUP"
    sleep 1 # Small delay
    echo "Fullscreening the 1Password window..."
    xdotool key F11
    echo "Navigating to 'Sign In' button..."
    xdotool key Tab    # Navigate to the "Sign In" button
    xdotool key Return # Press Enter to activate the button

    echo "Waiting for sign in options to appear..."
    sleep 2

    echo "Going to 'Enter account details'..."
    xdotool key Tab
    xdotool key Tab
    xdotool key Tab
    xdotool key Tab
    xdotool key Return # Press Enter to select

    echo "Typing in account details..."
    sleep 2
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_EMAIL"
    xdotool key Tab
    sleep 1
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_SECRET_KEY"
    xdotool key Tab
    xdotool key Tab
    sleep 1
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_PASSWORD"
    xdotool key Tab
    xdotool key Tab
    sleep 1
    xdotool key Tab # Skip over the "Get help" link
    xdotool key Return

    echo "Login details entered, waiting for potential MFA prompt..."
    sleep 4

    initiate_log_monitor
    if monitor_logs_for_line "Prompting user for MFA"; then
        enter_2fa
    else
        echo "MFA prompt not detected. Will continue without MFA."
    fi

elif [ -n "$LOCK_SCREEN_WINDOW_ID" ]; then
    echo "Detected subsequent login attempt..."
    xdotool windowactivate "$LOCK_SCREEN_WINDOW_ID"
    sleep 1
    echo "Typing the password for subsequent login..."
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_PASSWORD"
    sleep 1
    xdotool key Return

    echo "Waiting for potential MFA Prompt after subsequent login..."
    sleep 4

    initiate_log_monitor
    if monitor_logs_for_line "Prompting user for MFA"; then
        enter_2fa
    else
        echo "MFA prompt not detected in subsequent login. Continuing..."
    fi
else
    echo "1Password window not found or not ready yet. Exiting script."
fi

echo "1Password auto-login script completed."
