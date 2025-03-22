#!/bin/sh

# Create user and group, configure user settings
groupadd -g "$GID" "$USER" || true
useradd --create-home --no-log-init -u "$UID" -g "$GID" "$USER" || true # Ignore error if user exists
usermod -aG sudo "$USER"
echo "$USER:$PASSWORD" | chpasswd
chsh -s /bin/bash "$USER"

# Ensure the directory structure exists and set permissions
mkdir -p /backuponepass/config /backuponepass/scripts /backuponepass/images
chown -R "$USER":"$USER" /backuponepass

# Ensure directories for 1Password exist
mkdir -p /home/$USER/.config/1Password/logs
touch /home/$USER/.config/1Password/logs/1Password_rCURRENT.log
chown -R "$USER":"$USER" /home/$USER/.config/1Password

# Sync system time
apt-get update && apt-get install -y ntpdate
ntpdate -s time.nist.gov

# Start DBus and noMachine
if [ ! -S /host/run/dbus/system_bus_socket ]; then
  echo "DBus socket not found. Please ensure it is mounted correctly."
  exit 1
fi
/etc/init.d/dbus start
/etc/NX/nxserver --startup

# Export environment variables for cron with proper escaping
printenv | grep -vE "^(UID|GID|no_proxy)" | while IFS='=' read -r key value; do
  echo "export $key='$(printf '%s' "$value" | sed "s/'/'\\''/g")'"
done >/etc/profile.d/env_vars.sh

# Ensure DISPLAY is included for GUI automation
echo "export DISPLAY=:99" >>/etc/profile.d/env_vars.sh

# Set DBus and runtime environment variables
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Start the virtual display (Xvfb) immediately
if [ -z "$DISPLAY" ]; then
  export DISPLAY=:99
  echo "DISPLAY set to $DISPLAY"
fi

if ! pgrep -x "Xvfb" >/dev/null; then
  echo "Starting Xvfb on display $DISPLAY..."
  Xvfb $DISPLAY -screen 0 1920x1080x24 &
  sleep 2 # Give Xvfb time to start
fi

# Redirect cron logs to container stdout
CRON_LOG=/var/log/cron.log
touch $CRON_LOG
chmod 0644 $CRON_LOG

# Always start the immediate launch script for display and initial GUI.
bash /backuponepass/1password_start.sh

# If DEBUG_MODE is enabled, run the automation script immediately.
if [ "$DEBUG_MODE" = "true" ]; then
  echo "DEBUG_MODE enabled: Running 1password_cron.sh immediately."
  bash /backuponepass/1password_cron.sh
elif [ -n "$BACKUP_SCHEDULE" ]; then
  # If a backup schedule is provided, configure cron.
  # Enforce minimum cron interval of 2 minutes
  if echo "$BACKUP_SCHEDULE" | grep -Eq '^\*/[2-9]|^[2-9]|[1-5][0-9]'; then
    echo "Using custom BACKUP_SCHEDULE: $BACKUP_SCHEDULE"
    echo "$BACKUP_SCHEDULE . /etc/profile.d/env_vars.sh && su \"$USER\" -c '/bin/bash /backuponepass/1password_cron.sh' >> /var/log/cron.log 2>&1" >/etc/cron.d/backup_schedule
    chmod 0644 /etc/cron.d/backup_schedule
    crontab /etc/cron.d/backup_schedule
    service cron start
  else
    echo "ERROR: BACKUP_SCHEDULE cannot be less frequent than every 2 minutes."
    exit 1
  fi
fi

# Keep the container running and logging
tail -f $CRON_LOG /usr/NX/var/log/nxserver.log
