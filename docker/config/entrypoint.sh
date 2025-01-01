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

# Start DBus
if [ ! -S /host/run/dbus/system_bus_socket ]; then
  echo "DBus socket not found. Please ensure it is mounted correctly."
  exit 1
fi
/etc/init.d/dbus start
/etc/NX/nxserver --startup

# Export environment variables for cron with proper escaping
printenv | grep -vE "^(UID|GID|no_proxy)" | while IFS='=' read -r key value; do
  echo "export $key='$(printf '%s' "$value" | sed "s/'/'\\''/g")'"
done > /etc/profile.d/env_vars.sh

# Handle DBus permissions
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
export XDG_RUNTIME_DIR="/tmp/runtime-$USER"
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# Redirect cron logs to container stdout
CRON_LOG=/var/log/cron.log
touch $CRON_LOG
chmod 0644 $CRON_LOG

# Set up the backup schedule
if [ -n "$BACKUP_SCHEDULE" ]; then
  # Enforce minimum cron interval of 2 minutes
  if echo "$BACKUP_SCHEDULE" | grep -Eq '^\*/[2-9]|^[2-9]|[1-5][0-9]'; then
    echo "Using custom BACKUP_SCHEDULE: $BACKUP_SCHEDULE"
    echo "$BACKUP_SCHEDULE /bin/bash -c 'source /etc/profile.d/env_vars.sh && /backuponepass/1password_start.sh' >> $CRON_LOG 2>&1" > /etc/cron.d/backup_schedule
    chmod 0644 /etc/cron.d/backup_schedule
    crontab /etc/cron.d/backup_schedule
    service cron start
  else
    echo "ERROR: BACKUP_SCHEDULE cannot be less frequent than every 2 minutes."
    exit 1
  fi
else
  echo "BACKUP_SCHEDULE is not defined. Running 1password_start.sh once."
  bash /backuponepass/1password_start.sh
fi

# Keep the container running and logging
tail -f $CRON_LOG /usr/NX/var/log/nxserver.log
