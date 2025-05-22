#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly TEMPLATE="/backuponepass/images/backuponepass_export_in_menu_bar.png"
readonly TIMEOUT=10
readonly THRESHOLD=0.8

log() { echo "[$(date +'%T')] $*"; }
sn() { sleep "${1:-1}"; }

main() {
    log "=== Opening Export Menu ==="

    # 1) Focus 1Password window
    local win
    win=$(xdotool search --onlyvisible --class 1password | head -1)
    log "Focusing window (ID: $win)"
    xdotool windowactivate --sync "$win"
    sn

    # 2) Open menubar
    log "Pressing Alt to open menubar"
    xdotool key Alt_L
    sn

    # 3) Wait for “Export…” item
    log "Waiting up to ${TIMEOUT}s for Export menu item"
    backuponepass-cli monitor \
        --template "${TEMPLATE}" \
        --timeout "${TIMEOUT}" \
        --threshold "${THRESHOLD}"

    # 4) Click the Export item
    log "Clicking Export menu item"
    backuponepass-cli click \
        --template "${TEMPLATE}" \
        --threshold "${THRESHOLD}"
    sn

    # 5) Confirm dialog
    log "Confirming export dialog"
    xdotool key Return
    xdotool key Return

    log "=== Export menu opened ==="
}

main
