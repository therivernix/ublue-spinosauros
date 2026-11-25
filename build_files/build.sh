#!/bin/bash

set -ouex pipefail

# ==============================================================================
# 01. Variables
# ==============================================================================

SYSTEM_FILES="/ctx/system_files"
EXTENSIONS_DIR="/usr/share/gnome-shell/extensions"
CODEX_DIR="/usr/share/ublue-os-spinosauros/codex"

CODEX_URL="https://persistent.oaistatic.com/codex-app-prod/linux/rpm/latest/chatgpt.x86_64.rpm"

TAILSCALE_REPO="https://pkgs.tailscale.com/stable/fedora/tailscale.repo"
SCROLL_FACTOR_COPR="daniel-g-carrasco/wayland-scroll-factor"


# ==============================================================================
# 02. Package definitions
# ==============================================================================

# System packages and utilities
SYSTEM_PACKAGES=(
    firefox
    firefox-langpacks
    yelp
    curl
    jq
    unzip
    git
    xdg-terminal-exec
    gum
    dnf5-plugins
)

# Build tools and dependencies
BUILD_PACKAGES=(
    make
    gettext
    meson
    glib2-devel
    sassc
)

# Packages to remove from the final image
REMOVE_PACKAGES=(
    gnome-software
    gnome-extensions-app
    htop
    nvtop
    sassc
)


# ==============================================================================
# 03. System preparation
# ==============================================================================

# Remove Bluefin keybindings if necessary
# rm -f /etc/dconf/db/distro.d/02-bluefin-keybindings

# Remove preinstalled GNOME extensions
rm -rf "${EXTENSIONS_DIR:?}/"*

# Copy custom system files into the image
cp -avf "${SYSTEM_FILES}/." /


# ==============================================================================
# 04. Install system packages
# ==============================================================================

dnf5 install -y \
    "${SYSTEM_PACKAGES[@]}" \
    "${BUILD_PACKAGES[@]}"


# ==============================================================================
# 05. Configure third-party repositories
# ==============================================================================

# Tailscale
dnf5 config-manager addrepo --overwrite \
    --from-repofile="${TAILSCALE_REPO}"

# Wayland Scroll Factor
dnf5 -y copr enable "${SCROLL_FACTOR_COPR}"


# ==============================================================================
# 06. Install third-party packages
# ==============================================================================

dnf5 install -y \
    tailscale \
    wayland-scroll-factor


# ==============================================================================
# 07. Install external applications
# ==============================================================================

# ------------------------------------------------------------------------------
# ChatGPT Desktop / Codex
# ------------------------------------------------------------------------------

mkdir -p "${CODEX_DIR}"

curl -fL --retry 3 \
    -o "${CODEX_DIR}/chatgpt.x86_64.rpm" \
    "${CODEX_URL}"

dnf5 install -y \
    "${CODEX_DIR}/chatgpt.x86_64.rpm"

# Remove the downloaded RPM after installation
rm -f "${CODEX_DIR}/chatgpt.x86_64.rpm"


# ------------------------------------------------------------------------------
# Google Chrome
# ------------------------------------------------------------------------------

bash /ctx/google-chrome.sh


# ==============================================================================
# 08. Configure GNOME
# ==============================================================================

# Compile GSettings schemas for GNOME extensions
find "${EXTENSIONS_DIR}" \
    -type d \
    -name schemas \
    -exec glib-compile-schemas {} \;

# Compile dconf databases and apply system defaults
dconf update


# ==============================================================================
# 09. Configure system services
# ==============================================================================

# Enable Podman socket
systemctl enable podman.socket

# Enable Tailscale daemon
systemctl enable tailscaled.service


# ==============================================================================
# 10. Disable third-party repositories
# ==============================================================================

# Disable COPR repositories
dnf5 -y copr disable "${SCROLL_FACTOR_COPR}"

# Disable other third-party repositories
dnf5 config-manager disable \
    'copr:copr.fedorainfracloud.org:ublue-os:akmods' \
    fedora-multimedia \
    tailscale-stable


# ==============================================================================
# 11. Clean up final image
# ==============================================================================

# Remove unwanted packages without removing dependencies
dnf5 remove -y --no-autoremove \
    "${REMOVE_PACKAGES[@]}"

# Clean package manager caches
dnf5 clean all

echo "Spinosauros image configuration completed successfully."

