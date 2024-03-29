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

# start nxserver
/etc/init.d/dbus start
/etc/NX/nxserver --startup

# # Start 1Password automation test
bash /backuponepass/1password_start.sh

# Keep the container running and logging
tail -f /usr/NX/var/log/nxserver.log
