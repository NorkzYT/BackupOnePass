#!/bin/bash

# Function to enter 2FA code
enter_2fa() {
    echo "Attempting to generate and enter 2FA code..."

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
    sleep 0.5

    # Submit the 2FA code
    echo "Submitting the 2FA code..."
    xdotool key Tab
    sleep 0.5
    xdotool key Return

    # Wait briefly to ensure the code is processed
    echo "Waiting for confirmation of 2FA submission..."
    sleep 2
    xdotool key Return

    echo "2FA process completed."
}
