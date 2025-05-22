import cv2, numpy as np
from PIL import ImageGrab

DEFAULT_THRESHOLD = 0.4
DEFAULT_TIMEOUT = 60  # seconds


def take_screenshot():
    """Returns the current screen as a BGR image."""
    img = np.array(ImageGrab.grab())
    return cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)


def match_template(path, threshold=DEFAULT_THRESHOLD, return_coord=False):
    """
    Match template on screen.
    If return_coord=True, returns center (x,y) of best match or None.
    Else, returns True/False if any match ≥ threshold.
    """
    tpl = cv2.imread(path, 0)
    if tpl is None:
        raise FileNotFoundError(f"Template not found: {path}")
    h, w = tpl.shape
    screen = take_screenshot()
    res = cv2.matchTemplate(screen, tpl, cv2.TM_CCOEFF_NORMED)
    loc = np.where(res >= threshold)
    if loc[0].size == 0:
        return None if return_coord else False
    # pick best match
    minVal, maxVal, minLoc, maxLoc = cv2.minMaxLoc(res)
    cx = maxLoc[0] + w // 2
    cy = maxLoc[1] + h // 2
    return (cx, cy) if return_coord else True
