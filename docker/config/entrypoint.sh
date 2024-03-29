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

# start nxserver
/etc/init.d/dbus start
/etc/NX/nxserver --startup

# # Start 1Password automation test
bash /backuponepass/1password_start.sh

# Keep the container running and logging
tail -f /usr/NX/var/log/nxserver.log
