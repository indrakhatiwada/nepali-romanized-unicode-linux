#!/usr/bin/env bash
set -euo pipefail
XKB="${XDG_CONFIG_HOME:-$HOME/.config}/xkb"
rm -f "$XKB/symbols/nepali_unicode_romanized"
echo "Removed user-level layout (registry entry left intact)."
