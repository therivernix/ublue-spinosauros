#!/usr/bin/env bash
set -euo pipefail

SENTINEL="$HOME/.local/state/spinosauros-first-login.done"

if [[ -f "$SENTINEL" ]]; then
    exit 0
fi

mkdir -p "$(dirname "$SENTINEL")"

ujust install-extensions
ujust configure-extensions
ujust enable-extensions

ujust install-1password
ujust install-framework-tool

ujust install-flatpaks
ujust remove-flatpaks
ujust update-flatpaks

touch "$SENTINEL"
