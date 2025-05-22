#!/usr/bin/env python3
"""
backuponepass-cli: unified GUI-automation toolkit
Commands:
  monitor   Wait for a template to appear
  locate    Print the center x y of the best match
  click     Move & click at the template center
"""
import sys
import time
import argparse
import subprocess
from image_utils import match_template, DEFAULT_THRESHOLD, DEFAULT_TIMEOUT


def cmd_monitor(args):
    start = time.time()
    while time.time() - start < args.timeout:
        if match_template(args.template, args.threshold):
            sys.exit(0)
        time.sleep(0.5)
    print(f"ERROR: timeout after {args.timeout}s", file=sys.stderr)
    sys.exit(1)


def cmd_locate(args):
    coord = match_template(args.template, args.threshold, return_coord=True)
    if coord:
        print(f"{coord[0]} {coord[1]}")
        sys.exit(0)
    else:
        sys.exit(2)


def cmd_click(args):
    coord = match_template(args.template, args.threshold, return_coord=True)
    if coord is None:
        print("ERROR: template not found", file=sys.stderr)
        sys.exit(1)
    x, y = coord
    # move & click
    subprocess.run(["xdotool", "mousemove", str(x), str(y)], check=True)
    clicks = 2 if args.double else 1
    for _ in range(clicks):
        subprocess.run(["xdotool", "click", "1"], check=True)
    sys.exit(0)


def main():
    p = argparse.ArgumentParser(prog="backuponepass-cli")
    subs = p.add_subparsers(dest="cmd", required=True)

    m = subs.add_parser("monitor", help="wait for template")
    m.add_argument("--template", required=True, help="path to PNG")
    m.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    m.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT)
    m.set_defaults(func=cmd_monitor)

    l = subs.add_parser("locate", help="print x y of template center")
    l.add_argument("--template", required=True, help="path to PNG")
    l.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    l.set_defaults(func=cmd_locate)

    c = subs.add_parser("click", help="move & click template")
    c.add_argument("--template", required=True, help="path to PNG")
    c.add_argument("--threshold", type=float, default=DEFAULT_THRESHOLD)
    c.add_argument("--double", action="store_true", help="double-click")
    c.set_defaults(func=cmd_click)

    args = p.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
