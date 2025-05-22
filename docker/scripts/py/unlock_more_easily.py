#!/usr/bin/env python3
import os
import sys
import time
import subprocess

# ensure this script’s directory is on PYTHONPATH
SCRIPT_DIR = os.path.dirname(__file__)
sys.path.insert(0, SCRIPT_DIR)

from image_utils import match_template

# ── Configuration ───────────────────────────────────────────────────────────
PAUSE = 2  # seconds before first capture
TEMPLATE = "/backuponepass/images/unlock-more-easily-text.png"
THRESHOLD = 0.2


def log(msg: str):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def main():
    log("Waiting for UI to settle…")
    time.sleep(PAUSE)

    log(f"Searching for unlock prompt (threshold={THRESHOLD})")
    found = match_template(TEMPLATE, THRESHOLD)

    if found:
        log("Unlock prompt detected; sending Tab → Tab → Return")
        for key in ("Tab", "Tab", "Return"):
            subprocess.run(["xdotool", "key", key], check=True)
            time.sleep(0.5)
    else:
        log("Unlock prompt not detected; exiting.")

    sys.exit(0)


if __name__ == "__main__":
    main()
