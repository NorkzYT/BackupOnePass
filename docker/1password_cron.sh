#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ── Configuration ───────────────────────────────────────────────────────────
readonly BASH_SCRIPTS="/backuponepass/scripts/bash"
readonly PY_SCRIPTS="/backuponepass/scripts/py"
readonly DATA_DIR="/backuponepass/data"
readonly LOG_FILE="$HOME/.config/1Password/logs/1Password_rCURRENT.log"
readonly SYNC_TIMEOUT="${SYNC_TIMEOUT:-60}" # seconds

# ── Helpers ────────────────────────────────────────────────────────────────
log() { echo "[$(date +'%T')] $*"; }

wait_for_sync() {
    log "Waiting for account sync (timeout ${SYNC_TIMEOUT}s)…"
    local elapsed=0
    until grep -q "synced account" "${LOG_FILE}"; do
        ((elapsed++))
        if ((elapsed >= SYNC_TIMEOUT)); then
            log "ERROR: sync did not complete within ${SYNC_TIMEOUT}s" >&2
            exit 1
        fi
        sleep 1
    done
    log "Account sync complete."
}

# ── Main ──────────────────────────────────────────────────────────────────
main() {
    log "=== Cron-triggered backup started ==="

    log "1) Auto-login"
    bash "${BASH_SCRIPTS}/auto-login-1password.sh"

    log "2) Confirm login prompt"
    sleep 1
    xdotool key Return
    sleep 1

    log "3) Handle unlock-more-easily prompt"
    python3 "${PY_SCRIPTS}/unlock_more_easily.py"

    log "4) Wait for account sync"
    wait_for_sync

    log "5) Open export menu"
    bash "${BASH_SCRIPTS}/open_export.sh"

    log "6) Auto-export data"
    bash "${BASH_SCRIPTS}/auto-export-data.sh"

    log "7) Adjust file permissions"
    find "${DATA_DIR}" -type f -exec chmod 660 {} \; || true

    log "8) Lock 1Password"
    bash "${BASH_SCRIPTS}/lock-1password.sh"

    if [ -z "${BACKUP_SCHEDULE:-}" ]; then
        log "No BACKUP_SCHEDULE → quitting 1Password"
        bash "${BASH_SCRIPTS}/quit-1password.sh"
    else
        log "BACKUP_SCHEDULE set → keeping session open"
    fi

    log "=== Cron job completed ==="
}

main
