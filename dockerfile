FROM ubuntu:20.04

LABEL maintainer="NorkzYT richard@pcscorp.dev"

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=ubuntu \
    PASSWORD=ubuntu \
    UID=1000 \
    GID=1000

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV VGL_DISPLAY=egl

# Create folder
RUN mkdir -p /backuponepass

# Copy env file
COPY .env /backuponepass

## Copy config folder 
COPY docker/config /backuponepass/config

# Copy scripts folder 
COPY docker/scripts /backuponepass/scripts

# Copy images folder 
COPY docker/images /backuponepass/images

# Ensure scripts in config have execute permissions
RUN chmod +x /backuponepass/config/*.sh && \
    chmod +x /backuponepass/scripts/*.sh

## Install and Configure OpenGL
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libxau6 libxdmcp6 libxcb1 libxext6 libx11-6 \
    libglvnd0 libgl1 libglx0 libegl1 libgles2 \
    libglvnd-dev libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/share/glvnd/egl_vendor.d/ && \
    echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
    \"library_path\": \"libEGL_nvidia.so.0\"\n\
    }\n\
    }" > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

## Install and Configure for Vulkan
RUN apt-get update && \
    apt-get install -y --no-install-recommends vulkan-tools && \
    rm -rf /var/lib/apt/lists/* && \
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)') && \
    mkdir -p /etc/vulkan/icd.d/ && \
    echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
    \"library_path\": \"libGLX_nvidia.so.0\",\n\
    \"api_version\" : \"${VULKAN_API_VERSION}\"\n\
    }\n\
    }" > /etc/vulkan/icd.d/nvidia_icd.json

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
    # add apt repo for firefox
    add-apt-repository -y ppa:mozillateam/ppa &&\
    mkdir -p /etc/apt/preferences.d &&\
    echo "Package: firefox*\n\
    Pin: release o=LP-PPA-mozillateam\n\
    Pin-Priority: 1001" > /etc/apt/preferences.d/mozilla-firefox &&\
    # install xfce4 and firefox
    apt-get install -y xfce4 terminator fonts-wqy-zenhei ffmpeg firefox &&\
    # set firefox as default web browser
    update-alternatives --set x-www-browser /usr/bin/firefox &&\
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
