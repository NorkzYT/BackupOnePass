#!/bin/bash

echo "Starting auto-export-data script..."

source "/backuponepass/scripts/monitor-1password-logs.sh"

echo "Sourcing environment variables from .env file..."
# Source the environment variables from the .env file
set -a
source /backuponepass/.env
set +a

echo "Opening the export menu..."

# Simulate pressing the down arrow key
xdotool key Down
xdotool key Down
xdotool key Down
xdotool key Down

# Click Enter
xdotool key Return

# Simulate pressing the right arrow key
xdotool key Right

# Click Enter
xdotool key Return

echo "Waiting for a second before starting the export process..."
sleep 1

echo "Typing the secret key..."
xdotool type "$BACKUP_ONE_PASS_ONEPASSWORD_PASSWORD"
echo "Navigating through the export dialog..."
xdotool key Tab
xdotool key Tab
xdotool key Tab
echo "Initiating the export process..."
xdotool key Return # Export Data

echo "Waiting for a second before navigating to the address bar..."
sleep 1

# -------------------------------------------------------------
### Non-Headless

# echo "Navigating to the address bar to type the save location..."
# xdotool key Ctrl+l
# sleep 0.5

# echo "Typing the save location path..."
# xdotool type "/backuponepass/data"
# sleep 0.5

# echo "Confirming the save location..."
# xdotool key Return

# -------------------------------------------------------------

### Headless

# Go into the file directory to then save and start export process
python3 /backuponepass/scripts/click_export_location.py

# -------------------------------------------------------------

echo "Waiting for a second to ensure the save location is confirmed..."
sleep 1

echo "Starting to monitor the 1Password log for the 'Finished export task' message..."
if ! monitor_logs_for_line "Finished export task" 120; then
    echo "'Finished export task' not found in logs. Checking again..."
else
    echo "'Finished export task' found in logs. Confirming export completion..."
    xdotool key Return
fi

echo "Auto-export-data script completed."
