import cv2
import numpy as np

# Load the full screenshot and the template
full_screen_image = cv2.imread('full_screenshot.png', 0)
template = cv2.imread('button_template.png', 0)
w, h = template.shape[::-1]

# Perform template matching
res = cv2.matchTemplate(full_screen_image, template, cv2.TM_CCOEFF_NORMED)

# Set a threshold
threshold = 0.8
loc = np.where(res >= threshold)

# If the template is found in the screenshot
for pt in zip(*loc[::-1]):
    # Draw a rectangle around the matched region
    cv2.rectangle(full_screen_image, pt, (pt[0] + w, pt[1] + h), (0,0,255), 2)

# Save the result as a new image
cv2.imwrite('images/result_image.png', full_screen_image)
