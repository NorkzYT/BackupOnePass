#!/usr/bin/env python3
import cv2, sys, time
import numpy as np
from PIL import ImageGrab

if len(sys.argv) != 2:
    print("Usage: wait_for_image.py <template.png>", file=sys.stderr)
    sys.exit(1)

template_path = sys.argv[1]
threshold = 0.8
timeout = 10.0  # seconds
interval = 0.1  # polling interval

tpl = cv2.imread(template_path, 0)
if tpl is None:
    print(f"ERROR: could not load template '{template_path}'", file=sys.stderr)
    sys.exit(2)
w, h = tpl.shape[::-1]

start = time.time()
while True:
    img = cv2.cvtColor(np.array(ImageGrab.grab()), cv2.COLOR_BGR2GRAY)
    res = cv2.matchTemplate(img, tpl, cv2.TM_CCOEFF_NORMED)
    if (res >= threshold).any():
        sys.exit(0)
    if time.time() - start > timeout:
        print("ERROR: timeout waiting for template", file=sys.stderr)
        sys.exit(3)
    time.sleep(interval)
