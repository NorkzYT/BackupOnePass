FROM ubuntu:20.04

LABEL maintainer="NorkzYT richard@pcscorp.dev"

ENV DEBIAN_FRONTEND=noninteractive

## Copy 1password_start.sh file 
COPY docker/1password_start.sh /backuponepass/1password_start.sh

## Copy config folder 
COPY docker/config /backuponepass/config

# Copy scripts folder 
COPY docker/scripts /backuponepass/scripts

# Copy images folder 
COPY docker/images /backuponepass/images

# Ensure scripts in config have execute permissions
RUN chmod +x /backuponepass/config/*.sh && \
    chmod +x /backuponepass/scripts/*.sh

## Install some common tools 
RUN apt-get update && \
    apt-get install -y sudo gedit locales curl gnupg2 lsb-release xdotool oathtool xvfb \
    python3-opencv scrot dbus-x11 \
    python3-pip && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2 && \
    pip3 install --upgrade pip &&\
    pip3 install numpy opencv-python Pillow &&\
    rm -rf /var/lib/apt/lists/* 

ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
RUN apt-get update && apt-get install -y pulseaudio && mkdir -p /var/run/dbus &&\
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y cron

## Install nomachine
RUN bash /backuponepass/config/install_nomachine.sh && \
    groupmod -g 2000 nx && \
    sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg && \
    sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "xset s off && /usr/bin/startxfce4"' /usr/NX/etc/node.cfg

## Install 1password
RUN bash /backuponepass/config/install_1password.sh

EXPOSE 4000

ENTRYPOINT ["/backuponepass/config/entrypoint.sh"]
