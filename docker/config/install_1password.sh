#!/bin/bash

# Specific download of 1Password version links:
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/misc/1password-gui/sources.json
# https://releases.1password.com/linux/beta/

# Detect architecture and download the appropriate version of 1Password (Stable)
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    FILE="1password-8.10.70.x64.tar.gz"
    curl -sSO https://downloads.1password.com/linux/tar/stable/x86_64/$FILE
elif [ "$ARCH" = "arm64" ]; then
    FILE="1password-8.10.70.arm64.tar.gz"
    curl -sSO https://downloads.1password.com/linux/tar/stable/aarch64/$FILE
else
    echo "Unsupported architecture"
    exit 1
fi

# Extract and move the files
tar -xf "$FILE"
mkdir -p /opt/1Password
mv 1password-*/* /opt/1Password
/opt/1Password/after-install.sh
rm "$FILE"

# April 2 2025
# 1Password version 8.10.70 (Supported)
