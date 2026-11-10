#!/bin/bash

set -ouex pipefail

#Removing bluefin keybindings so I can override them
# rm -f /etc/dconf/db/distro.d/02-bluefin-keybindings

# Removing built-in extensions
rm -rf /usr/share/gnome-shell/extensions/*

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# Use a COPR Example:

# Enable COPRs to packages from said COPR can be installed during build time
#dnf5 -y copr enable ublue-os/packages


dnf5 install -y \
    firefox \
    firefox-langpacks \
    yelp \
    curl \
    jq \
    unzip \
    git \
    make \
    gettext \
    meson \
    glib2-devel \
    sassc \
    xdg-terminal-exec \
    gum \
    dnf5-plugins \
    chromium

# Add the official Tailscale repository
dnf5 config-manager addrepo --overwrite \
    --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

# Install Tailscale
dnf5 install -y tailscale

# Install ChatGPT Desktop
# Download and install ChatGPT Codex
mkdir -p /usr/share/ublue-os-spinosauros/codex

curl -fL --retry 3 \
    -o /usr/share/ublue-os-spinosauros/codex/chatgpt.x86_64.rpm \
    https://persistent.oaistatic.com/codex-app-prod/linux/rpm/latest/chatgpt.x86_64.rpm

dnf5 install -y \
    /usr/share/ublue-os-spinosauros/codex/chatgpt.x86_64.rpm


### Extensions

# Compile GSettings schemas for GNOME extensions
find /usr/share/gnome-shell/extensions -type d -name schemas \
    -exec glib-compile-schemas {} \;


### Gnome Dconf

# Reloading dconf to ingest settings and apply kb shortcuts
# Compile dconf databases
dconf update


### Cleaning Up

#Removing packages that are no longer needed after the build has completed
dnf5 remove -y --no-autoremove \
    gnome-software \
    gnome-extensions-app \
    htop \
    nvtop \
    sassc
    #make \
    #gettext \
    #meson \
    #glib2-devel \
    
dnf5 clean all

# Disable COPRs so they don't end up enabled on the final image:
#dnf5 -y copr disable ublue-os/packages

# Disable third-party repositories in the final image
dnf5 config-manager disable \
    'copr:copr.fedorainfracloud.org:ublue-os:akmods' \
    fedora-multimedia \
    tailscale-stable

#### Example for enabling a System Unit File
systemctl enable podman.socket

# Enable the daemon for boot
systemctl enable tailscaled.service




