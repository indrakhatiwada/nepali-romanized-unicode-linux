#!/usr/bin/env bash
set -euo pipefail

BACKUP="${XDG_CONFIG_HOME:-$HOME/.config}/nepali-unicode-romanized-prev.txt"

if [ -f "$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/hypr/input.lua.bak.altshift" ]; then
  cp "$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/hypr/input.lua.bak.altshift" "$HOME/.mydotfiles/com.ml4w.dotfiles.stable/.config/hypr/input.lua"
  command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1 || true
  echo "Restored Hyprland input from backup."
elif [ -n "${XDG_CURRENT_DESKTOP:-}" ] && echo "$XDG_CURRENT_DESKTOP" | grep -qi hypr; then
  echo "No backup found; manually set input block back to kb_layout = \"us\"."
fi

case "${XDG_CURRENT_DESKTOP:-}" in
  *GNOME*|*gnome*)
    gsettings set org.gnome.desktop.input-sources sources "[('xkb','us')]"
    gsettings set org.gnome.desktop.input-sources xkb-options "[]"
    echo "GNOME reset to US layout."
    ;;
  *)
    if [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
      setxkbmap -layout us || true
      echo "Reset X11 to US layout."
    fi
    ;;
esac

echo "Disable complete (backup: $BACKUP)."
