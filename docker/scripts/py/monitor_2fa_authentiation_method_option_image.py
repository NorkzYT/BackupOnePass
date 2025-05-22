#!/usr/bin/env python3
import sys, time
from image_utils import match_template

# ── Configuration ───────────────────────────────────────────────────────────
TEMPLATE = (
    "/backuponepass/images/backuponepass_2fa_authentiation_method_option_text.png"
)
THRESHOLD = 0.2
TIMEOUT = 240  # seconds
INTERVAL = 1  # polling interval


def main():
    start = time.time()
    while time.time() - start < TIMEOUT:
        if match_template(TEMPLATE, THRESHOLD):
            print("2FA method-option prompt detected.")
            sys.exit(0)
        time.sleep(INTERVAL)

    print("ERROR: timeout waiting for 2FA method-option prompt.", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
