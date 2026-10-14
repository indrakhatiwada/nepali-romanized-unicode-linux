#!/usr/bin/env bash
set -euo pipefail

APPLY=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

LAYOUT="nepali_unicode_romanized"
VARIANT="unicode_romanized"
HCTL="grp:alt_shift_toggle"

echo "Alt+Shift toggle target:"
echo "  layout: $LAYOUT/$VARIANT"
echo "  options: $HCTL"

if [ "$APPLY" -ne 1 ]; then
  echo "Preview only. Re-run with --apply to modify configuration."
  if [ -n "$HYPR" ] && [ -f "$HYPR" ]; then
    echo "Hyprland input file: $HYPR"
  fi
  exit 0
fi

if [ -n "$HYPR" ] && [ -f "$HYPR" ]; then
  [ -f "$HYPR.bak.altshift" ] || cp "$HYPR" "$HYPR.bak.altshift"
  python3 - "$HYPR" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p).read()
s = re.sub(r'kb_layout\s*=\s*"[^"]*"\s*,', 'kb_layout    = "us,nepali_unicode_romanized",', s)
s = re.sub(r'kb_variant\s*=\s*"[^"]*"\s*,', 'kb_variant   = ",unicode_romanized",', s)
if "kb_options" in s:
    s = re.sub(r'kb_options\s*=\s*"[^"]*"\s*,', 'kb_options   = "grp:alt_shift_toggle",', s)
else:
    s = s.replace("input = {", "input = {\n        kb_options   = \"grp:alt_shift_toggle\",", 1)
open(p, "w").write(s)
PY
  command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1 || true
  echo "Hyprland input updated."
fi

case "${XDG_CURRENT_DESKTOP:-}" in
  *Hyprland*|*hyprland*)
    HYPR_INPUT="$(find -L "$HOME/.config/hypr" -name 'input*.lua' 2>/dev/null | head -n1 || true)"
    if [ -n "$HYPR_INPUT" ] && [ -f "$HYPR_INPUT" ]; then
      [ -f "$HYPR_INPUT.bak.altshift" ] || cp "$HYPR_INPUT" "$HYPR_INPUT.bak.altshift"
      python3 - "$HYPR_INPUT" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p).read()
s = re.sub(r'kb_layout\s*=\s*"[^"]*"\s*,', 'kb_layout    = "us,nepali_unicode_romanized",', s)
s = re.sub(r'kb_variant\s*=\s*"[^"]*"\s*,', 'kb_variant   = ",unicode_romanized",', s)
if "kb_options" in s:
    s = re.sub(r'kb_options\s*=\s*"[^"]*"\s*,', 'kb_options   = "grp:alt_shift_toggle",', s)
else:
    s = s.replace("input = {", "input = {\n        kb_options   = \"grp:alt_shift_toggle\",", 1)
open(p, "w").write(s)
PY
      command -v hyprctl >/dev/null 2>&1 && hyprctl reload >/dev/null 2>&1 || true
      echo "Hyprland input updated."
    else
      echo "Hyprland config not found."
    fi
    ;;
  *GNOME*|*gnome*)
    gsettings set org.gnome.desktop.input-sources sources "[('xkb','us'), ('xkb','nepali_unicode_romanized+unicode_romanized')]"
    gsettings set org.gnome.desktop.input-sources xkb-options "['grp:alt_shift_toggle']"
    echo "GNOME input sources updated."
    ;;
  *KDE*|*KDE*|*Plasma*)
    mkdir -p "$HOME/.config"
    python3 - "$HOME/.config/kxkbrc" <<'PY'
import os, sys, configparser
p = sys.argv[1]
cfg = configparser.ConfigParser()
cfg.read(p)
if not cfg.has_section("Layout"):
    cfg.add_section("Layout")
cfg.set("Layout", "LayoutList", "us,nepali_unicode_romanized")
cfg.set("Layout", "VariantList", ",unicode_romanized")
cfg.set("Layout", "Options", "grp:alt_shift_toggle")
with open(p, "w") as f:
    cfg.write(f)
print("KDE kxkbrc updated:", p)
PY
    ;;
  *)
    if [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
      setxkbmap -layout "us,nepali_unicode_romanized" -variant ",unicode_romanized" -option "grp:alt_shift_toggle" || true
      echo "X11 layout applied for this session."
    else
      echo "Manual configuration required for $XDG_CURRENT_DESKTOP."
    fi
    ;;
esac

echo "Apply complete."
