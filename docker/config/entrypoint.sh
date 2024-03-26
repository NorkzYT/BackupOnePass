#!/bin/sh
## initialize environment
if [ ! -f "/backuponepass/config/init_flag" ]; then
    # create user
    groupadd -g "$GID" "$USER"
    useradd --create-home --no-log-init -u "$UID" -g "$GID" "$USER"
    usermod -aG sudo "$USER"
    echo "$USER:$PASSWORD" | chpasswd
    chsh -s /bin/bash "$USER"

    # Create folders and set permissions
    mkdir -p /backuponepass/config
    mkdir -p /backuponepass/scripts
    mkdir -p /backuponepass/images
    chown "$USER":"$USER" /backuponepass
    chmod 777 /backuponepass

    # vgl for user
    echo "export PATH=/usr/NX/scripts/vgl:\$PATH" >>/home/"$USER"/.bashrc
    echo "export VGL_DISPLAY=$VGL_DISPLAY" >>/home/"$USER"/.bashrc
    # extra env init for developer
    if [ -f "/backuponepass/config/env_init.sh" ]; then
        bash /backuponepass/config/env_init.sh
    fi
    # custom env init for user
    if [ -f "/backuponepass/config/custom_env_init.sh" ]; then
        bash /backuponepass/config/custom_env_init.sh
    fi
    echo "ok" >/backuponepass/config/init_flag
fi

# # Setup cron job
# if [ -n "$CRON_SCHEDULE" ]; then
#     ## Print when the backup will start according to CRON_SCHEDULE
#     echo "Backup will start $CRON_SCHEDULE"
#     echo "$CRON_SCHEDULE /backuponepass/scripts/start.sh >> /var/log/cron.log 2>&1" | crontab -
#     # Start the cron service in the background
#     cron
# fi

## startup
# custom startup for user
if [ -f "/backuponepass/config/custom_startup.sh" ]; then
    bash /backuponepass/config/custom_startup.sh
fi

# start sshd&nxserver
/usr/sbin/sshd
/etc/init.d/dbus start
/etc/NX/nxserver --startup

# Keep the container running and logging
tail -f /usr/NX/var/log/nxserver.log /var/log/cron.log
