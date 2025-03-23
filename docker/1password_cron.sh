#!/bin/bash
# -------------------------------------------------------------

### Automation Steps (Cron Triggered)

# Auto-login steps
echo "Starting auto-login..."
bash /backuponepass/scripts/auto-login-1password.sh

echo "Checking for unlock-more-easily prompt..."
python3 /backuponepass/scripts/unlock_more_easily.py

# Click the Kebap menu UI icon using OpenCV
echo "Clicking the kebab icon..."
python3 /backuponepass/scripts/click_kebap_icon.py

# Export the 1Password .1pux data
echo "Exporting 1Password data..."
bash /backuponepass/scripts/auto-export-data.sh

# Lock 1Password after exporting data
echo "Locking 1Password..."
bash /backuponepass/scripts/lock-1password.sh

# Conditionally quit 1Password if BACKUP_SCHEDULE is not defined
if [ -z "$BACKUP_SCHEDULE" ]; then
    echo "BACKUP_SCHEDULE not defined. Quitting 1Password..."
    bash /backuponepass/scripts/quit-1password.sh
else
    echo "BACKUP_SCHEDULE defined. Keeping 1Password running for reuse."
fi
