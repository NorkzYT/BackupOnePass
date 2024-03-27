#!/bin/bash

# Source the monitor script
source "/backuponepass/scripts/monitor-1password-logs.sh"
echo "Loaded monitor-1password-logs.sh..."

echo "Starting 1Password Automation Script..."

# Start 1Password without sandboxing and send it to the background
1password --no-sandbox &
sleep 6

# Monitor logs with a timeout of 120 seconds.
if ! monitor_logs_for_line "System unlock" 120; then
    echo "Failed to detect unlock log line within timeout." >&2
    exit 1
fi

# Auto Login for 1Password.
bash /backuponepass/scripts/auto-login-1password.sh

# Get to the 1Password export data UI by clicking buttons using OpenCV.
python3 /backuponepass/scripts/click_export_button.py

# Export the 1Password `.1pux` data.
bash /backuponepass/scripts/auto-export-data.sh

# Lock 1Password
bash /backuponepass/scripts/lock-1password.sh
