#!/usr/bin/env bash
#
# Install GNOME Shell extensions system-wide during an image build.
#
# Sources:
#   - extensions.gnome.org for normal GNOME Extensions
#   - GitHub for ASDB-Brightness-Keys@therivernix and Blur my Shell
#
# Intended for immutable Fedora/Silverblue/Bluefin/bootc image builds.
#

set -euo pipefail

INSTALL_DIR="/usr/share/gnome-shell/extensions"
EGO_API="https://extensions.gnome.org/extension-query/"

# Extensions from extensions.gnome.org.
EGO_EXTENSIONS=(
    "AlphabeticalAppGrid@stuarthayhurst"
    "BudsLink-Companion@maniacx.github.com"
    "Studi-Brightness-Control@matey-0"
    "clipboard-indicator@tudmotu.com"
    "custom-command-list@storageb.github.com"
    "disable-workspace-switch-animation@osmancevik"
    "hide-minimized@danigm.net"
    "hotedge@jonathan.jdoda.ca"
    "just-perfection-desktop@just-perfection"
    "light-style@gnome-shell-extensions.gcampax.github.com"
    "lightning-gnome-launcher@avimanyu"
    "nightthemeswitcher@romainvigier.fr"
    "quick-settings-audio-panel@rayzeq.github.io"
    "smile-extension@mijorus.it"
    "tailscale-gnome-qs@tailscale-qs.github.io"
    "tilingshell@ferrarodomenico.com"
)

# GitHub-hosted extension.
ASDB_UUID="ASDB-Brightness-Keys@therivernix"
ASDB_ZIP_URL="https://github.com/therivernix/ASDB-Brightness-Keys/raw/refs/heads/main/ASDB-Brightness-Keys%40therivernix.zip"

# GitHub-hosted Blur my Shell.
BLUR_UUID="blur-my-shell@aunetx"
BLUR_ZIP_URL="https://github.com/aunetx/blur-my-shell/archive/refs/heads/master.zip"

log() {
    printf '[gnome-extensions] %s\n' "$*"
}

die() {
    printf '[gnome-extensions] ERROR: %s\n' "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "Required command not found: $1"
}

get_shell_major_version() {
    local version

    # During a normal Fedora image build, gnome-shell is installed in the image.
    # rpm is preferred because it does not require a running GNOME session.
    if command -v rpm >/dev/null 2>&1 && rpm -q gnome-shell >/dev/null 2>&1; then
        version="$(rpm -q --qf '%{VERSION}\n' gnome-shell | head -n1)"
    elif command -v gnome-shell >/dev/null 2>&1; then
        version="$(gnome-shell --version | sed -E 's/.* ([0-9]+).*/\1/')"
    else
        die "Could not determine installed GNOME Shell version."
    fi

    printf '%s\n' "$version" | sed -E 's/^([0-9]+).*/\1/'
}

find_ego_extension() {
    local uuid="$1"
    local shell_version="$2"
    local response

    response="$(
        curl --fail --silent --show-error --location \
            --get "$EGO_API" \
            --data-urlencode "search=$uuid" \
            --data-urlencode "shell_version=$shell_version"
    )"

    # Search results use uuid as the stable identifier. Pick the exact UUID.
    jq -er --arg uuid "$uuid" '
        .extensions[]
        | select(.uuid == $uuid)
        | .pk
    ' <<<"$response" | head -n1
}

download_ego_extension() {
    local uuid="$1"
    local shell_version="$2"
    local pk
    local zip
    local tmpdir
    local metadata
    local extracted_uuid

    log "Looking up $uuid for GNOME Shell $shell_version..."

    pk="$(find_ego_extension "$uuid" "$shell_version")" || {
        die "No compatible EGO release found for $uuid and GNOME Shell $shell_version."
    }

    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    zip="$tmpdir/extension.zip"

    curl --fail --silent --show-error --location \
        "https://extensions.gnome.org/extension-download/?pk=$pk&shell_version=$shell_version" \
        -o "$zip"

    unzip -q "$zip" -d "$tmpdir/extracted"

    metadata="$(find "$tmpdir/extracted" -type f -name metadata.json -print -quit)"

    [[ -n "$metadata" ]] ||
        die "Downloaded archive for $uuid does not contain metadata.json."

    extracted_uuid="$(
        jq -er '.uuid // empty' "$metadata"
    )"

    [[ "$extracted_uuid" == "$uuid" ]] ||
        die "UUID mismatch: expected '$uuid', downloaded '$extracted_uuid'."

    install_extension_directory "$uuid" "$(dirname "$metadata")"

    trap - RETURN
    rm -rf "$tmpdir"
}

