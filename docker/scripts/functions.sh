#!/bin/bash

# Function to enter 2FA code
enter_2fa() {
    echo "Attempting to generate and enter 2FA code..."

    # Generate a 2FA code using the secret key (if TOTP is used)
    TWOFA_CODE=$(oathtool --totp -b "$ONEPASSWORD_TOTP_SECRET")
    echo "2FA code generated."

    # Use xdotool to enter the 2FA code if the TWOFA_CODE variable is not empty
    if [ -n "$TWOFA_CODE" ]; then
        echo "Entering the 2FA code into the input field..."
        xdotool type "$TWOFA_CODE"
        echo "Navigating away from the 2FA field..."
        xdotool key Tab # Navigate away from the 2FA field (if needed)
        echo "Submitting the 2FA form..."
        xdotool key Return # Submit the 2FA form
    else
        echo "No 2FA code was generated. Skipping 2FA entry."
    fi

    # Wait for screen change and any pop-ups
    echo "Waiting for potential screen changes or pop-ups..."
    sleep 2

    # Double Enter if anything pops-up to "Continue"
    echo "Sending double 'Enter' key presses to bypass any pop-ups..."
    xdotool key Return
    xdotool key Return

    echo "2FA process completed."
}
