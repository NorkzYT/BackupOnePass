#!/usr/bin/env python3
import sys
import time
from image_utils import match_template

# ── Configuration ───────────────────────────────────────────────────────────
TEMPLATE = "/backuponepass/images/backuponepass_export_finished_text.png"
THRESHOLD = 0.8  # stricter match to avoid false positives
INITIAL_PAUSE_SECONDS = 3.0  # wait for the save-dialog to disappear
TIMEOUT = 300  # seconds (5 min)
INTERVAL = 1.0  # seconds between polls


def main():
    # 1) Give the UI a few seconds to transition from "Save" → main window
    time.sleep(INITIAL_PAUSE_SECONDS)

    start = time.time()
    while True:
        elapsed = time.time() - start
        if elapsed >= TIMEOUT:
            print(
                f"ERROR: timeout ({int(elapsed)}s) waiting for export-finished prompt.",
                file=sys.stderr,
            )
            sys.exit(1)

        # 2) Only succeed if we truly see the “Export Finished” text
        try:
            if match_template(TEMPLATE, THRESHOLD):
                print("Export-finished prompt detected.")
                sys.exit(0)
        except FileNotFoundError as e:
            # Crash immediately if we mis-pointed at the PNG
            print(f"ERROR: {e}", file=sys.stderr)
            sys.exit(1)

        time.sleep(INTERVAL)


if __name__ == "__main__":
    main()
