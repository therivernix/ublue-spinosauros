#!/usr/bin/env bash

set -euo pipefail

APPS=$(
cat <<'EOF'
app.drey.EarTag
be.alexandervanhee.gradia
ca.desrt.dconf-editor
com.brave.Browser
com.fastmail.Fastmail
com.github.PintaProject.Pinta
com.github.tchx84.Flatseal
com.mattjakeman.ExtensionManager
com.synology.SynologyDrive
de.swsnr.turnon
io.github.flattool.Ignition
io.github.flattool.Warehouse
io.github.kolunmi.Bazaar
io.missioncenter.MissionCenter
md.obsidian.Obsidian
org.fedoraproject.MediaWriter
org.gnome.Showtime
org.gnome.Calculator
org.gnome.Decibels
org.gnome.Logs
org.gnome.Loupe
org.gnome.Music
org.gnome.NautilusPreviewer
org.gnome.Snapshot
org.gnome.TextEditor
org.gnome.baobab
org.gnome.clocks
org.remmina.Remmina
org.signal.Signal
page.codeberg.libre_menu_editor.LibreMenuEditor
EOF
)

echo "The following Flatpaks will be installed:"
echo "$APPS"
echo

read -rp "Proceed with installation? [y/N] " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "$APPS" | xargs -r flatpak install -y
    echo "Installation complete."
else
    echo "Aborted."
fi
