#!/usr/bin/env bash
set -euo pipefail

SENTINEL="$HOME/.local/state/spinosauros-configureflatpaks.done"

if [[ -f "$SENTINEL" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"

touch "$SENTINEL"

flatpak install -y flathub \
        app.drey.EarTag \
        be.alexandervanhee.gradia \
        ca.desrt.dconf-editor \
        cafe.avery.Delfin \
        com.brave.Browser \
        com.fastmail.Fastmail \
        com.github.PintaProject.Pinta \
        com.github.tchx84.Flatseal \
        com.github.xournalpp.xournalpp \
        com.mattjakeman.ExtensionManager \
        com.obsproject.Studio \
        com.ranfdev.DistroShelf \
        com.somaxa8.earx \
        com.synology.SynologyDrive \
        com.vixalien.sticky \
        com.vscodium.codium \
        com.yubico.yubioath \
        de.leopoldluley.Clapgrep \
        de.swsnr.turnon \
        fr.handbrake.ghb \
        io.github.ans_ibrahim.Memento \
        io.github.flattool.Ignition \
        io.github.flattool.Warehouse \
        io.github.kolunmi.Bazaar \
        io.github.maniacx.BudsLink \
        io.github.plrigaux.sysd-manager \
        io.github.screwys.Rufin \
        io.github.tobagin.keysmith \
        io.github.victoralvesf.aonsoku \
        io.github.vikdevelop.SaveDesktop \
        io.gitlab.adhami3310.Impression \
        io.missioncenter.MissionCenter \
        it.dottorblaster.cauldron \
        it.mijorus.gearlever \
        it.mijorus.smile \
        md.obsidian.Obsidian \
        nl.andreasknoben.Laser \
        org.fedoraproject.MediaWriter \
        org.filezillaproject.Filezilla \
        org.gaphor.Gaphor \
        org.gnome.Calculator \
        org.gnome.Decibels \
        org.gnome.Epiphany \
        org.gnome.FileRoller \
        org.gnome.Firmware \
        org.gnome.Logs \
        org.gnome.Loupe \
        org.gnome.NautilusPreviewer \
        org.gnome.Papers \
        org.gnome.PowerStats \
        org.gnome.Showtime \
        org.gnome.SimpleScan \
        org.gnome.Snapshot \
        org.gnome.SoundRecorder \
        org.gnome.TextEditor \
        org.gnome.World.PikaBackup \
        org.gnome.baobab \
        org.gnome.clocks \
        org.kde.kdenlive \
        org.keepassxc.KeePassXC \
        org.libreoffice.LibreOffice \
        org.nickvision.tubeconverter \
        org.remmina.Remmina \
        org.signal.Signal \
        page.codeberg.libre_menu_editor.LibreMenuEditor \
        page.tesk.Refine
        
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
