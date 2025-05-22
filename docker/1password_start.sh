#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ── Constants ─────────────────────────────────────────────────────────
readonly DISPLAY_NUM="${DISPLAY:-:99}"
readonly XVFB_SCREEN="1920x1080x24"
readonly LOG_DIR="$HOME/.config/1Password/logs"
readonly LOG_FILE="${LOG_DIR}/1Password_rCURRENT.log"

# ── Helpers ────────────────────────────────────────────────────────────
ensure_dbus() {
    if ! pgrep -x dbus-daemon &>/dev/null; then
        echo "Starting D-Bus…"
        dbus-daemon --system --fork
    fi
}

ensure_log_dir() {
    mkdir -p "${LOG_DIR}"
    touch "${LOG_FILE}"
}

ensure_display() {
    if [ -z "${DISPLAY:-}" ]; then
        export DISPLAY="${DISPLAY_NUM}"
        echo "DISPLAY set to ${DISPLAY}"
    fi
}

ensure_xvfb() {
    if ! pgrep -x Xvfb &>/dev/null; then
        echo "Starting Xvfb on ${DISPLAY}…"
        Xvfb "${DISPLAY}" -screen 0 "${XVFB_SCREEN}" &
        sleep 2
    fi
}

launch_1password() {
    if pgrep -x 1password &>/dev/null; then
        echo "1Password already running; skipping launch."
        return
    fi

    echo "Launching 1Password (no sandbox)…"
    su "$USER" -c '1password --no-sandbox &'
    sleep 5

    echo "Waiting for logo…"
    if ! python3 /backuponepass/scripts/py/monitor_logo_image.py; then
        echo "ERROR: Logo detection failed." >&2
        exit 1
    fi
}

# ── Main ────────────────────────────────────────────────────────────────
main() {
    echo "=== 1Password headless bootstrap ==="
    ensure_dbus
    ensure_log_dir
    ensure_display
    ensure_xvfb

    echo "Starting automation script…"
    launch_1password

    echo "✅ 1Password launched successfully."
}

main
