#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYS="/usr/share/X11/xkb"
sudo cp "$DIR/nepali_unicode_romanized" "$SYS/symbols/nepali_unicode_romanized"
if ! grep -q "nepali_unicode_romanized" "$SYS/rules/evdev.xml"; then
  sudo python3 "$DIR/register-layout.py" "$SYS/rules/evdev.xml"
fi
echo "System-wide install complete."
