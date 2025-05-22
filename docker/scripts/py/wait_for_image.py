#!/usr/bin/env python3
import sys
import time
from image_utils import match_template

# ── Configuration ───────────────────────────────────────────────────────────
if len(sys.argv) != 2:
    print("Usage: wait_for_image.py <template.png>", file=sys.stderr)
    sys.exit(1)

TEMPLATE = sys.argv[1]
THRESHOLD = 0.2
TIMEOUT = 10.0  # seconds
INTERVAL = 0.1  # polling interval

start = time.time()
while time.time() - start < TIMEOUT:
    if match_template(TEMPLATE, THRESHOLD):
        sys.exit(0)
    time.sleep(INTERVAL)

print(f"ERROR: timeout ({TIMEOUT}s) waiting for template {TEMPLATE}", file=sys.stderr)
sys.exit(1)
