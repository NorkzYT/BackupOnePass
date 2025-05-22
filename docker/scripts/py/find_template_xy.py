#!/usr/bin/env python3
import sys
from image_utils import match_template


def main():
    if len(sys.argv) != 2:
        print("Usage: find_template_xy.py <template.png>", file=sys.stderr)
        sys.exit(1)

    template = sys.argv[1]
    coord = match_template(template, return_coord=True)

    if coord is None:
        # no match
        sys.exit(2)

    x, y = coord
    print(f"{x} {y}")
    sys.exit(0)


if __name__ == "__main__":
    import sys

    main()
