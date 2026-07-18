#!/usr/bin/env bash

set -euo pipefail

# Check if gnome-extensions-cli is installed
if ! command -v gnome-extensions-cli >/dev/null 2>&1; then
  echo "gnome-extensions-cli not found. Installing via pip3..."

  # Install gnome-extensions-cli via pipx
  pip3 install gnome-extensions-cli

  echo "Installation complete."
else
  echo "gnome-extensions-cli is already installed."
fi

# Install GNOME extensions
gnome-extensions-cli install \
  AlphabeticalAppGrid@stuarthayhurst \
  appindicatorsupport@rgcjonas.gmail.com \
  blur-my-shell@aunetx \
  caffeine@patapon.info \
  clipboard-indicator@tudmotu.com \
  custom-command-list@storageb.github.com \
  hotedge@jonathan.jdoda.ca \
  just-perfection-desktop@just-perfection \
  nightthemeswitcher@romainvigier.fr \
  quick-settings-audio-panel@rayzeq.github.io \
  smile-extension@mijorus.it \
  tailscale-gnome-qs@tailscale-qs.github.io \
  tiling-assistant@leleat-on-github \
  light-style@gnome-shell-extensions.gcampax.github.com
