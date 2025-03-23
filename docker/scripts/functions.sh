#!/bin/bash

# Function to enter 2FA code
enter_2fa() {
    echo "Attempting to generate and enter 2FA code..."

    # Ensure the 1Password window is active
    WINDOW_ID=$(xdotool search --name "1Password")
    if [ -n "$WINDOW_ID" ]; then
        echo "Focusing 1Password window ID: $WINDOW_ID"
        xdotool windowactivate "$WINDOW_ID"
        sleep 1 # Allow time for focus
    else
        echo "Error: 1Password window not found."
        echo "Listing all active window names:" # Added error debug output
        xdotool search --onlyvisible --name ".*" getwindowname
        return 1
    fi

    # Generate a 2FA code using the secret key (if TOTP is used)
    TWOFA_CODE=$(oathtool --totp -b "$ONEPASSWORD_TOTP_SECRET")
    if [ -n "$TWOFA_CODE" ]; then
        echo "2FA code generated: $TWOFA_CODE"
    else
        echo "Error: Failed to generate 2FA code."
        return 1
    fi

    # Enter the 2FA code
    echo "Entering the 2FA code..."
    xdotool type "$TWOFA_CODE"
    sleep 1

    # Submit the 2FA code
    echo "Submitting the 2FA code..."
    xdotool key Tab
    sleep 1
    xdotool key Return

    # Wait briefly to ensure the code is processed
    echo "Waiting for confirmation of 2FA submission..."
    sleep 2
    xdotool key Return

    echo "2FA process completed."
}
