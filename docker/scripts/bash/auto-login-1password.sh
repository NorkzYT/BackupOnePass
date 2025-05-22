#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPTS_DIR="/backuponepass/scripts/bash"
source "${SCRIPTS_DIR}/functions.sh"

log() { echo "[$(date +'%T')] $*"; }
sn() { sleep "${1:-1}"; } # default 1s pause

# ── First-time sign-in flow ───────────────────────────────────────────────
first_startup() {
    log "First-time setup: filling credentials"
    sn

    log "→ Open 'Sign In' dialog"
    xdotool key Tab && xdotool key Return
    sn 2

    log "→ Entering email address"
    xdotool type "$ONEPASSWORD_EMAIL" && sn

    log "→ Skipping ahead to 'Continue'"
    for _ in {1..5}; do xdotool key Tab && sn; done
    xdotool key Return && sn

    log "→ Entering Secret Key"
    xdotool type "$ONEPASSWORD_SECRET_KEY" && sn
    xdotool key Tab && sn
    xdotool key Tab && sn

    log "→ Entering Master Password"
    xdotool type "$ONEPASSWORD_PASSWORD" && sn

    log "→ Submitting credentials"
    # skip emergency kit prompt
    xdotool key Tab && sn
    xdotool key Tab && sn
    xdotool key Tab && sn
    sn
    xdotool key Return

    log "Waiting for MFA prompt…"
    sn 4

    handle_2fa
}

# ── Unlock-lock screen flow ───────────────────────────────────────────────
lock_screen_flow() {
    log "Lock screen detected: entering password"
    xdotool type "$ONEPASSWORD_PASSWORD" && sn
    xdotool key Tab && sn
    xdotool key Tab && xdotool key Return

    log "Waiting for MFA prompt…"
    sn 2

    handle_2fa
}

# ── Entry point ──────────────────────────────────────────────────────────
main() {
    log "=== Starting 1Password auto-login ==="

    # Turn any 'no window found' into a zero exit so pipefail won't kill us
    local first_win lock_win
    first_win=$(
        xdotool search --name "Welcome — 1Password" 2>/dev/null || true |
            head -1
    )
    lock_win=$(
        xdotool search --name "Lock Screen — 1Password" 2>/dev/null || true |
            head -1
    )

    if [ -n "$first_win" ]; then
        first_startup
    elif [ -n "$lock_win" ]; then
        lock_screen_flow
    else
        log "No 1Password window found; exiting."
        exit 1
    fi

    log "=== Auto-login completed ==="
}

main
