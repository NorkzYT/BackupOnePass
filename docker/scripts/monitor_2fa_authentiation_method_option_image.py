import cv2
import numpy as np
import time
from PIL import ImageGrab
import os
import subprocess

# Directory to save screenshots
SAVE_DIR = '/backuponepass/data'
os.makedirs(SAVE_DIR, exist_ok=True)

# Default Configuration
DEFAULT_THRESHOLD = 0.6
TIMEOUT = 240
RETRY_INTERVAL = 1

def take_screenshot():
    """Captures the current screen."""
    screen = np.array(ImageGrab.grab())
    return cv2.cvtColor(screen, cv2.COLOR_BGR2RGB)

def find_image_on_screen(template_path, threshold=DEFAULT_THRESHOLD):
    """Searches for an image template on the screen."""
    template = cv2.imread(template_path, 0)
    if template is None:
        return False

    # Get template dimensions
    w, h = template.shape[::-1]

    # Capture a screenshot and process it
    screen = take_screenshot()
    screen_gray = cv2.cvtColor(screen, cv2.COLOR_RGB2GRAY)

    # Apply multi-scale template matching
    scales = [0.8]  # Focus on the scale that worked previously
    for scale in scales:
        resized_template = cv2.resize(template, (int(w * scale), int(h * scale)))
        result = cv2.matchTemplate(screen_gray, resized_template, cv2.TM_CCOEFF_NORMED)

        # Check for match above threshold
        loc = np.where(result >= threshold)
        if len(loc[0]) > 0:
            return True

    return False

def wait_for_image(template_path, timeout=TIMEOUT, threshold=DEFAULT_THRESHOLD):
    """Waits until the specified image appears on the screen."""
    start_time = time.time()

    while time.time() - start_time < timeout:
        if find_image_on_screen(template_path, threshold):
            return True
        time.sleep(RETRY_INTERVAL)

    return False

def main():
    template_path = '/backuponepass/images/backuponepass_2fa_authentiation_method_option_text.png'
    if wait_for_image(template_path):
        print("2FA prompt authentication method option detected. Proceeding...")
        exit(0)
    else:
        exit(1)

if __name__ == "__main__":
    main()
