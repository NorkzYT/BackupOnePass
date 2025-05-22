#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

log() { echo "[$(date +'%T')] $*"; }
sn() { sleep "${1:-1}"; }

main() {
    log "=== quit-1password start ==="
    sn
    log "Sending Ctrl+q to quit 1Password"
    xdotool key Ctrl+q
    log "✅ 1Password quit successfully"
}

main
