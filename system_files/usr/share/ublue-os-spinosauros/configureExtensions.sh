#!/usr/bin/env bash

set -euo pipefail

dconf load /org/gnome/shell/extensions/ < /usr/share/ublue-os-spinosauros/extension-settings.dconf
