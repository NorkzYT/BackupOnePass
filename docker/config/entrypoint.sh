#!/bin/sh
## initialize environment
if [ ! -f "/backuponepass/config/init_flag" ]; then

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
#     echo "$CRON_SCHEDULE /backuponepass/1password_start.sh >> /var/log/cron.log 2>&1" | crontab -
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
