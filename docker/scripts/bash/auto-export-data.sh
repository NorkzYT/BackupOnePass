#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ── Configuration ───────────────────────────────────────────────────────────
readonly PY_SCRIPTS="/backuponepass/scripts/py"
readonly SAVE_DIR="/backuponepass/data"

# ── Helpers ─────────────────────────────────────────────────────────────────
log() { echo "[$(date +'%T')] $*"; }
sn() { sleep "${1:-1}"; } # default 1s pause

type_password() {
    log "Typing master password"
    xdotool type "$ONEPASSWORD_PASSWORD"
}

navigate_export_dialog() {
    log "Navigating to 'Export Data' button"
    for _ in {1..3}; do
        xdotool key Tab
        sn
    done
    log "Initiating export"
    xdotool key Return
    sn
}

set_save_location() {
    log "Setting save location to ${SAVE_DIR}"
    xdotool key Ctrl+l
    sn
    xdotool type "${SAVE_DIR}"
    sn
    xdotool key Return
    sn
}

wait_for_export_complete() {
    log "Waiting for export to finish"
    if python3 "${PY_SCRIPTS}/monitor_export_complete_image.py"; then
        log "Export completion detected"
    else
        log "ERROR: export completion not detected" >&2
        exit 1
    fi
}

main() {
    log "=== auto-export-data start ==="
    sn

    type_password
    navigate_export_dialog
    set_save_location
    wait_for_export_complete

    log "Confirming and closing dialog"
    xdotool key Return

    log "=== auto-export-data done ==="
}

main
