#!/bin/bash

echo "Starting 1Password auto-login…"
source "/backuponepass/scripts/functions.sh"

FIRST_STARTUP=$(xdotool search --name "Welcome — 1Password" | head -1)
LOCK_SCREEN=$(xdotool search --name "Lock Screen — 1Password" | head -1)

if [ -n "$FIRST_STARTUP" ]; then
    echo "First-time setup detected, filling credentials…"
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
    echo "Waiting for MFA prompt…"
    sleep 4

    handle_2fa || exit 1

elif [ -n "$LOCK_SCREEN" ]; then
    echo "Lock screen detected, entering password…"
    xdotool type "$ONEPASSWORD_PASSWORD" && sleep 1
    xdotool key Tab && sleep 1
    xdotool key Tab && xdotool key Return
    echo "Waiting for MFA prompt…"
    sleep 2

    handle_2fa || exit 1

else
    echo "No valid 1Password window found; exiting."
    exit 1
fi

echo "1Password auto-login completed."
