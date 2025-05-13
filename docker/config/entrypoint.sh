#!/bin/sh
set -e

# ensure that any files created by child processes get mode 660 (rw-rw----)
umask 0007

# -----------------------------------------------------------------------------
# Environment / constants
# -----------------------------------------------------------------------------
export USER="${USER:-onepassword}"
export HOME="/home/${USER}"
export DISPLAY=${DISPLAY:-:99}
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket
export XDG_RUNTIME_DIR="/tmp/runtime-${USER}"

# Create runtime dir for 1Password’s IPC
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# -----------------------------------------------------------------------------
# Create helper user (but we will **not** switch to it)
# -----------------------------------------------------------------------------
groupadd -o -g "1000" "${USER}" 2>/dev/null || true
useradd -o -u "1000" -g "1000" -M -s /bin/bash "${USER}" 2>/dev/null || true

# make sure the expected paths exist
mkdir -p /backuponepass /backuponepass/{config,scripts,images}
mkdir -p "${HOME}/.config/1Password/logs"
chown -R "${USER}:${USER}" /backuponepass "${HOME}"

# -----------------------------------------------------------------------------
# System time sync (root only)
# -----------------------------------------------------------------------------
apt-get update && apt-get install -y ntpdate
ntpdate -s time.nist.gov || true

# -----------------------------------------------------------------------------
# DBus (host socket is bind‑mounted)
# -----------------------------------------------------------------------------
[ -S /host/run/dbus/system_bus_socket ] || {
  echo "DBus socket missing"
  exit 1
}
/etc/init.d/dbus start

# -----------------------------------------------------------------------------
# Xvfb headless display
# -----------------------------------------------------------------------------
if ! pgrep -x Xvfb >/dev/null 2>&1; then
  echo "Starting Xvfb on ${DISPLAY}"
  Xvfb "${DISPLAY}" -screen 0 1920x1080x24 &
  sleep 2
fi

# Start a minimal window manager so focus/activate actually work
echo "Starting Openbox window manager…"
openbox &
sleep 1

# -----------------------------------------------------------------------------
# VNC + noVNC (root)
# -----------------------------------------------------------------------------
[ -z "${VNC_PASSWORD}" ] && {
  echo "VNC_PASSWORD not set"
  exit 1
}

x11vnc -storepasswd "${VNC_PASSWORD}" /tmp/vnc_pass
x11vnc -display "${DISPLAY}" \
  -rfbport 5900 -rfbauth /tmp/vnc_pass \
  -listen 0.0.0.0 -xkb -forever -bg

if ! lsof -Pi :6080 -sTCP:LISTEN -t >/dev/null 2>&1; then
  websockify --web=/usr/share/novnc 6080 localhost:5900 &
fi

# -----------------------------------------------------------------------------
# Export all env vars for cron (properly quoted)
# -----------------------------------------------------------------------------
printenv | grep -vE "^(UID|GID|no_proxy)" |
  while IFS='=' read -r k v; do
    printf "export %s='%s'\n" "$k" "$(printf '%s' "$v" | sed "s/'/'\\\\''/g")"
  done >/etc/profile.d/env_vars.sh
echo "export DISPLAY=${DISPLAY}" >>/etc/profile.d/env_vars.sh

# -----------------------------------------------------------------------------
# Redirect cron log
# -----------------------------------------------------------------------------
CRON_LOG=/var/log/cron.log
touch "${CRON_LOG}" && chmod 0644 "${CRON_LOG}"

# -----------------------------------------------------------------------------
# 1Password bootstrap (runs as **root**, still launches GUI with --no‑sandbox)
# -----------------------------------------------------------------------------
bash /backuponepass/1password_start.sh

# DEBUG option
if [ "${DEBUG_MODE}" = "true" ]; then
  echo "DEBUG_MODE: running automation once."
  bash /backuponepass/1password_cron.sh
fi

# -----------------------------------------------------------------------------
# Cron schedule (also as root)
# -----------------------------------------------------------------------------
if [ -n "${BACKUP_SCHEDULE}" ]; then
  if echo "${BACKUP_SCHEDULE}" | grep -Eq '^\*/[2-9]|^[2-9]|[1-5][0-9]'; then
    echo "Using BACKUP_SCHEDULE: ${BACKUP_SCHEDULE}"
    echo "${BACKUP_SCHEDULE} . /etc/profile.d/env_vars.sh && /bin/bash /backuponepass/1password_cron.sh >>${CRON_LOG} 2>&1" \
      >/etc/cron.d/backup_schedule
    chmod 0644 /etc/cron.d/backup_schedule
    crontab /etc/cron.d/backup_schedule
    service cron start
  else
    echo "ERROR: BACKUP_SCHEDULE cannot be less frequent than every 2 minutes."
    exit 1
  fi
fi

# -----------------------------------------------------------------------------
# Keep the container alive
# -----------------------------------------------------------------------------
exec tail -n+0 -F "${CRON_LOG}"
