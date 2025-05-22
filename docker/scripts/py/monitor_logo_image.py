#!/usr/bin/env python3
import sys, time
from image_utils import match_template, DEFAULT_THRESHOLD

# ── Configuration ───────────────────────────────────────────────────────────
TEMPLATE = "/backuponepass/images/backuponepass_logo.png"
THRESHOLD = 0.6
TIMEOUT = 240
INTERVAL = 1


def main():
    start = time.time()
    while time.time() - start < TIMEOUT:
        if match_template(TEMPLATE, THRESHOLD):
            print("1Password logo detected.")
            sys.exit(0)
        time.sleep(INTERVAL)

    print("ERROR: timeout waiting for logo.", file=sys.stderr)
    sys.exit(1)


if __name__ == "__main__":
    main()
