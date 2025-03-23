# Use the phusion baseimage for Ubuntu Jammy
# https://hub.docker.com/r/phusion/baseimage
FROM phusion/baseimage:jammy-1.0.4

LABEL maintainer="NorkzYT richard@pcscorp.dev"

ENV DEBIAN_FRONTEND=noninteractive

# Copy all required files into the container
COPY docker/1password_start.sh /backuponepass/1password_start.sh
COPY docker/1password_cron.sh /backuponepass/1password_cron.sh
COPY docker/config /backuponepass/config
COPY docker/scripts /backuponepass/scripts
COPY docker/images /backuponepass/images

# Set execute permissions on shell and Python scripts
RUN chmod +x /backuponepass/config/*.sh && \
    chmod +x /backuponepass/scripts/*.sh && \
    chmod +x /backuponepass/scripts/*.py

# Install OS-level dependencies
RUN apt-get update && \
    apt-get install -y sudo gedit locales curl gnupg2 lsb-release xdotool oathtool xvfb \
    python3-opencv scrot dbus-x11 python3-pip x11-xserver-utils && \
    rm -rf /var/lib/apt/lists/*

# Copy and install Python packages globally from requirements.txt
# Ensure that your requirements.txt is located at docker/config/requirements.txt
COPY docker/config/requirements.txt /tmp/requirements.txt
RUN pip3 install --upgrade pip && \
    pip3 install -r /tmp/requirements.txt

# Setup additional dependencies: DBus and pulseaudio
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
RUN apt-get update && apt-get install -y pulseaudio && mkdir -p /var/run/dbus && \
    rm -rf /var/lib/apt/lists/*

# Install cron for scheduling automation tasks
RUN apt-get update && apt-get install -y cron

# Install NoMachine (and tweak its configuration)
RUN bash /backuponepass/config/install_nomachine.sh && \
    groupmod -g 2000 nx && \
    sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg && \
    sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "xset s off && /usr/bin/startxfce4"' /usr/NX/etc/node.cfg

# Install 1Password
RUN bash /backuponepass/config/install_1password.sh

# Add 1Password binary directory to the PATH so that "1password" is found.
ENV PATH="/opt/1Password:$PATH"

# Expose the port used by NoMachine
EXPOSE 4000

# Set the container entrypoint
ENTRYPOINT ["/backuponepass/config/entrypoint.sh"]
