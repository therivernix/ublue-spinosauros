#!/usr/bin/env bash
set -euo pipefail

SENTINEL="$HOME/.local/state/spinosauros-configurekeybindings.done"

if [[ -f "$SENTINEL" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"

touch "$SENTINEL"

dconf load /org/gnome/settings-daemon/plugins/media-keys/ < /usr/share/ublue-os-spinosauros/dconf/media-keys.dconf
dconf load /org/gnome/desktop/wm/keybindings/ < /usr/share/ublue-os-spinosauros/dconf/wm-keybindings.dconf
dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < /usr/share/ublue-os-spinosauros/dconf/custom-keybindings.conf
dconf load /org/gnome/shell/keybindings/ < /usr/share/ublue-os-spinosauros/dconf/shell-keybindings.dconf
