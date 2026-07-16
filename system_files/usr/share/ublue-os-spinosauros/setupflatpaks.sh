#!/usr/bin/env bash
set -euo pipefail

SENTINEL="$HOME/.local/state/spinosauros-configureflatpaks.done"

if [[ -f "$SENTINEL" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"

touch "$SENTINEL"

flatpak install -y flathub org.gnome.Decibels \
        org.gnome.Snapshot \
        org.gnome.clocks \
        app.drey.EarTag \
        com.fastmail.Fastmail \
        org.fedoraproject.MediaWriter \
        com.unicornsonlsd.finamp \
        it.mijorus.gearlever \
        io.m51.Gelly \
        be.alexandervanhee.gradia \
        io.github.tobagin.keysmith \
        org.libreoffice.LibreOffice \
        md.obsidian.Obsidian \
        org.nickvision.tubeconverter \
        org.remmina.Remmina \
        org.signal.Signal \
        com.synology.SynologyDrive \
        de.swsnr.turnon \
        org.gnome.Showtime \
        com.yubico.yubioath \
        org.gnome.World.PikaBackup \
        ca.desrt.dconf-editor \
        page.codeberg.libre_menu_editor.LibreMenuEditor
        
flatpak uninstall -y org.gnome.Calendar \
        org.gnome.Contacts \
        org.mozilla.firefox \
        org.mozilla.thunderbird \
        org.mozilla.thunderbird_esr \
        org.mozilla.thunderbird_esr.Locale \
        org.gnome.font-viewer \
        org.gnome.Characters \
        org.gnome.Maps \
        org.gnome.DejaDup \
        org.gnome.Connections \
        org.gnome.Weather
