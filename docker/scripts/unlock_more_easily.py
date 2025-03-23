import cv2
import numpy as np
import subprocess
import time
from PIL import ImageGrab
import sys


def take_screenshot():
    print("Taking a screenshot...")
    screen = np.array(ImageGrab.grab())
    return cv2.cvtColor(screen, cv2.COLOR_BGR2RGB)


def find_template(template_path, threshold=0.7):
    print(f"Searching for template: {template_path}")
    template = cv2.imread(template_path, 0)
    if template is None:
        print(f"Template image at {template_path} could not be loaded.")
        return False

    screenshot = take_screenshot()
    gray_screen = cv2.cvtColor(screenshot, cv2.COLOR_RGB2GRAY)

    # Try multiple scales
    scales = [0.9, 1.0, 1.1]
    for scale in scales:
        new_w = int(template.shape[1] * scale)
        new_h = int(template.shape[0] * scale)
        resized_template = cv2.resize(template, (new_w, new_h))

        result = cv2.matchTemplate(gray_screen, resized_template, cv2.TM_CCOEFF_NORMED)
        loc = np.where(result >= threshold)

        if len(loc[0]) > 0:
            print("Template found at scale", scale)
            return True

    print("Template not found at any scale.")
    return False


if __name__ == "__main__":
    # Allow a short pause for the UI to settle
    time.sleep(2)
    TEMPLATE_PATH = "/backuponepass/images/unlock-more-easily-text.png"
    if find_template(TEMPLATE_PATH):
        print("Unlock prompt detected. Sending key events...")
        subprocess.call(["xdotool", "key", "Tab"])
        time.sleep(0.5)
        subprocess.call(["xdotool", "key", "Tab"])
        time.sleep(0.5)
        subprocess.call(["xdotool", "key", "Return"])
    else:
        print("Unlock prompt not detected. Exiting.")
        sys.exit(0)
