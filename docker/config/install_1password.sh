#!/bin/sh

#############################
# 1Password Installer Script
#############################

# ──────────────────────────────────────────────────────────────────────────────
# Constants: update here for new releases
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION=$(jq -r '.version' "${SCRIPT_DIR}/docker/config/version.json")
RELEASE_DATE=$(jq -r '.release_date' "${SCRIPT_DIR}/version.json")
BASE_URL="https://downloads.1password.com/linux/tar/stable"
INSTALL_DIR="/opt/1Password"
# ──────────────────────────────────────────────────────────────────────────────

echo "Installing 1Password v${VERSION} (released on ${RELEASE_DATE})..."

# Detect architecture
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
amd64)
    PLATFORM="x86_64"
    ;;
arm64)
    PLATFORM="aarch64"
    ;;
*)
    echo "Error: Unsupported architecture '$ARCH'." >&2
    exit 1
    ;;
esac

# Compose download filename and URL
FILE="1password-${VERSION}.${ARCH}.tar.gz"
DOWNLOAD_URL="${BASE_URL}/${PLATFORM}/${FILE}"

echo "Downloading ${DOWNLOAD_URL}..."
curl -fSL --retry 3 --retry-delay 5 -o "${FILE}" "${DOWNLOAD_URL}"

echo "Extracting ${FILE}..."
tar -xf "${FILE}"

echo "Installing to ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}"
# Move contents of extracted dir (which is likely named "1password-8.10.75") into install dir
EXTRACTED_DIR=$(tar -tzf "${FILE}" | head -n1 | cut -f1 -d"/")
mv 1password-*/* "${INSTALL_DIR}"

echo "Running post-install script..."
"${INSTALL_DIR}/after-install.sh"

# Clean up
echo "Cleaning up..."
rm -f "${FILE}"

echo "1Password v${VERSION} installed successfully in ${INSTALL_DIR}."
