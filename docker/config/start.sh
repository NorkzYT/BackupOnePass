#!/bin/bash

echo "Starting 1Password Automation Script..."

# Start 1Password without sandboxing and send it to the background
1password --no-sandbox &
sleep 6

# Loop until the "1Password" is fully running
while true; do
    source "/backuponepass/scripts/monitor-1password-logs.sh"
    echo "Loaded monitor-1password-logs.sh..."

    if monitor_logs_for_line "System unlock was attempted but we cannot use it."; then
        sleep 1
        # If found, break out of the loop
        break
    else
        # If not found, sleep for 1 second and try again
        sleep 1
    fi
done

# Auto Login for 1Password.
bash /backuponepass/scripts/auto-login-1password.sh

# Get to the 1Password export data UI by clicking buttons using OpenCV.
python3 /backuponepass/scripts/click_export_button.py

# Export the 1Password `.1pux` data.
bash /backuponepass/scripts/auto-export-data.sh

# Lock 1Password
bash /backuponepass/scripts/lock-1password.sh
