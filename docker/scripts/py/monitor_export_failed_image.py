#!/usr/bin/env python3
import sys, time
from image_utils import match_template

# — Configuration —
TEMPLATE = "/backuponepass/images/backuponepass_export_failed_text.png"
THRESHOLD = 0.8  # tune this to your exact crop
TIMEOUT = 30  # give the dialog a few seconds to appear
INTERVAL = 0.5

start = time.time()
while time.time() - start < TIMEOUT:
    if match_template(TEMPLATE, THRESHOLD):
        print("Export-failed prompt detected.")
        sys.exit(0)
    time.sleep(INTERVAL)

# no failure dialog within timeout → return non-zero
sys.exit(1)
