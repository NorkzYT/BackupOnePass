#!/bin/bash

echo "Starting auto-export-data script..."

echo "Opening the export menu..."

# Simulate pressing the down arrow key
xdotool key Down
sleep 0.5
xdotool key Down
sleep 0.5
xdotool key Down
sleep 0.5
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
xdotool type "$ONEPASSWORD_PASSWORD"
echo "Navigating through the export dialog..."
xdotool key Tab
sleep 0.5
xdotool key Tab
sleep 0.5
xdotool key Tab
echo "Initiating the export process..."
xdotool key Return # Export Data
sleep 1

# -------------------------------------------------------------
### Non-Headless

# Go into the file directory to then save and start export process
#python3 /backuponepass/scripts/click_export_location.py

# -------------------------------------------------------------

### Headless

echo "Navigating to the address bar to type the save location..."
xdotool key Ctrl+l
sleep 1

echo "Typing the save location path..."
xdotool type "/backuponepass/data"
sleep 1

echo "Confirming the save location..."
xdotool key Return

# -------------------------------------------------------------

echo "Waiting for a second to ensure the save location is confirmed..."
sleep 1

echo "Starting to monitor for 'Export Finished' image using GUI detection..."
python3 /backuponepass/scripts/monitor_export_complete_image.py
RESULT=$?

if [ $RESULT -ne 0 ]; then
    echo "Export completion detection failed. Exiting."
    exit 1
fi

sleep 1
xdotool key Return

echo "Auto-export-data script completed."
