#!/bin/bash

# -------------------------------------------------------------
### Headless

# Start D-Bus if not already running
if ! pgrep -x "dbus-daemon" >/dev/null; then
    echo "Starting D-Bus..."
    dbus-daemon --system --fork
fi

# Ensure directories and files for 1Password exist
mkdir -p /home/$USER/.config/1Password/logs
touch /home/$USER/.config/1Password/logs/1Password_rCURRENT.log

# Ensure DISPLAY is set correctly
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:99
    echo "DISPLAY environment variable set to $DISPLAY"
fi

# Handle Xvfb to avoid duplicate instance issues
if pgrep -x "Xvfb" >/dev/null; then
    echo "Xvfb is already running."
else
    echo "Starting virtual display for GUI automation..."
    Xvfb :99 -screen 0 1920x1080x24 &
    sleep 2
fi

# -------------------------------------------------------------
### Non-Headless

echo "Starting 1Password Automation Script..."

# Check if 1Password is already running
if pgrep -x "1password" >/dev/null; then
    echo "1Password is already running. Skipping launch..."
else
    # Start 1Password without sandboxing and send it to the background
    echo "Launching 1Password..."
    su "$USER" -c '1password --no-sandbox &'
    sleep 5
    python3 /backuponepass/scripts/monitor_logo_image.py
    RESULT=$?

    if [ $RESULT -ne 0 ]; then
        echo "OnePassword Logo Image detection failed. Exiting."
        exit 1
    fi
fi

# Auto Login for 1Password.
bash /backuponepass/scripts/auto-login-1password.sh

# Click the Kebap menu UI icon using OpenCV.
python3 /backuponepass/scripts/click_kebap_icon.py

# Export the 1Password `.1pux` data.
bash /backuponepass/scripts/auto-export-data.sh

# Lock 1Password
bash /backuponepass/scripts/lock-1password.sh

# Conditionally quit 1Password based on BACKUP_SCHEDULE
if [ -z "$BACKUP_SCHEDULE" ]; then
    echo "BACKUP_SCHEDULE not defined. Quitting 1Password..."
    bash /backuponepass/scripts/quit-1password.sh
else
    echo "BACKUP_SCHEDULE defined. Keeping 1Password running for reuse."
fi
