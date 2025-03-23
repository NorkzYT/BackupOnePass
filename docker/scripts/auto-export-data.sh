#!/bin/bash

echo "Ensuring display remains active..."
# Reinforce that blanking/DPMS is off before proceeding
DISPLAY=:99 xset s off -dpms
DISPLAY=:99 xset s noblank

echo "Ensuring 1Password window is active..."
# Try to find the 1Password window and raise it
WINDOW_ID=$(xdotool search --onlyvisible --name "1Password")
if [ -n "$WINDOW_ID" ]; then
    echo "1Password window found (ID: $WINDOW_ID). Activating..."
    xdotool windowactivate "$WINDOW_ID"
    xdotool windowraise "$WINDOW_ID"
    sleep 1
else
    echo "Warning: 1Password window not found. Proceeding..."
fi

echo "Starting auto-export-data script..."

echo "Opening the export menu..."

# Simulate pressing the down arrow key
xdotool key Down
sleep 1
xdotool key Down
sleep 1
xdotool key Down
sleep 1
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
sleep 1
xdotool key Tab
sleep 1
xdotool key Tab
echo "Initiating the export process..."
xdotool key Return # Export Data
sleep 1

# -------------------------------------------------------------
### Non-Headless

# Go into the file directory to then save and start export process
python3 /backuponepass/scripts/click_export_location.py

# -------------------------------------------------------------

### Headless

# echo "Navigating to the address bar to type the save location..."
# xdotool key Ctrl+l
# sleep 1

# echo "Typing the save location path..."
# xdotool type "/backuponepass/data"
# sleep 1

# echo "Confirming the save location..."
# xdotool key Return

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
