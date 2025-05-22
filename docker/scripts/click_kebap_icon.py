import cv2
import numpy as np
import subprocess
import time
from PIL import ImageGrab

KEBAP_ICON_TEMPLATE_PATH = "/backuponepass/images/button_template_white.png"


def take_screenshot():
    print("Taking a screenshot...")
    # On headless servers, you may need to use a different method to capture the screen
    screen = np.array(ImageGrab.grab())
    return cv2.cvtColor(screen, cv2.COLOR_BGR2RGB)


def activate_window(name="1Password"):
    # find the first visible window whose title contains “1Password”
    win = (
        subprocess.check_output(["xdotool", "search", "--onlyvisible", "--name", name])
        .splitlines()[0]
        .strip()
    )
    subprocess.call(["xdotool", "windowactivate", win])
    # give it a moment
    time.sleep(0.2)


def click_location(center_x, center_y):
    print(f"Moving to coordinates: ({center_x}, {center_y})")
    subprocess.call(["xdotool", "mousemove", str(center_x), str(center_y)])
    print("Pressing mouse down…")
    subprocess.call(["xdotool", "mousedown", "1"])
    time.sleep(0.05)
    print("Releasing mouse…")
    subprocess.call(["xdotool", "mouseup", "1"])


def find_button_and_click(template_path):
    print(f"Attempting to find button using template: {template_path}")
    # Read the template
    template = cv2.imread(template_path, 0)
    if template is None:
        print(f"Template image at {template_path} could not be loaded.")
        return None
    w, h = template.shape[::-1]

    # Take a screenshot
    screen = take_screenshot()
    screen_gray = cv2.cvtColor(screen, cv2.COLOR_RGB2GRAY)

    # Match the template
    res = cv2.matchTemplate(screen_gray, template, cv2.TM_CCOEFF_NORMED)
    threshold = 0.8
    loc = np.nonzero(res >= threshold)

    if np.any(res >= threshold):
        print("Template matched. Finding the best match.")
    else:
        print("No match found for the template.")

    # Return the first matching location
    for pt in zip(*loc[::-1]):
        center_x = pt[0] + w // 2
        center_y = pt[1] + h // 2
        print(f"Button found at ({center_x}, {center_y}).")
        return center_x, center_y

    print("Button not found.")
    return None


if __name__ == "__main__":
    print("Starting the process to find and click the kebap icon...")

    time.sleep(4)  # let the UI settle
    activate_window("1Password")

    print("Looking for the kebap icon…")
    coords = find_button_and_click(KEBAP_ICON_TEMPLATE_PATH)
    if not coords:
        print("❌ could not find the icon; exiting.")
        sys.exit(1)

    x, y = coords
    print(f"✅ found at {x},{y}; clicking…")
    time.sleep(0.2)
    click_location(x, y)
    time.sleep(0.5)
    print("✔️ done.")
