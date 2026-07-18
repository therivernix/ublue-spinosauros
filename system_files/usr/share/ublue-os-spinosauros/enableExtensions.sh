#!/usr/bin/env bash

set -euo pipefail

extensions=(
  "AlphabeticalAppGrid@stuarthayhurst"
  "appindicatorsupport@rgcjonas.gmail.com"
  "blur-my-shell@aunetx"
  "caffeine@patapon.info"
  "clipboard-indicator@tudmotu.com"
  "custom-command-list@storageb.github.com"
  "dash-to-dock@micxgx.gmail.com"
  "hide-minimized@danigm.net"
  "hotedge@jonathan.jdoda.ca"
  "just-perfection-desktop@just-perfection"
  "nightthemeswitcher@romainvigier.fr"
  "quick-settings-audio-panel@rayzeq.github.io"
  "smile-extension@mijorus.it"
  "tailscale-gnome-qs@tailscale-qs.github.io"
  "tiling-assistant@leleat-on-github"
  "Studi-Brightness-Control@matey-0"
)

for ext in "${extensions[@]}"; do
  echo "Enabling: $ext"
  gnome-extensions enable "$ext"
done

echo "All extensions enabled."
