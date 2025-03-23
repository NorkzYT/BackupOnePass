#!/bin/bash
# -------------------------------------------------------------
### Headless Setup for Immediate Launch
# Ensure D-Bus is running
if ! pgrep -x "dbus-daemon" >/dev/null; then
    echo "Starting D-Bus..."
    dbus-daemon --system --fork
fi

# Ensure directories and log files for 1Password exist
mkdir -p /home/$USER/.config/1Password/logs
touch /home/$USER/.config/1Password/logs/1Password_rCURRENT.log

# Make sure DISPLAY is set (default to :99)
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:99
    echo "DISPLAY environment variable set to $DISPLAY"
fi

# Start Xvfb if not already running
if ! pgrep -x "Xvfb" >/dev/null; then
    echo "Starting Xvfb on $DISPLAY..."
    Xvfb $DISPLAY -screen 0 1920x1080x24 &
    sleep 2
fi

# Disable screen blanking and power management to avoid black screen in NoMachine
echo "Disabling screen blanking and DPMS..."
DISPLAY=:99 xset s off
DISPLAY=:99 xset s noblank

# -------------------------------------------------------------
### Launch 1Password Immediately
echo "Starting 1Password Automation Script..."

# Check if 1Password is already running
if pgrep -x "1password" >/dev/null; then
    echo "1Password is already running. Skipping launch..."
else
    echo "Launching 1Password..."
    # Launch 1Password without sandboxing in the background
    su "$USER" -c '1password --no-sandbox &'
    sleep 5 # Wait for the process to initialize

    # Monitor for the 1Password logo to confirm the GUI is active
    python3 /backuponepass/scripts/monitor_logo_image.py
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echo "1Password Logo detection failed. Exiting."
        exit 1
    fi
fi

echo "1Password launched successfully. The display should now be active for NoMachine."
