#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# — Configuration —
readonly BASH_SCRIPTS="/backuponepass/scripts/bash"
readonly PY_SCRIPTS="/backuponepass/scripts/py"
readonly SAVE_DIR="/backuponepass/data"

# — Helpers —
log() { echo "[$(date +'%T')] $*"; }
sn() { sleep "${1:-1}"; }

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

main() {
    log "=== auto-export-data start ==="
    sn

    type_password
    navigate_export_dialog
    set_save_location

    # — loop until we see either the success or failure dialog —
    until python3 "${PY_SCRIPTS}/monitor_export_complete_image.py"; do
        if python3 "${PY_SCRIPTS}/monitor_export_failed_image.py"; then
            log "Export failed detected; clicking OK"
            xdotool key Return # dismiss the failure dialog
            log "Sleeping 120s before retry"
            sleep 120

            log "Re-opening export menu"
            bash "${BASH_SCRIPTS}/open_export.sh"
            log "Re-initiating export"
            navigate_export_dialog
            set_save_location
            continue
        fi

        # neither complete nor failed → something went wrong
        log "ERROR: no export result detected; aborting" >&2
        exit 1
    done

    log "Export completion detected"
    log "Confirming and closing dialog"
    xdotool key Return

    log "=== auto-export-data done ==="
}

main
