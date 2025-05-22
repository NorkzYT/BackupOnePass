#!/bin/sh
set -e

# ─── Fix Xauthority file so xauth generate won’t fail ─────────────────────
export HOME="/home/${APP_USER}"
mkdir -p "${HOME}"
touch "${HOME}/.Xauthority"
chown "${APP_USER}:${APP_USER}" "${HOME}/.Xauthority"

# ─── Make all new files mode 660 by default ─────────────────────────────────
umask 0007

# ─── Force a headless display on :99 ────────────────────────────────────────
export DISPLAY=":99"

# ─── Ensure the X socket directory exists ──────────────────────────────────
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# ─── Constants & environment ────────────────────────────────────────────────
export APP_USER="${APP_USER:-onepassword}"
export USER="$APP_USER"
export HOME="/home/${USER}"
export DBUS_SYSTEM_BUS_ADDRESS="unix:path=/host/run/dbus/system_bus_socket"
export XDG_RUNTIME_DIR="/tmp/runtime-${USER}"

# ─── Prepare runtime dir for 1Password IPC ─────────────────────────────────
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# ─── Ensure the service user exists ────────────────────────────────────────
groupadd -g 1000 "${APP_USER}" 2>/dev/null || true
useradd -m -u 1000 -g 1000 -s /bin/bash "${APP_USER}" 2>/dev/null || true

# ─── Ensure project folders exist & ownership ──────────────────────────────
mkdir -p /backuponepass/{config,scripts,images,data}
mkdir -p "${HOME}/.config/1Password/logs"
chown -R "${APP_USER}:${APP_USER}" /backuponepass "${HOME}"

# ─── Start DBus (host socket is bind-mounted) ──────────────────────────────
[ -S /host/run/dbus/system_bus_socket ] || {
  echo "DBus socket missing"
  exit 1
}
service dbus start

# ─── Launch Xvfb on :99 (with correct “:99” syntax) ────────────────────────
if ! pgrep -x Xvfb >/dev/null 2>&1; then
  echo "Starting Xvfb on ${DISPLAY}…"
  Xvfb "${DISPLAY}" -screen 0 1920x1080x24 &
  # wait up to 2s for the socket file
  for i in $(seq 1 20); do
    [ -e "/tmp/.X11-unix/X${DISPLAY#:}" ] && break
    sleep 0.1
  done
fi

# ─── Remove any stale X lockfile so Xvfb can start cleanly ───────────────
[ -f "/tmp/.X99-lock" ] && rm -f "/tmp/.X99-lock"

# ─── Generate an Xauthority cookie for the service user ──────────────────
su - "${APP_USER}" -s /bin/sh -c "\
 xauth generate ${DISPLAY} . trusted \
"

# ─── Start a minimal window manager ────────────────────────────────────────
echo "Starting Openbox window manager…"
openbox-session &
sleep 1

# ─── VNC + noVNC setup ─────────────────────────────────────────────────────
[ -z "${VNC_PASSWORD}" ] && {
  echo "VNC_PASSWORD not set"
  exit 1
}

# x11vnc (attach to :99)
x11vnc -storepasswd "${VNC_PASSWORD}" /tmp/vnc_pass
x11vnc -noxdamage -ncache 10 \
  -auth "${HOME}/.Xauthority" \
  -display "${DISPLAY}" \
  -rfbport 5900 -rfbauth /tmp/vnc_pass \
  -listen 0.0.0.0 -xkb -forever -bg

# noVNC
if ! lsof -Pi :6080 -sTCP:LISTEN -t >/dev/null 2>&1; then
  websockify --web=/usr/share/novnc 6080 localhost:5900 &
fi

# ─── Export env for cron jobs ───────────────────────────────────────────────
printenv | grep -vE "^(UID|GID|no_proxy)" |
  while IFS='=' read -r k v; do
    printf "export %s='%s'\n" "$k" \
      "$(printf '%s' "$v" | sed "s/'/'\\\\''/g")"
  done >/etc/profile.d/env_vars.sh
echo "export DISPLAY=${DISPLAY}" >>/etc/profile.d/env_vars.sh

# ─── Cron log file ─────────────────────────────────────────────────────────
CRON_LOG=/var/log/cron.log
touch "${CRON_LOG}" && chmod 0644 "${CRON_LOG}"

# ─── Bootstrap 1Password GUI (as root) ────────────────────────────────────
bash /backuponepass/1password_start.sh

# ─── If DEBUG_MODE, run once immediately ──────────────────────────────────
[ "${DEBUG_MODE}" = "true" ] && bash /backuponepass/1password_cron.sh

# ─── Install cron schedule if BACKUP_SCHEDULE given ─────────────────────────
if [ -n "${BACKUP_SCHEDULE}" ]; then
  if echo "${BACKUP_SCHEDULE}" | grep -Eq '^\*/[2-9]|^[2-9]|[1-5][0-9]'; then
    echo "${BACKUP_SCHEDULE} . /etc/profile.d/env_vars.sh && \
      /bin/bash /backuponepass/1password_cron.sh >>${CRON_LOG} 2>&1" \
      >/etc/cron.d/backup_schedule
    chmod 0644 /etc/cron.d/backup_schedule
    crontab /etc/cron.d/backup_schedule
    service cron start
  else
    echo "ERROR: BACKUP_SCHEDULE cannot be less frequent than every 2 minutes."
    exit 1
  fi
fi

# ─── Finally, keep the container alive by tailing the cron log ─────────────
exec tail -n+0 -F "${CRON_LOG}"
