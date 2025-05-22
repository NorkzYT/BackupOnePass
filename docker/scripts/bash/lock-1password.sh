#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

log() { echo "[$(date +'%T')] $*"; }
sn() { sleep "${1:-1}"; }

main() {
    log "=== Locking 1Password ==="
    sn 2
    log "Issuing lock shortcut (Ctrl+Shift+L)"
    xdotool key Ctrl+Shift+l
    sn 2
    log "✅ 1Password should now be locked"
}

main
