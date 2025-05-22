#!/usr/bin/env python3
import sys
import time
import subprocess
from image_utils import match_template

# ── Configuration ───────────────────────────────────────────────────────────
# template paths and whether to double-click
STEPS = [
    ("/backuponepass/images/slash_folder_template.png", False),
    ("/backuponepass/images/backuponepass_folder_template.png", True),
    ("/backuponepass/images/backuponepass_data_folder_template.png", True),
    ("/backuponepass/images/save_button_template.png", False),
]
PAUSE_SECONDS = 4
THRESHOLD = 0.8


def log(msg: str):
    print(f"[{time.strftime('%H:%M:%S')}] {msg}", flush=True)


def click_at(x: int, y: int, double: bool):
    subprocess.run(["xdotool", "mousemove", str(x), str(y)], check=True)
    clicks = 2 if double else 1
    for _ in range(clicks):
        subprocess.run(["xdotool", "click", "1"], check=True)
        time.sleep(0.1)


def main():
    log("Waiting for UI to settle…")
    time.sleep(PAUSE_SECONDS)

    for tpl_path, double in STEPS:
        log(f"Searching for template: {tpl_path}")
        coord = match_template(tpl_path, threshold=THRESHOLD, return_coord=True)
        if coord is None:
            log(f"ERROR: template not found: {tpl_path}")
            sys.exit(1)
        x, y = coord
        log(f"Clicking {'double' if double else 'single'} at ({x},{y})")
        click_at(x, y, double)
        time.sleep(PAUSE_SECONDS)

    log("✅ Auto-export-location process completed.")
    sys.exit(0)


if __name__ == "__main__":
    main()