download_github_extension() {
    local uuid="$1"
    local url="$2"
    local tmpdir
    local zip
    local metadata
    local extracted_uuid

    log "Downloading $uuid from GitHub..."

    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    zip="$tmpdir/extension.zip"

    curl --fail --silent --show-error --location \
        "$url" \
        -o "$zip"

    unzip -q "$zip" -d "$tmpdir/extracted"

    metadata="$(find "$tmpdir/extracted" -type f -name metadata.json -print -quit)"

    [[ -n "$metadata" ]] ||
        die "GitHub archive for $uuid does not contain metadata.json."

    extracted_uuid="$(
        jq -er '.uuid // empty' "$metadata"
    )"

    [[ "$extracted_uuid" == "$uuid" ]] ||
        die "UUID mismatch: expected '$uuid', downloaded '$extracted_uuid'."

    install_extension_directory "$uuid" "$(dirname "$metadata")"

    trap - RETURN
    rm -rf "$tmpdir"
}

download_blur_my_shell() {
    local uuid="$BLUR_UUID"
    local tmpdir
    local metadata
    local extracted_uuid
    local source_dir

    log "Downloading $uuid from GitHub: https://github.com/aunetx/blur-my-shell"

    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' RETURN

    curl --fail --silent --show-error --location \
        "$BLUR_ZIP_URL" \
        -o "$tmpdir/extension.zip"

    unzip -q "$tmpdir/extension.zip" -d "$tmpdir/extracted"

    metadata="$(find "$tmpdir/extracted" -type f -name metadata.json -print -quit)"
    [[ -n "$metadata" ]] || die "GitHub archive for $uuid does not contain metadata.json."

    extracted_uuid="$(jq -er '.uuid // empty' "$metadata")"
    [[ "$extracted_uuid" == "$uuid" ]] || \
        die "UUID mismatch: expected '$uuid', downloaded '$extracted_uuid'."

    if ! jq -e --arg shell_version "$SHELL_VERSION" \
        '.["shell-version"] | map(select(. == $shell_version)) | length > 0' \
        "$metadata" >/dev/null; then
        die "$uuid does not declare support for GNOME Shell $SHELL_VERSION."
    fi

    source_dir="$(dirname "$metadata")"
    install_extension_directory "$uuid" "$source_dir"

    trap - RETURN
    rm -rf "$tmpdir"
}

install_extension_directory() {
    local uuid="$1"
    local source_dir="$2"
    local destination="${INSTALL_DIR}/${uuid}"
    local staging="${INSTALL_DIR}/.${uuid}.new"

    [[ -f "${source_dir}/metadata.json" ]] ||
        die "Missing metadata.json for $uuid."

    # Validate metadata.json before installing it.
    jq empty "${source_dir}/metadata.json" >/dev/null ||
        die "Invalid metadata.json for $uuid."

    rm -rf "$staging"
    mkdir -p "$INSTALL_DIR"

    # Copy into a staging directory so a failed build never leaves a
    # partially installed extension behind.
    cp -a "$source_dir/." "$staging/"

    rm -rf "$destination"
    mv "$staging" "$destination"

    log "Installed $uuid"
}

main() {
    local shell_version

    [[ $EUID -eq 0 ]] ||
        die "This script must run as root during the image build."

    require_command curl
    require_command jq
    require_command unzip

    mkdir -p "$INSTALL_DIR"

    shell_version="$(get_shell_major_version)"
    SHELL_VERSION="$shell_version"
    log "Detected GNOME Shell major version: $shell_version"
    log "Installing extensions into: $INSTALL_DIR"

    for uuid in "${EGO_EXTENSIONS[@]}"; do
        download_ego_extension "$uuid" "$shell_version"
    done

    download_blur_my_shell
    download_github_extension "$ASDB_UUID" "$ASDB_ZIP_URL"

    log "All GNOME extensions installed successfully."
}

main "$@"
