#!/usr/bin/env python3
import sys, time
from image_utils import match_template, DEFAULT_THRESHOLD

# ── Configuration ───────────────────────────────────────────────────────────
TEMPLATE = "/backuponepass/images/backuponepass_2fa_text.png"
THRESHOLD = 0.2
TIMEOUT = 30  # seconds (instead of 240)
INTERVAL = 1  # polling interval


def main():
    start = time.time()
    while time.time() - start < TIMEOUT:
        if match_template(TEMPLATE, THRESHOLD):
            print("2FA prompt detected.")
            sys.exit(0)
        time.sleep(INTERVAL)

    # timeout reached without detection → warn but proceed
    print("WARNING: timeout waiting for 2FA prompt; proceeding anyway", file=sys.stderr)
    sys.exit(0)


if __name__ == "__main__":
    main()
