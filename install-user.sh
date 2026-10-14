#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XKB="${XDG_CONFIG_HOME:-$HOME/.config}/xkb"
mkdir -p "$XKB/symbols" "$XKB/rules"
cp "$DIR/nepali_unicode_romanized" "$XKB/symbols/nepali_unicode_romanized"

rm -f "$XKB/symbols/nepali_mac"
SYSXML="/usr/share/X11/xkb/rules/evdev.xml"
RULES="$XKB/rules/evdev.xml"
if [ ! -f "$RULES" ]; then
  cp "$SYSXML" "$RULES"
fi
python3 - "$RULES" <<'PY'
import sys, xml.etree.ElementTree as ET
p=sys.argv[1]; t=ET.parse(p); root=t.getroot()
ll=None
for e in root.iter():
    if e.tag=="layoutList": ll=e; break
if ll is None: raise SystemExit("no layoutList")
changed=False
for layout in list(ll.findall("layout")):
    ci=layout.find("configItem")
    if ci is not None:
        nm=ci.find("name")
        if nm is not None and nm.text in ("nepali_mac","nepali_unicode_romanized"):
            ll.remove(layout); changed=True
if changed:
    t.write(p, encoding="utf-8", xml_declaration=True)
PY

python3 "$DIR/register-layout.py" "$RULES"
echo "Installed to $XKB"
echo "Reload your session or run: hyprctl reload"
