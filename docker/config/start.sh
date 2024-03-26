#!/bin/bash

# Start 1Password without sandboxing and send it to the background
1password --no-sandbox &

# Give 1Password some time to start
sleep 4

# Auto Login for 1Password.
bash ./backuponepass/scripts/auto-login-1password.sh

# Get to the 1Password export data UI by clicking buttons using OpenCV.
python3 ./backuponepass/scripts/click_export_button.py

# Export the 1Password `.1pux` data.
bash ./backuponepass/scripts/auto-export-data.sh

# Lock 1Password
bash ./backuponepass/scripts/lock-1password.sh