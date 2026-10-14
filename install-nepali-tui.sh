#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SINGLE_INSTALLER="$SOURCE_DIR/install-nepali-unicode-romanized.sh"

if [ ! -x "$SINGLE_INSTALLER" ]; then
  echo "Missing installer: $SINGLE_INSTALLER" >&2
  exit 1
fi

if ! command -v whiptail >/dev/null 2>&1; then
  echo "whiptail is required. Install it (e.g. sudo pacman -S libnewt)." >&2
  exit 1
fi

SCOPE="$(whiptail --title "Nepali Unicode Romanized Installer" --radiolist \
  "Choose installation scope:" 12 70 2 \
  "user"   "User-level (~/.config/xkb) - no sudo" ON \
  "system" "System-wide (/usr/share/X11/xkb) - sudo" OFF \
  3>&1 1>&2 2>&3)" || exit 1

INSTALL_FONTS="$(whiptail --title "Optional fonts" --yesno \
  "Install Noto fonts for Devanagari rendering (recommended)?" 8 70 3>&1 1>&2 2>&3 && echo yes || echo no)"

INSTALL_ARGS=()
if [ "$SCOPE" = "system" ]; then
  INSTALL_ARGS+=(--system)
fi

whiptail --title "Installing" --infobox "Installing layout..." 8 60
"$SINGLE_INSTALLER" "${INSTALL_ARGS[@]}"

if [ "$INSTALL_FONTS" = "yes" ]; then
  whiptail --title "Fonts" --infobox "Installing Noto fonts (may ask for sudo)..." 8 60
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm noto-fonts >/dev/null 2>&1 || true
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get install -y fonts-noto || true
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y google-noto-sans-devanagari-fonts >/dev/null 2>&1 || true
  fi
  fc-cache -f >/dev/null 2>&1 || true
fi

whiptail --title "Validation" --infobox "Verifying installation..." 8 60
if command -v xkbcli >/dev/null 2>&1; then
  if ! xkbcli compile-keymap --include "${XDG_CONFIG_HOME:-$HOME/.config}/xkb" --include-defaults --rules evdev --layout nepali_unicode_romanized --variant unicode_romanized --test >/tmp/nepali-install-validation.log 2>&1; then
    whiptail --title "Validation failed" --msgbox "Validation failed. See /tmp/nepali-install-validation.log" 10 60
    exit 1
  fi
else
  whiptail --title "Validation skipped" --msgbox "xkbcli not found, validation skipped." 8 60
fi

whiptail --title "Done" --msgbox \
"Installation complete.

Layout: Nepali Unicode Romanized
Toggle: Alt+Shift

Hyprland: input configuration updated (if applicable).
Remember to reload: hyprctl reload" 14 70
