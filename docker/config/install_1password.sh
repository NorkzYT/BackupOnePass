#!/bin/bash

# Detect architecture and download the appropriate version of 1Password
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then
    curl -sSO https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz
elif [ "$ARCH" = "arm64" ]; then
    curl -sSO https://downloads.1password.com/linux/tar/stable/aarch64/1password-latest.tar.gz
else
    echo "Unsupported architecture"
    exit 1
fi

# Extract and move the files
tar -xf 1password-latest.tar.gz
mkdir -p /opt/1Password
mv 1password-*/* /opt/1Password
/opt/1Password/after-install.sh
rm 1password-latest.tar.gz
