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

# Start DBus
if [ ! -S /host/run/dbus/system_bus_socket ]; then
  echo "DBus socket not found. Please ensure it is mounted correctly."
  exit 1
fi
/etc/init.d/dbus start
/etc/NX/nxserver --startup

# Export environment variables for cron with proper escaping
printenv | grep -vE "^(UID|GID|no_proxy)" | while IFS='=' read -r key value; do
  echo "export $key='$(printf '%s' "$value" | sed "s/'/'\\\\''/g")'"
done > /etc/profile.d/env_vars.sh

# Redirect cron logs to container stdout
CRON_LOG=/var/log/cron.log
touch $CRON_LOG
chmod 0644 $CRON_LOG

# Set up the backup schedule
if [ -n "$BACKUP_SCHEDULE" ]; then
  echo "Using custom BACKUP_SCHEDULE: $BACKUP_SCHEDULE"
  echo "$BACKUP_SCHEDULE /bin/bash -c 'source /etc/profile.d/env_vars.sh && /backuponepass/1password_start.sh' >> $CRON_LOG 2>&1" > /etc/cron.d/backup_schedule
  chmod 0644 /etc/cron.d/backup_schedule
  crontab /etc/cron.d/backup_schedule
  service cron start
else
  echo "BACKUP_SCHEDULE is not defined. Running 1password_start.sh once."
  bash /backuponepass/1password_start.sh
fi

# Keep the container running and logging
tail -f $CRON_LOG /usr/NX/var/log/nxserver.log
