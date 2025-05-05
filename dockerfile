# -----------------------------------------------------------------------------
# BackupOnePass – headless 1Password backup container (Ubuntu 22.04 Jammy)
# -----------------------------------------------------------------------------
FROM phusion/baseimage:jammy-1.0.4

LABEL maintainer="NorkzYT <richard@pcscorp.dev>"

# -----------------------------------------------------------------------------
# Global environment
# -----------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    APP_USER=onepassword \
    APP_GROUP=onepassword

# -----------------------------------------------------------------------------
# Create the application user once, at build‑time
# -----------------------------------------------------------------------------
RUN groupadd -g 1000 "${APP_GROUP}" \
    && useradd  -m -u 1000 -g "${APP_GROUP}" -s /bin/bash "${APP_USER}" \
    && passwd   -d "${APP_USER}"

# -----------------------------------------------------------------------------
# Copy project tree and preserve script permissions
# -----------------------------------------------------------------------------
COPY docker/ /backuponepass/
RUN find /backuponepass -type f -name "*.sh" -exec chmod +x {} \; \
    && find /backuponepass -type f -name "*.py" -exec chmod +x {} \;

# -----------------------------------------------------------------------------
# System packages
# -----------------------------------------------------------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        sudo gedit locales curl gnupg2 lsb-release \
        xdotool oathtool xvfb x11-xserver-utils \
        python3-opencv scrot python3-pip dbus-x11 \
        pulseaudio cron x11vnc novnc websockify \
        libgbm1 lsof \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Python packages
# -----------------------------------------------------------------------------
COPY docker/config/requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 install --no-cache-dir -r /tmp/requirements.txt

# -----------------------------------------------------------------------------
# 1Password installation
# -----------------------------------------------------------------------------
RUN /backuponepass/config/install_1password.sh
ENV PATH="/opt/1Password:${PATH}"

# -----------------------------------------------------------------------------
# Prepare HOME
# -----------------------------------------------------------------------------
RUN mkdir -p /home/${APP_USER}/.config \
    && chown -R ${APP_USER}:${APP_GROUP} /home/${APP_USER}

# -----------------------------------------------------------------------------
# VNC / noVNC
# -----------------------------------------------------------------------------
EXPOSE 5900 6080

# -----------------------------------------------------------------------------
# Entrypoint (kept as root – switches user internally)
# -----------------------------------------------------------------------------
ENTRYPOINT ["/backuponepass/config/entrypoint.sh"]
