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


def find_template(template_path, threshold=0.8):
    print(f"Searching for template: {template_path}")
    template = cv2.imread(template_path, 0)
    if template is None:
        print(f"Template image at {template_path} could not be loaded.")
        return False
    # Capture the current screen and convert to grayscale
    screenshot = take_screenshot()
    gray_screen = cv2.cvtColor(screenshot, cv2.COLOR_RGB2GRAY)
    # Perform template matching
    result = cv2.matchTemplate(gray_screen, template, cv2.TM_CCOEFF_NORMED)
    if np.any(result >= threshold):
        print("Template found!")
        return True
    else:
        print("Template not found.")
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
