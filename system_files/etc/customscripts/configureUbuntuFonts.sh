#!/usr/bin/env bash
set -euo pipefail

URL="https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip"
ZIP_FILE="ubuntu-font-family-0.83.zip"
FONT_DIR="$HOME/.local/share/fonts"

FONT="Ubuntu 11"
DOC_FONT="Ubuntu 12"
MONO_FONT="Ubuntu Mono 11"

echo "=============================="
echo " Ubuntu Font Setup Script"
echo "=============================="

# -----------------------------
# Download
# -----------------------------
echo
echo "Downloading Ubuntu font family..."
curl -L "$URL" -o "$ZIP_FILE"

if [[ ! -s "$ZIP_FILE" ]]; then
    echo "ERROR: Download failed or file is empty"
    exit 1
fi

# -----------------------------
# Extract + install
# -----------------------------
echo
echo "Installing fonts..."

mkdir -p "$FONT_DIR"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

unzip -q "$ZIP_FILE" -d "$TMP_DIR"

find "$TMP_DIR" -type f \( -iname "*.ttf" -o -iname "*.otf" \) \
    -exec cp -f {} "$FONT_DIR/" \;

echo "Refreshing font cache..."
fc-cache -f "$FONT_DIR" >/dev/null

# -----------------------------
# Validate font installation
# -----------------------------
echo
echo "Validating font installation..."

if fc-list | grep -qi "ubuntu mono" && fc-list | grep -qi "^.*ubuntu"; then
    echo "✓ Ubuntu fonts detected"
else
    echo "✗ Ubuntu fonts NOT detected"
    exit 1
fi

# -----------------------------
# Set GNOME fonts
# -----------------------------
echo
echo "Setting GNOME fonts..."

gsettings set org.gnome.desktop.interface font-name "$FONT"
gsettings set org.gnome.desktop.interface document-font-name "$DOC_FONT"
gsettings set org.gnome.desktop.interface monospace-font-name "$MONO_FONT"

# -----------------------------
# Validate GNOME settings
# -----------------------------
echo
echo "Validating GNOME settings..."

actual_font=$(gsettings get org.gnome.desktop.interface font-name | tr -d "'")
actual_doc=$(gsettings get org.gnome.desktop.interface document-font-name | tr -d "'")
actual_mono=$(gsettings get org.gnome.desktop.interface monospace-font-name | tr -d "'")

status=0

if [[ "$actual_font" != "$FONT" ]]; then
    echo "✗ font-name mismatch"
    echo "  expected: $FONT"
    echo "  actual:   $actual_font"
    status=1
else
    echo "✓ font-name = $actual_font"
fi

if [[ "$actual_doc" != "$DOC_FONT" ]]; then
    echo "✗ document-font-name mismatch"
    echo "  expected: $DOC_FONT"
    echo "  actual:   $actual_doc"
    status=1
else
    echo "✓ document-font-name = $actual_doc"
fi

if [[ "$actual_mono" != "$MONO_FONT" ]]; then
    echo "✗ monospace-font-name mismatch"
    echo "  expected: $MONO_FONT"
    echo "  actual:   $actual_mono"
    status=1
else
    echo "✓ monospace-font-name = $actual_mono"
fi

echo

if [[ $status -eq 0 ]]; then
    echo "All GNOME font settings validated successfully."
else
    echo "Validation failed."
    exit 1
fi

echo
echo "Done."
