#!/usr/bin/env python3

import sys, time
import cv2
import numpy as np
from PIL import ImageGrab

if len(sys.argv) != 2:
    print("Usage: find_template_xy.py <template.png>", file=sys.stderr)
    sys.exit(1)

tpl_path = sys.argv[1]
tpl = cv2.imread(tpl_path, 0)
if tpl is None:
    print(f"ERROR: cannot load template {tpl_path}", file=sys.stderr)
    sys.exit(2)
w, h = tpl.shape[::-1]

# snapshot & match
img = cv2.cvtColor(np.array(ImageGrab.grab()), cv2.COLOR_BGR2GRAY)
res = cv2.matchTemplate(img, tpl, cv2.TM_CCOEFF_NORMED)
_, max_val, _, max_loc = cv2.minMaxLoc(res)

if max_val < 0.8:
    # no good match
    sys.exit(3)

# center of the best‐match box
x = max_loc[0] + w // 2
y = max_loc[1] + h // 2
print(x, y)
sys.exit(0)
