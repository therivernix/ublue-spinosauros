#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="/usr/share/gnome-shell/extensions"
GITHUB_API="https://api.github.com"
SHELL_VERSION=""

# GitHub projects where an installable release ZIP is preferred. If no usable
# release ZIP exists, the default branch is inspected and, when necessary,
# a project-specific source build is used below.
RELEASE_EXTENSIONS=(
  "AlphabeticalAppGrid@stuarthayhurst|stuarthayhurst/alphabetical-grid-extension"
  "Studi-Brightness-Control@matey-0|matey-0/Studi-Brightness-Control"
  "clipboard-indicator@tudmotu.com|Tudmotu/gnome-shell-extension-clipboard-indicator"
  "custom-command-list@storageb.github.com|StorageB/custom-command-menu"
  "disable-workspace-switch-animation@osmancevik|osmancevik/gnome-extension-disable-workspace-switch-animation"
  "hide-minimized@danigm.net|danigm/hide-minimized"
  "hotedge@jonathan.jdoda.ca|jdoda/hotedge"
  "quick-settings-audio-panel@rayzeq.github.io|Rayzeq/quick-settings-audio-panel"
  "smile-extension@mijorus.it|mijorus/smile-gnome-extension"
  "tilingshell@ferrarodomenico.com|domferr/tilingshell"
)

# Directly installable source repositories.
SOURCE_EXTENSIONS=(
  "BudsLink-Companion@maniacx.github.com|maniacx/BudsLink-Companion|gnome"
)

ASDB_UUID="ASDB-Brightness-Keys@therivernix"
ASDB_ZIP_URL="https://raw.githubusercontent.com/therivernix/ASDB-Brightness-Keys/main/ASDB-Brightness-Keys%40therivernix.zip"

BLUR_UUID="blur-my-shell@aunetx"
BLUR_REPO="https://github.com/aunetx/blur-my-shell.git"

JUST_UUID="just-perfection-desktop@just-perfection"
JUST_REPO="https://github.com/jrahmatzadeh/just-perfection.git"

TAILSCALE_UUID="tailscale-gnome-qs@tailscale-qs.github.io"
TAILSCALE_REPO="https://github.com/tailscale-qs/tailscale-gnome-qs.git"

NIGHT_UUID="nightthemeswitcher@romainvigier.fr"
NIGHT_REPO="https://gitlab.com/rmnvgr/nightthemeswitcher-gnome-shell-extension.git"

LIGHTNING_UUID="lightning-gnome-launcher@avimanyu"
LIGHTNING_REPO="https://gitlab.com/rimal.avimanyu/lightning-gnome-launcher-extension.git"

LIGHT_STYLE_UUID="light-style@gnome-shell-extensions.gcampax.github.com"

