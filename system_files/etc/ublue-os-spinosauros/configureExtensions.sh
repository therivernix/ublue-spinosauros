#!/usr/bin/env bash

set -euo pipefail

dconf load /org/gnome/shell/extensions/ < /etc/ublue-os-spinosauros/extension-settings.dconf
