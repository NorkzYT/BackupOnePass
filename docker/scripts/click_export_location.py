import cv2
import numpy as np
import subprocess
import time
from PIL import ImageGrab

def take_screenshot():
    print("Taking a screenshot...")
    screen = np.array(ImageGrab.grab())
    return cv2.cvtColor(screen, cv2.COLOR_BGR2RGB)

def click_location(center_x, center_y, clicks=1):
    print(f"Moving to coordinates: ({center_x}, {center_y})")
    subprocess.call(["xdotool", "mousemove", str(center_x), str(center_y)])
    for _ in range(clicks):
        subprocess.call(["xdotool", "click", "1"])
        time.sleep(0.1)  # slight delay between clicks for double click

def find_button_and_click(template_path, threshold=0.8, double_click=False):
    print(f"Looking for the button using template: {template_path}")
    template = cv2.imread(template_path, 0)
    if template is None:
        print(f"Template image at {template_path} could not be loaded.")
        return False
    w, h = template.shape[::-1]

    screen = take_screenshot()
    screen_gray = cv2.cvtColor(screen, cv2.COLOR_RGB2GRAY)
    res = cv2.matchTemplate(screen_gray, template, cv2.TM_CCOEFF_NORMED)

    if np.any(res >= threshold):
        print("Template matched. Finding the best match.")
        loc = np.nonzero(res >= threshold)
        pt = max(zip(*loc[::-1]), key=lambda pt: res[pt[::-1]])
        center_x, center_y = pt[0] + w // 2, pt[1] + h // 2
        click_location(center_x, center_y, 2 if double_click else 1)
        return True
    else:
        print("No match found for the template.")
        return False

if __name__ == "__main__":
    print("Starting the process to find and click the export location...")

    # Paths to the template images
    slash_folder_template = "/backuponepass/images/slash_folder_template.png"
    backuponepass_folder_template = "/backuponepass/images/backuponepass_folder_template.png"
    backuponepass_data_folder_template = "/backuponepass/images/backuponepass_data_folder_template.png"
    save_button_template = "/backuponepass/images/save_button_template.png"

    time.sleep(4)  # Give the UI some time to be ready

    if not find_button_and_click(slash_folder_template):
        print("Could not click the '/' folder.")
        exit(1)

    time.sleep(4)  # Wait for the navigation

    if not find_button_and_click(backuponepass_folder_template, double_click=True):
        print("Could not double-click the 'backuponepass' folder.")
        exit(1)

    time.sleep(4)  # Wait for the navigation

    if not find_button_and_click(backuponepass_data_folder_template, double_click=True):
        print("Could not double-click the 'backuponepass_data' folder.")
        exit(1)

    time.sleep(4)  # Wait for the navigation

    if not find_button_and_click(save_button_template):
        print("Could not click the 'Save' button.")
        exit(1)

    print("Auto-export-data process completed.")
