#!/bin/bash

readonly PY_SCRIPTS="/backuponepass/scripts/py"

# ─── Helpers ────────────────────────────────────────────────────────────────

# Generate and echo a TOTP code
generate_2fa_code() {
    CODE=$(oathtool --totp -b "$ONEPASSWORD_TOTP_SECRET")
    if [ -z "$CODE" ]; then
        echo "Error: failed to generate 2FA code." >&2
        return 1
    fi
    # Debug: print to stderr so you can confirm
    echo "Generated 2FA code: $CODE" >&2
    echo "$CODE"
}

# Focus & raise the 1Password main window
activate_1password_window() {
    ID=$(xdotool search --onlyvisible --name "1Password" | head -1)
    if [ -z "$ID" ]; then
        echo "Error: 1Password window not found." >&2
        xdotool search --onlyvisible --name ".*" getwindowname
        return 1
    fi
    echo "Focusing 1Password window (ID: $ID)…"
    xdotool windowfocus "$ID"
    xdotool windowraise "$ID"
    sleep 0.5
}

# Default entry: type code + Tab+Return twice
enter_2fa_default() {
    local CODE=$1
    echo "Using default 2FA entry…"
    # ensure focus on the code field
    xdotool key Tab
    sleep 0.2

    echo "Typing code: $CODE"
    xdotool type "$CODE" || {
        echo "Error: xdotool type failed" >&2
        return 1
    }

    sleep 0.5
    echo "Submitting default flow…"
    xdotool key Tab
    sleep 0.5
    xdotool key Return
    sleep 1
    xdotool key Return

    echo "✅ 2FA default flow complete."
}

# “Method option” entry: Tab → Tab → type → Tab+Return twice
enter_2fa_method_option() {
    local CODE=$1
    echo "Using auth-method option…"
    # make sure the code-entry field is focused
    xdotool key Tab
    sleep 0.2
    xdotool key Tab
    sleep 0.2

    echo "Typing code: $CODE"
    xdotool type "$CODE" || {
        echo "Error: xdotool type failed" >&2
        return 1
    }

    sleep 0.5
    echo "Submitting option flow…"
    xdotool key Tab
    sleep 0.5
    xdotool key Return
    sleep 1
    xdotool key Return

    echo "✅ 2FA option flow complete."
}

# ─── Orchestrator ──────────────────────────────────────────────────────────

handle_2fa() {
    echo "Monitoring for 2FA prompt…"
    if ! python3 "${PY_SCRIPTS}/monitor_2fa_image.py"; then
        echo "No 2FA prompt detected" >&2
        return 1
    fi

    echo "Monitoring for 2FA-method-option prompt…"
    if timeout 5s python3 "${PY_SCRIPTS}/monitor_2fa_authentiation_method_option_image.py"; then
        METHOD_OK=0
    else
        METHOD_OK=1
    fi

    echo "Generating 2FA code…"
    CODE=$(generate_2fa_code) || return 1

    activate_1password_window || return 1

    if [ $METHOD_OK -eq 0 ]; then
        enter_2fa_method_option "$CODE"
    else
        enter_2fa_default "$CODE"
    fi

    return 0
}
