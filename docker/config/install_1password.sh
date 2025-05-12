#!/bin/bash

#############################
# 1Password Installer Script
#############################

# ──────────────────────────────────────────────────────────────────────────────
# Constants: update here for new releases
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=$(jq -r '.version' "${SCRIPT_DIR}/version.json")
RELEASE_DATE=$(jq -r '.release_date' "${SCRIPT_DIR}/version.json")
BASE_URL="https://downloads.1password.com/linux/tar/stable"
INSTALL_DIR="/opt/1Password"
# ──────────────────────────────────────────────────────────────────────────────

echo "Installing 1Password v${VERSION} (released on ${RELEASE_DATE})..."

# 1) Detect architecture & set URL path + filename suffix
ARCH=$(dpkg --print-architecture)
case "$ARCH" in
amd64)
    PLATFORM="x86_64"
    SUFFIX="x64"
    ;;
arm64)
    PLATFORM="aarch64"
    SUFFIX="arm64"
    ;;
*)
    echo "Error: Unsupported architecture '$ARCH'." >&2
    exit 1
    ;;
esac

# 2) Build URL & filename
FILE="1password-${VERSION}.${SUFFIX}.tar.gz"
DOWNLOAD_URL="${BASE_URL}/${PLATFORM}/${FILE}"

# 3) Download
echo "Downloading ${DOWNLOAD_URL}…"
curl -fSL --retry 3 --retry-delay 5 -o "${FILE}" "${DOWNLOAD_URL}"

# 4) Extract into temp dir
TMPDIR=$(mktemp -d)
echo "Extracting ${FILE} into ${TMPDIR}…"
tar -xf "${FILE}" -C "${TMPDIR}"

# 5) Prepare a fresh install dir
echo "Preparing ${INSTALL_DIR}…"
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"

# 6) Move the real payload (find its root under TMPDIR)
EXTRACTED_ROOT=$(find "${TMPDIR}" -mindepth 1 -maxdepth 1 -type d | head -n1)
echo "Moving files from ${EXTRACTED_ROOT} to ${INSTALL_DIR}…"
mv "${EXTRACTED_ROOT}"/* "${INSTALL_DIR}"

# 7) Cleanup temp + archive
rm -rf "${TMPDIR}" "${FILE}"

# 8) Run post-install hook
echo "Running post-install script…"
/opt/1Password/after-install.sh

echo "✅ 1Password v${VERSION} installed successfully in ${INSTALL_DIR}."
