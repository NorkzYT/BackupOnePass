#!/bin/bash
set -e

# 1) Focus the 1Password window
WIN=$(xdotool search --onlyvisible --class 1password | head -1)
xdotool windowactivate --sync "$WIN"

# 2) “Click” Alt to open the menubar
xdotool key Alt_L

# 3) Wait until the menu bar icon “Export…” is actually visible
until python3 /backuponepass/scripts/wait_for_image.py \
    /backuponepass/images/backuponepass_export_in_menu_bar.png; do
    sleep 0.1
done

# 4) Find its on-screen center and click it
read X Y < <(python3 /backuponepass/scripts/find_template_xy.py \
    /backuponepass/images/backuponepass_export_in_menu_bar.png)
xdotool mousemove --sync "$X" "$Y"
xdotool click 1

# 5) Confirm the dialog open (double-Return used previously)
xdotool key Return
xdotool key Return