log() { printf '[gnome-extensions] %s\n' "$*"; }
die() { printf '[gnome-extensions] ERROR: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Required build command is missing: $1"; }

get_shell_major_version() {
  local v
  if rpm -q gnome-shell >/dev/null 2>&1; then
    v="$(rpm -q --qf '%{VERSION}\n' gnome-shell | head -n1)"
  else
    v="$(gnome-shell --version | sed -E 's/.* ([0-9]+).*/\1/')"
  fi
  sed -E 's/^([0-9]+).*/\1/' <<<"$v"
}

supports_shell() {
  jq -e --arg s "$SHELL_VERSION" '
    (.["shell-version"] // []) | map(tostring) |
    any(. == $s or startswith($s + "."))
  ' "$1" >/dev/null
}

find_metadata() {
  local root="$1" uuid="$2" m
  while IFS= read -r m; do
    [[ "$(jq -r '.uuid // empty' "$m" 2>/dev/null || true)" == "$uuid" ]] && {
      printf '%s\n' "$m"; return 0;
    }
  done < <(find "$root" -type f -name metadata.json -print)
  return 1
}

install_dir() {
  local uuid="$1" src="$2"
  local meta="$src/metadata.json" dst="$INSTALL_DIR/$uuid" stage="$INSTALL_DIR/.$uuid.new"
  [[ -f "$meta" ]] || die "Missing metadata.json for $uuid"
  [[ "$(jq -er '.uuid' "$meta")" == "$uuid" ]] || die "UUID mismatch for $uuid"
  supports_shell "$meta" || die "$uuid does not declare GNOME Shell $SHELL_VERSION support"
  rm -rf "$stage"
  mkdir -p "$stage"
  cp -a "$src/." "$stage/"
  rm -rf "$dst"
  mv "$stage" "$dst"
  log "Installed $uuid"
}

try_zip() {
  local uuid="$1" zip="$2" tmp="$3" meta
  rm -rf "$tmp/unzip"; mkdir -p "$tmp/unzip"
  unzip -q "$zip" -d "$tmp/unzip" 2>/dev/null || return 1
  meta="$(find_metadata "$tmp/unzip" "$uuid")" || return 1
  supports_shell "$meta" || return 2
  install_dir "$uuid" "$(dirname "$meta")"
}

gh() {
  curl -fsSL -H 'Accept: application/vnd.github+json' \
    -H 'X-GitHub-Api-Version: 2022-11-28' "$1"
}

install_release_or_source() {
  local uuid="$1" repo="$2" tmp rel name url rc branch meta
  tmp="$(mktemp -d)"
  log "Resolving $uuid from $repo"

  if rel="$(gh "$GITHUB_API/repos/$repo/releases/latest" 2>/dev/null)"; then
    log "Latest release: $(jq -r '.tag_name // "unknown"' <<<"$rel")"
    while IFS=$'\t' read -r name url; do
      [[ -n "$url" ]] || continue
      log "Trying release ZIP: $name"
      curl -fsSL "$url" -o "$tmp/a.zip" || continue
      set +e; try_zip "$uuid" "$tmp/a.zip" "$tmp"; rc=$?; set -e
      [[ $rc -eq 0 ]] && { rm -rf "$tmp"; return 0; }
    done < <(jq -r '.assets[] | select(.name|ascii_downcase|endswith(".zip")) |
                    [.name,.browser_download_url]|@tsv' <<<"$rel")
  fi

  branch="$(gh "$GITHUB_API/repos/$repo" | jq -er '.default_branch')"
  log "No compatible release ZIP; inspecting $repo@$branch"
  curl -fsSL "https://github.com/$repo/archive/refs/heads/$branch.zip" -o "$tmp/source.zip"
  rm -rf "$tmp/source"; mkdir -p "$tmp/source"
  unzip -q "$tmp/source.zip" -d "$tmp/source"
  meta="$(find_metadata "$tmp/source" "$uuid" || true)"
  if [[ -n "$meta" ]] && supports_shell "$meta"; then
    install_dir "$uuid" "$(dirname "$meta")"
    rm -rf "$tmp"; return 0
  fi

  rm -rf "$tmp"
  die "No directly installable GNOME-$SHELL_VERSION artifact found for $uuid in $repo"
}

install_branch_source() {
  local uuid="$1" repo="$2" branch="$3" tmp meta
  tmp="$(mktemp -d)"
  log "Installing $uuid from $repo branch $branch"
  git clone -q --depth=1 --branch "$branch" "https://github.com/$repo.git" "$tmp/repo"
  meta="$(find_metadata "$tmp/repo" "$uuid")" || die "Could not locate $uuid in $repo/$branch"
  install_dir "$uuid" "$(dirname "$meta")"
  rm -rf "$tmp"
}

install_asdb() {
  local tmp rc
  tmp="$(mktemp -d)"
  log "Installing $ASDB_UUID"
  curl -fsSL "$ASDB_ZIP_URL" -o "$tmp/a.zip"
  set +e; try_zip "$ASDB_UUID" "$tmp/a.zip" "$tmp"; rc=$?; set -e
  rm -rf "$tmp"
  [[ $rc -eq 0 ]] || die "ASDB ZIP is missing, invalid, or incompatible with GNOME $SHELL_VERSION"
}

install_blur() {
  local tmp meta
  tmp="$(mktemp -d)"
  log "Building $BLUR_UUID from current upstream master"
  git clone -q --depth=1 "$BLUR_REPO" "$tmp/repo"
  # Upstream source is already an extension tree; the image build compiles
  # GSettings schemas globally afterwards. Validate before copying.
  meta="$(find_metadata "$tmp/repo" "$BLUR_UUID")" || die "Blur My Shell metadata not found"
  install_dir "$BLUR_UUID" "$(dirname "$meta")"
  rm -rf "$tmp"
}

install_just_perfection() {
  local tmp meta
  tmp="$(mktemp -d)"
  log "Building $JUST_UUID"
  git clone -q --depth=1 "$JUST_REPO" "$tmp/repo"
  (
    cd "$tmp/repo"
    ./scripts/build.sh
  )
  meta="$(find_metadata "$tmp/repo" "$JUST_UUID")" || die "Just Perfection build produced no extension"
  install_dir "$JUST_UUID" "$(dirname "$meta")"
  rm -rf "$tmp"
}

install_tailscale() {
  local tmp meta
  tmp="$(mktemp -d)"
  log "Building $TAILSCALE_UUID"
  git clone -q --depth=1 "$TAILSCALE_REPO" "$tmp/repo"
  ( cd "$tmp/repo"; make build )
  meta="$(find_metadata "$tmp/repo" "$TAILSCALE_UUID")" || die "Tailscale QS build produced no extension"
  install_dir "$TAILSCALE_UUID" "$(dirname "$meta")"
  rm -rf "$tmp"
}

install_night() {
  local tmp stage meta
  tmp="$(mktemp -d)"; stage="$tmp/stage"
  log "Building $NIGHT_UUID with Meson"
  git clone -q --depth=1 "$NIGHT_REPO" "$tmp/repo"
  (
    cd "$tmp/repo"
    meson setup builddir --prefix=/usr
    DESTDIR="$stage" meson install -C builddir
  )
  meta="$(find_metadata "$stage" "$NIGHT_UUID")" || die "Night Theme Switcher build produced no extension"
  install_dir "$NIGHT_UUID" "$(dirname "$meta")"
  rm -rf "$tmp"
}

install_lightning() {
  local tmp meta
  tmp="$(mktemp -d)"
  log "Installing $LIGHTNING_UUID from canonical GitLab upstream"
  git clone -q --depth=1 "$LIGHTNING_REPO" "$tmp/repo"
  meta="$(find_metadata "$tmp/repo" "$LIGHTNING_UUID" || true)"
  if [[ -n "$meta" ]]; then
    install_dir "$LIGHTNING_UUID" "$(dirname "$meta")"
  elif [[ -f "$tmp/repo/Makefile" ]]; then
    ( cd "$tmp/repo"; make build )
    meta="$(find_metadata "$tmp/repo" "$LIGHTNING_UUID")" ||
      die "Lightning build completed but extension metadata was not found"
    install_dir "$LIGHTNING_UUID" "$(dirname "$meta")"
  else
    die "Lightning upstream layout changed and no supported build entry point was found"
  fi
  rm -rf "$tmp"
}

verify_light_style() {
  local meta="$INSTALL_DIR/$LIGHT_STYLE_UUID/metadata.json"
  log "Checking base-image $LIGHT_STYLE_UUID"
  [[ -f "$meta" ]] || die "$LIGHT_STYLE_UUID is missing from the Bluefin base image"
  supports_shell "$meta" || die "Base-image $LIGHT_STYLE_UUID is not compatible with GNOME $SHELL_VERSION"
  log "Keeping base-image $LIGHT_STYLE_UUID"
}

main() {
  local e uuid repo branch

  [[ $EUID -eq 0 ]] || die "Run this during the image build as root"

  for c in curl jq unzip git make gettext meson glib-compile-schemas; do need "$c"; done

  SHELL_VERSION="$(get_shell_major_version)"
  log "Detected GNOME Shell major version: $SHELL_VERSION"
  mkdir -p "$INSTALL_DIR"

  for e in "${RELEASE_EXTENSIONS[@]}"; do
    IFS='|' read -r uuid repo <<<"$e"
    install_release_or_source "$uuid" "$repo"
  done

  for e in "${SOURCE_EXTENSIONS[@]}"; do
    IFS='|' read -r uuid repo branch <<<"$e"
    install_branch_source "$uuid" "$repo" "$branch"
  done

  install_blur
  install_just_perfection
  install_tailscale
  install_night
  install_lightning
  verify_light_style
  install_asdb

  log "Verifying installed extension UUIDs..."
  for e in "${RELEASE_EXTENSIONS[@]}" "${SOURCE_EXTENSIONS[@]}"; do
    uuid="${e%%|*}"
    [[ -f "$INSTALL_DIR/$uuid/metadata.json" ]] || die "Final verification failed: $uuid"
  done
  for uuid in "$BLUR_UUID" "$JUST_UUID" "$TAILSCALE_UUID" "$NIGHT_UUID" \
              "$LIGHTNING_UUID" "$LIGHT_STYLE_UUID" "$ASDB_UUID"; do
    [[ -f "$INSTALL_DIR/$uuid/metadata.json" ]] || die "Final verification failed: $uuid"
  done

  log "All GNOME extensions installed successfully."
}

main "$@"
