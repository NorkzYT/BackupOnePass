FROM ubuntu:24.04

LABEL maintainer="NorkzYT richard@pcscorp.dev"

ENV DEBIAN_FRONTEND=noninteractive

# Copy files
COPY docker/1password_start.sh /backuponepass/1password_start.sh
COPY docker/config /backuponepass/config
COPY docker/scripts /backuponepass/scripts
COPY docker/images /backuponepass/images

# Set permissions
RUN chmod +x /backuponepass/config/*.sh && \
    chmod +x /backuponepass/scripts/*.sh && \
    chmod +x /backuponepass/scripts/*.py

# Install dependencies
RUN apt-get update && \
    apt-get install -y sudo gedit locales curl gnupg2 lsb-release xdotool oathtool xvfb \
    python3-opencv scrot dbus-x11 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Create a virtual environment and install Python packages
RUN python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install numpy opencv-python Pillow

# Set environment variables for the virtual environment
ENV PATH="/venv/bin:$PATH"

# Setup additional dependencies
ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
RUN apt-get update && apt-get install -y pulseaudio && mkdir -p /var/run/dbus && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y cron

# Install nomachine
RUN bash /backuponepass/config/install_nomachine.sh && \
    groupmod -g 2000 nx && \
    sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg && \
    sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "xset s off && /usr/bin/startxfce4"' /usr/NX/etc/node.cfg

# Install 1password
RUN bash /backuponepass/config/install_1password.sh

# Expose ports
EXPOSE 4000

# Set entrypoint
ENTRYPOINT ["/backuponepass/config/entrypoint.sh"]
