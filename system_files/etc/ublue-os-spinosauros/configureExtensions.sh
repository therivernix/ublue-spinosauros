#!/usr/bin/env bash
set -euo pipefail

SENTINEL="$HOME/.local/state/spinosauros-configureextensions.done"

if [[ -f "$SENTINEL" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"

dconf load /org/gnome/shell/extensions/ < /etc/ublue-os-spinosauros/extension-settings.dconf
