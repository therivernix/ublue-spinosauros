#!/usr/bin/env bash
set -euo pipefail

FLATPAK="/usr/bin/flatpak"
SENTINEL="$HOME/.local/state/spinosauros-installflatpaks.done"

########################################
# Don't run more than once
########################################

if [[ -f "$SENTINEL" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"

########################################
# Install Flatpak applications
########################################

APPS=(
    app.drey.EarTag
    be.alexandervanhee.gradia
    ca.desrt.dconf-editor
    com.fastmail.Fastmail
    com.github.tchx84.Flatseal
    com.github.xournalpp.xournalpp
    com.mattjakeman.ExtensionManager
    com.ranfdev.DistroShelf
    com.synology.SynologyDrive
    com.yubico.yubioath
    io.github.flattool.Ignition
    io.github.flattool.Warehouse
    io.github.kolunmi.Bazaar
    io.github.maniacx.BudsLink
    io.github.plrigaux.sysd-manager
    io.github.screwys.Rufin
    io.github.tobagin.keysmith
    io.missioncenter.MissionCenter
    it.mijorus.gearlever
    it.mijorus.smile
    md.obsidian.Obsidian
    org.fedoraproject.MediaWriter
    org.gnome.Calculator
    org.gnome.Decibels
    org.gnome.Epiphany
    org.gnome.FileRoller
    org.gnome.Firmware
    org.gnome.Logs
    org.gnome.Loupe
    org.gnome.NautilusPreviewer
    org.gnome.Showtime
    org.gnome.SimpleScan
    org.gnome.Snapshot
    org.gnome.SoundRecorder
    org.gnome.TextEditor
    org.gnome.World.PikaBackup
    org.gnome.baobab
    org.gnome.clocks
    org.libreoffice.LibreOffice
    org.nickvision.tubeconverter
    org.remmina.Remmina
    org.signal.Signal
    page.codeberg.libre_menu_editor.LibreMenuEditor
    page.tesk.Refine
    org.pulseaudio.pavucontrol
    dev.mufeed.Wordbook
)

for app in "${APPS[@]}"; do
    "$FLATPAK" install --user -y flathub "$app"
done

########################################
# Mark setup as complete
########################################

touch "$SENTINEL"
