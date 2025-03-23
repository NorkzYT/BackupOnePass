#!/bin/bash

echo "Starting 1Password auto-login script..."

source "/backuponepass/scripts/functions.sh"
echo "Loaded functions.sh..."

echo "Searching for 1Password startup window..."
# Try to find the 1Password first-time startup window
FIRST_STARTUP=$(xdotool search --name "Welcome — 1Password" | head -1)

echo "Searching for 1Password lock screen window..."
# Try to find the 1Password lock screen window
LOCK_SCREEN_WINDOW_ID=$(xdotool search --name "Lock Screen — 1Password" | head -1)

# Check for a specific GUI state that indicates a first-time login
if [ -n "$FIRST_STARTUP" ]; then
    echo "Detected first-time setup, initiating login sequence..."
    sleep 1 # Small delay
    echo "Navigating to 'Sign In' button..."
    xdotool key Tab    # Navigate to the "Sign In" button
    xdotool key Return # Press Enter to activate the button

    echo "Waiting for sign in options to appear..."
    sleep 2

    echo "Going to 'Enter account details'..."

    echo "Typing in account details..."
    sleep 2
    echo "Typing in Email..."
    xdotool type "$ONEPASSWORD_EMAIL"
    xdotool key Tab
    sleep 1
    xdotool key Tab
    sleep 1
    xdotool key Tab
    sleep 1
    xdotool key Tab
    sleep 1
    xdotool key Tab
    sleep 1
    xdotool key Return
    sleep 1
    echo "Typing in Secret key..."
    xdotool type "$ONEPASSWORD_SECRET_KEY"
    xdotool key Tab
    sleep 1
    xdotool key Tab
    sleep 1
    echo "Typing in Password..."
    xdotool type "$ONEPASSWORD_PASSWORD"
    xdotool key Tab
    sleep 1
    xdotool key Tab
    sleep 1
    xdotool key Tab # Skip over the "Use your Emergency Kit & Find your Secret Key"
    xdotool key Return

    echo "Login details entered, waiting for potential MFA prompt..."
    sleep 4

    echo "Monitoring for 2FA prompt using image detection..."
    python3 /backuponepass/scripts/monitor_2fa_image.py
    RESULT=$?

    if [ $RESULT -ne 0 ]; then
        echo "2FA detection failed. Exiting."
        exit 1
    fi

    # Execute the 2FA entry if detection succeeds
    echo "Entering 2FA..."
    enter_2fa

elif [ -n "$LOCK_SCREEN_WINDOW_ID" ]; then
    echo "Detected lock screen window for subsequent login..."

    # Step 1: Enter the password
    echo "Typing the password for subsequent login..."
    xdotool type "$ONEPASSWORD_PASSWORD"
    sleep 2

    # Step 2: Navigate to the submit button and submit the password
    xdotool key Tab
    sleep 1
    xdotool key Tab
    xdotool key Return
    echo "Password submitted. Waiting for MFA prompt..."

    echo "Monitoring for 2FA prompt using image detection..."
    python3 /backuponepass/scripts/monitor_2fa_image.py
    RESULT=$?

    if [ $RESULT -ne 0 ]; then
        echo "2FA detection failed. Exiting."
        exit 1
    fi

    # Execute the 2FA entry if detection succeeds
    xdotool key Return
    echo "Entering 2FA..."
    enter_2fa

else
    echo "No lock screen or startup window detected. Exiting auto-login script."
    exit 1
fi

echo "1Password auto-login script completed."
