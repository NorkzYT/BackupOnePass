#!/bin/bash
# -------------------------------------------------------------

### Automation Steps (Cron Triggered)
echo "Starting auto-login..."
bash /backuponepass/scripts/auto-login-1password.sh

# [Other steps that might run synchronously]
sleep 1
xdotool key Return
sleep 1

echo "Checking for unlock-more-easily prompt..."
python3 /backuponepass/scripts/unlock_more_easily.py

echo "Clicking the kebab icon..."
python3 /backuponepass/scripts/click_kebap_icon.py

# --- Wait for Account Sync Completion ---
LOG_FILE="/home/$USER/.config/1Password/logs/1Password_rCURRENT.log"
TIMEOUT=60 # Timeout in seconds to avoid waiting forever
ELAPSED=0

echo "Waiting for account sync to complete..."
while ! grep -q "synced account" "$LOG_FILE"; do
    sleep 1
    ELAPSED=$((ELAPSED + 1))
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "Timeout reached waiting for account sync."
        exit 1
    fi
done

echo "Account sync completed. Proceeding with export..."

# --- Continue with Export, Locking, etc. ---
echo "Exporting 1Password data..."
bash /backuponepass/scripts/auto-export-data.sh

echo "Locking 1Password..."
bash /backuponepass/scripts/lock-1password.sh

if [ -z "$BACKUP_SCHEDULE" ]; then
    echo "BACKUP_SCHEDULE not defined. Quitting 1Password..."
    bash /backuponepass/scripts/quit-1password.sh
else
    echo "BACKUP_SCHEDULE defined. Keeping 1Password running for reuse."
fi
