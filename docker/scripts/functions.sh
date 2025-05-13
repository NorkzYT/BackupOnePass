#!/bin/bash

# ─── Helpers ────────────────────────────────────────────────────────────────

# Generate and echo a TOTP code
generate_2fa_code() {
    CODE=$(oathtool --totp -b "$ONEPASSWORD_TOTP_SECRET")
    if [ -z "$CODE" ]; then
        echo "Error: failed to generate 2FA code." >&2
        return 1
    fi
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
    echo "Entering 2FA code…"
    xdotool type "$CODE"
    sleep 0.5
    echo "Submitting…"
    xdotool key Tab
    sleep 0.5
    xdotool key Return
    sleep 1
    xdotool key Return
    echo "✅ 2FA default flow complete."
}

# “Method option” entry: Tab → type → Tab+Return twice
enter_2fa_method_option() {
    local CODE=$1
    echo "Using auth-method option…"
    xdotool key Tab
    sleep 0.5
    echo "Typing code…"
    xdotool type "$CODE"
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
    python3 /backuponepass/scripts/monitor_2fa_image.py ||
        {
            echo "2FA prompt not found."
            return 1
        }

    echo "Monitoring for 2FA-method-option prompt…"
    if timeout 5s python3 /backuponepass/scripts/monitor_2fa_authentiation_method_option_image.py; then
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
