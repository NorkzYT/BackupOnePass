#!/bin/bash

# Start D-Bus if not already running
if ! pgrep -x "dbus-daemon" >/dev/null; then
    dbus-daemon --session --fork
fi

# Start Xvfb on display :99
Xvfb :99 -screen 0 1920x1080x24 &

# Wait for Xvfb to start
sleep 2

# Export the DISPLAY variable
export DISPLAY=:99

# Source the monitor script
source "/backuponepass/scripts/monitor-1password-logs.sh"
echo "Loaded monitor-1password-logs.sh..."

echo "Starting 1Password Automation Script..."

# Start 1Password without sandboxing and send it to the background
su ubuntu -c '1password --no-sandbox &'
sleep 6

# Monitor logs with a timeout of 120 seconds.
if ! monitor_logs_for_line "System unlock" 120; then
    echo "Failed to detect unlock log line within timeout." >&2
    exit 1
fi

# Auto Login for 1Password.
bash /backuponepass/scripts/auto-login-1password.sh

# Click the Kebap menu UI icon using OpenCV.
python3 /backuponepass/scripts/click_kebap_icon.py

# Export the 1Password `.1pux` data.
bash /backuponepass/scripts/auto-export-data.sh

# Lock 1Password
bash /backuponepass/scripts/lock-1password.sh

# Quit 1Password
bash /backuponepass/scripts/quit-1password.sh
