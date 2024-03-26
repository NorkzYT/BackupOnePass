#!/bin/bash

enter_2fa() {
    # Wait for potential 2FA screen
    sleep 5

    # Generate a 2FA code using the secret key (if TOTP is used)
    TWOFA_CODE=$(oathtool --totp -b "$UBUNTU_DESKTOP_ONEPASSWORD_TOTP_SECRET")

    # Use xdotool to enter the 2FA code if the TWOFA_CODE variable is not empty
    if [ -n "$TWOFA_CODE" ]; then
        xdotool type "$TWOFA_CODE"
        xdotool key Tab    # Navigate away from the 2FA field (if needed)
        xdotool key Return # Submit the 2FA form
    fi

    # Wait for screen change and any pop-ups
    sleep 5

    # Double Enter if anything pops-up to "Continue"
    xdotool key Return
    xdotool key Return
}

# Source the environment variables from the .env file
set -a
source /backuponepass/.env
set +a

# Start 1Password without sandboxing and send it to the background
1password --no-sandbox &

# Give 1Password some time to start
sleep 5

# Try to find the 1Password first-time startup window
FIRST_STARTUP=$(xdotool search --name "Welcome — 1Password" | head -1)

# Try to find the 1Password lock screen window
LOCK_SCREEN_WINDOW_ID=$(xdotool search --name "Lock Screen — 1Password" | head -1)

# Check for a specific GUI state that indicates a first-time login
if [ -n "$FIRST_STARTUP" ]; then
    echo "Detected first-time setup"
    # Activate the window
    xdotool windowactivate "$FIRST_STARTUP"
    sleep 1 # Small delay
    # Fullscreen the 1Password window
    xdotool key F11
    xdotool key Tab    # Navigate to the "Sign In" button
    xdotool key Return # Press Enter to activate the button

    # Wait a little bit for the sign in options to appear
    sleep 2

    # Go to "Enter account details"
    xdotool key Tab
    xdotool key Tab
    xdotool key Tab
    xdotool key Tab
    xdotool key Return # Press Enter to select

    # Wait a little bit for the "Enter account details" to appear
    sleep 2

    # Type the email address
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_EMAIL"
    xdotool key Tab

    # Wait before going to the next field
    sleep 1

    # Type the secret key
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_SECRET_KEY"
    xdotool key Tab
    xdotool key Tab

    # Wait before going to the next field
    sleep 1

    # Type the password
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_PASSWORD"
    xdotool key Tab
    xdotool key Tab

    # Wait before going to the next step
    sleep 1

    xdotool key Tab # Skip over the "Get help" link

    # Finally, press Enter to submit the login form
    xdotool key Return

    enter_2fa

elif [ -n "$LOCK_SCREEN_WINDOW_ID" ]; then
    echo "Detected subsequent login"
    # Activate the window
    xdotool windowactivate "$LOCK_SCREEN_WINDOW_ID"
    sleep 1 # Small delay
    # Assuming the password field is immediately active, type the password
    sleep 1 # Small delay
    xdotool type "$UBUNTU_DESKTOP_ONEPASSWORD_PASSWORD"
    sleep 1 # Small delay
    xdotool key Return

    enter_2fa
else
    echo "1Password window not found or not ready yet"
fi
