FROM ubuntu:20.04

LABEL maintainer="NorkzYT richard@pcscorp.dev"

ENV DEBIAN_FRONTEND=noninteractive

ARG USER
ARG PASSWORD
ARG UID
ARG GID

ENV USER=${USER} \
    PASSWORD=${PASSWORD} \
    UID=${UID} \
    GID=${GID}

# Create user and group, configure user settings
RUN groupadd -g "$GID" "$USER" && \
    useradd --create-home --no-log-init -u "$UID" -g "$GID" "$USER" && \
    usermod -aG sudo "$USER" && \
    echo "$USER:$PASSWORD" | chpasswd && \
    chsh -s /bin/bash "$USER"

# Create folders and set permissions
RUN mkdir -p /backuponepass/config /backuponepass/scripts /backuponepass/images && \
    chown -R "$USER":"$USER" /backuponepass

# Copy env file
COPY .env /backuponepass

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
    apt-get install -y sudo vim gedit locales wget curl tar git gnupg2 lsb-release net-tools iputils-ping mesa-utils xdotool oathtool xvfb \
    python3-opencv scrot cron dbus-x11 \
    openssh-server bash-completion software-properties-common python3-pip && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2 && \
    pip3 install --upgrade pip &&\
    pip3 install numpy opencv-python Pillow &&\
    rm -rf /var/lib/apt/lists/* 

## Install desktop
RUN apt-get update && \
    # install xfce4
    apt-get install -y xfce4 terminator fonts-wqy-zenhei ffmpeg &&\
    rm -rf /var/lib/apt/lists/*

ENV DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
RUN apt-get update && apt-get install -y pulseaudio && mkdir -p /var/run/dbus &&\
    rm -rf /var/lib/apt/lists/*

## Install nomachine
RUN bash /backuponepass/config/install_nomachine.sh && \
    groupmod -g 2000 nx && \
    sed -i "s|#EnableClipboard both|EnableClipboard both |g" /usr/NX/etc/server.cfg && \
    sed -i '/DefaultDesktopCommand/c\DefaultDesktopCommand "xset s off && /usr/bin/startxfce4"' /usr/NX/etc/node.cfg

## Install 1password
RUN bash /backuponepass/config/install_1password.sh

## Configure ssh
RUN mkdir /var/run/sshd &&  \
    echo 'root:THEPASSWORDYOUCREATED' | chpasswd && \
    sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

EXPOSE 22 4000

ENTRYPOINT ["/backuponepass/config/entrypoint.sh"]
