#!/usr/bin/env bash
set -euo pipefail

LAYOUT="nepali_unicode_romanized"
VARIANT="unicode_romanized"
XKB="${XDG_CONFIG_HOME:-$HOME/.config}/xkb"
SYSXML="/usr/share/X11/xkb/rules/evdev.xml"
RULES="$XKB/rules/evdev.xml"

CHECK=0
YES=0
SYSTEM=0
for arg in "$@"; do
  case "$arg" in
    --check) CHECK=1 ;;
    --yes) YES=1 ;;
    --system) SYSTEM=1 ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

if [ "$CHECK" -eq 1 ]; then
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  python3 - "$tmpdir/$LAYOUT" <<'PY'
import sys
SOURCE = r"""default partial alphanumeric_keys
xkb_symbols "unicode_romanized" {
    name[Group1] = "Nepali Unicode Romanized";
    include "level3(ralt_switch)"

    key <AB01> { type="FOUR_LEVEL", [ 0x1000937, 0x100090B, 0x100007A, 0x100005A ] };
    key <AB02> { type="FOUR_LEVEL", [ 0x1000921, 0x1000922, 0x1000078, 0x1000058 ] };
    key <AB03> { type="FOUR_LEVEL", [ 0x100091A, 0x100091B, 0x1000063, 0x1000043 ] };
    key <AB04> { type="FOUR_LEVEL", [ 0x1000935, 0x1000901, 0x1000076, 0x1000056 ] };
    key <AB05> { type="FOUR_LEVEL", [ 0x100092C, 0x100092D, 0x1000062, 0x1000042 ] };
    key <AB06> { type="FOUR_LEVEL", [ 0x1000928, 0x1000923, 0x100006E, 0x100004E ] };
    key <AB07> { type="FOUR_LEVEL", [ 0x100092E, 0x1000902, 0x100006D, 0x100004D ] };
    key <AB08> { type="FOUR_LEVEL", [ 0x100002C, 0x1000919, 0x100003C, 0x100003C ] };
    key <AB09> { type="FOUR_LEVEL", [ 0x1000964, 0x100002E, 0x100003E, 0x100003E ] };
    key <AB10> { type="FOUR_LEVEL", [ 0x100094D, 0x100003F, 0x100002F, 0x100003F ] };
    key <AC01> { type="FOUR_LEVEL", [ 0x100093E, 0x1000906, 0x1000061, 0x1000041 ] };
    key <AC02> { type="FOUR_LEVEL", [ 0x1000938, 0x1000936, 0x1000073, 0x1000053 ] };
    key <AC03> { type="FOUR_LEVEL", [ 0x1000926, 0x1000927, 0x1000064, 0x1000044 ] };
    key <AC04> { type="FOUR_LEVEL", [ 0x1000909, 0x100090A, 0x1000066, 0x1000046 ] };
    key <AC05> { type="FOUR_LEVEL", [ 0x1000917, 0x1000918, 0x1000067, 0x1000047 ] };
    key <AC06> { type="FOUR_LEVEL", [ 0x1000939, 0x1000905, 0x1000068, 0x1000048 ] };
    key <AC07> { type="FOUR_LEVEL", [ 0x100091C, 0x100091D, 0x100006A, 0x100004A ] };
    key <AC08> { type="FOUR_LEVEL", [ 0x1000915, 0x1000916, 0x100006B, 0x100004B ] };
    key <AC09> { type="FOUR_LEVEL", [ 0x1000932, 0x1000965, 0x100006C, 0x100004C ] };
    key <AC10> { type="FOUR_LEVEL", [ 0x100003B, 0x100003A, 0x100003B, 0x100003A ] };
    key <AC11> { type="FOUR_LEVEL", [ 0x1000027, 0x1000022, 0x1000027, 0x1000022 ] };
    key <AD01> { type="FOUR_LEVEL", [ 0x100091F, 0x1000920, 0x1000071, 0x1000051 ] };
    key <AD02> { type="FOUR_LEVEL", [ 0x100094C, 0x1000914, 0x1000077, 0x1000057 ] };
    key <AD03> { type="FOUR_LEVEL", [ 0x1000947, 0x1000948, 0x1000065, 0x1000045 ] };
    key <AD04> { type="FOUR_LEVEL", [ 0x1000930, 0x1000943, 0x1000072, 0x1000052 ] };
    key <AD05> { type="FOUR_LEVEL", [ 0x1000924, 0x1000925, 0x1000074, 0x1000054 ] };
    key <AD06> { type="FOUR_LEVEL", [ 0x100092F, 0x100091E, 0x1000079, 0x1000059 ] };
    key <AD07> { type="FOUR_LEVEL", [ 0x1000941, 0x1000942, 0x1000075, 0x1000055 ] };
    key <AD08> { type="FOUR_LEVEL", [ 0x100093F, 0x1000940, 0x1000069, 0x1000049 ] };
    key <AD09> { type="FOUR_LEVEL", [ 0x100094B, 0x1000913, 0x100006F, 0x100004F ] };
    key <AD10> { type="FOUR_LEVEL", [ 0x100092A, 0x100092B, 0x1000070, 0x1000050 ] };
    key <AD11> { type="FOUR_LEVEL", [ 0x1000907, 0x1000908, 0x100005B, 0x100007B ] };
    key <AD12> { type="FOUR_LEVEL", [ 0x100090F, 0x1000910, 0x100005D, 0x100007D ] };
    key <AE01> { type="FOUR_LEVEL", [ 0x1000967, 0x1000021, 0x1000031, 0x1000021 ] };
    key <AE02> { type="FOUR_LEVEL", [ 0x1000968, 0x1000040, 0x1000032, 0x1000040 ] };
    key <AE03> { type="FOUR_LEVEL", [ 0x1000969, 0x1000023, 0x1000033, 0x1000023 ] };
    key <AE04> { type="FOUR_LEVEL", [ 0x100096A, 0x1000930, 0x1000034, 0x1000024 ] };
    key <AE05> { type="FOUR_LEVEL", [ 0x100096B, 0x1000025, 0x1000035, 0x1000025 ] };
    key <AE06> { type="FOUR_LEVEL", [ 0x100096C, 0x100005E, 0x1000036, 0x100005E ] };
    key <AE07> { type="FOUR_LEVEL", [ 0x100096D, 0x1000026, 0x1000037, 0x1000026 ] };
    key <AE08> { type="FOUR_LEVEL", [ 0x100096E, 0x100002A, 0x1000038, 0x100002A ] };
    key <AE09> { type="FOUR_LEVEL", [ 0x100096F, 0x1000028, 0x1000039, 0x1000028 ] };
    key <AE10> { type="FOUR_LEVEL", [ 0x1000966, 0x1000029, 0x1000030, 0x1000029 ] };
    key <AE11> { type="FOUR_LEVEL", [ 0x100002D, 0x100005F, 0x100002D, 0x100005F ] };
    key <AE12> { type="FOUR_LEVEL", [ 0x100200D, 0x100200C, 0x100003D, 0x100002B ] };
    key <BKSL> { type="FOUR_LEVEL", [ 0x1000950, 0x1000903, 0x100005C, 0x100007C ] };
    key <TLDE> { type="FOUR_LEVEL", [ 0x100093C, 0x100093D, 0x1000060, 0x100007E ] };
};
"""
open(sys.argv[1], "w", encoding="utf-8").write(SOURCE)
PY
  xkbcli compile-keymap --include "$tmpdir" --include-defaults --rules evdev --layout "$LAYOUT" --variant "$VARIANT" --test
  echo "check: layout compiles successfully"
  exit 0
fi

if [ "$SYSTEM" -eq 1 ]; then
  BASE="/usr/share/X11/xkb"
  NEED_SUDO="sudo"
else
  BASE="${XDG_CONFIG_HOME:-$HOME/.config}/xkb"
  NEED_SUDO=""
fi

mkdir -p "$BASE/symbols" "$BASE/rules"

python3 - "$BASE/symbols/$LAYOUT" <<'PY'
import sys
SOURCE = r"""default partial alphanumeric_keys
xkb_symbols "unicode_romanized" {
    name[Group1] = "Nepali Unicode Romanized";
    include "level3(ralt_switch)"

    key <AB01> { type="FOUR_LEVEL", [ 0x1000937, 0x100090B, 0x100007A, 0x100005A ] };
    key <AB02> { type="FOUR_LEVEL", [ 0x1000921, 0x1000922, 0x1000078, 0x1000058 ] };
    key <AB03> { type="FOUR_LEVEL", [ 0x100091A, 0x100091B, 0x1000063, 0x1000043 ] };
    key <AB04> { type="FOUR_LEVEL", [ 0x1000935, 0x1000901, 0x1000076, 0x1000056 ] };
    key <AB05> { type="FOUR_LEVEL", [ 0x100092C, 0x100092D, 0x1000062, 0x1000042 ] };
    key <AB06> { type="FOUR_LEVEL", [ 0x1000928, 0x1000923, 0x100006E, 0x100004E ] };
    key <AB07> { type="FOUR_LEVEL", [ 0x100092E, 0x1000902, 0x100006D, 0x100004D ] };
    key <AB08> { type="FOUR_LEVEL", [ 0x100002C, 0x1000919, 0x100003C, 0x100003C ] };
    key <AB09> { type="FOUR_LEVEL", [ 0x1000964, 0x100002E, 0x100003E, 0x100003E ] };
    key <AB10> { type="FOUR_LEVEL", [ 0x100094D, 0x100003F, 0x100002F, 0x100003F ] };
    key <AC01> { type="FOUR_LEVEL", [ 0x100093E, 0x1000906, 0x1000061, 0x1000041 ] };
    key <AC02> { type="FOUR_LEVEL", [ 0x1000938, 0x1000936, 0x1000073, 0x1000053 ] };
    key <AC03> { type="FOUR_LEVEL", [ 0x1000926, 0x1000927, 0x1000064, 0x1000044 ] };
    key <AC04> { type="FOUR_LEVEL", [ 0x1000909, 0x100090A, 0x1000066, 0x1000046 ] };
    key <AC05> { type="FOUR_LEVEL", [ 0x1000917, 0x1000918, 0x1000067, 0x1000047 ] };
    key <AC06> { type="FOUR_LEVEL", [ 0x1000939, 0x1000905, 0x1000068, 0x1000048 ] };
    key <AC07> { type="FOUR_LEVEL", [ 0x100091C, 0x100091D, 0x100006A, 0x100004A ] };
    key <AC08> { type="FOUR_LEVEL", [ 0x1000915, 0x1000916, 0x100006B, 0x100004B ] };
    key <AC09> { type="FOUR_LEVEL", [ 0x1000932, 0x1000965, 0x100006C, 0x100004C ] };
    key <AC10> { type="FOUR_LEVEL", [ 0x100003B, 0x100003A, 0x100003B, 0x100003A ] };
    key <AC11> { type="FOUR_LEVEL", [ 0x1000027, 0x1000022, 0x1000027, 0x1000022 ] };
    key <AD01> { type="FOUR_LEVEL", [ 0x100091F, 0x1000920, 0x1000071, 0x1000051 ] };
    key <AD02> { type="FOUR_LEVEL", [ 0x100094C, 0x1000914, 0x1000077, 0x1000057 ] };
    key <AD03> { type="FOUR_LEVEL", [ 0x1000947, 0x1000948, 0x1000065, 0x1000045 ] };
    key <AD04> { type="FOUR_LEVEL", [ 0x1000930, 0x1000943, 0x1000072, 0x1000052 ] };
    key <AD05> { type="FOUR_LEVEL", [ 0x1000924, 0x1000925, 0x1000074, 0x1000054 ] };
    key <AD06> { type="FOUR_LEVEL", [ 0x100092F, 0x100091E, 0x1000079, 0x1000059 ] };
    key <AD07> { type="FOUR_LEVEL", [ 0x1000941, 0x1000942, 0x1000075, 0x1000055 ] };
    key <AD08> { type="FOUR_LEVEL", [ 0x100093F, 0x1000940, 0x1000069, 0x1000049 ] };
    key <AD09> { type="FOUR_LEVEL", [ 0x100094B, 0x1000913, 0x100006F, 0x100004F ] };
    key <AD10> { type="FOUR_LEVEL", [ 0x100092A, 0x100092B, 0x1000070, 0x1000050 ] };
    key <AD11> { type="FOUR_LEVEL", [ 0x1000907, 0x1000908, 0x100005B, 0x100007B ] };
    key <AD12> { type="FOUR_LEVEL", [ 0x100090F, 0x1000910, 0x100005D, 0x100007D ] };
    key <AE01> { type="FOUR_LEVEL", [ 0x1000967, 0x1000021, 0x1000031, 0x1000021 ] };
    key <AE02> { type="FOUR_LEVEL", [ 0x1000968, 0x1000040, 0x1000032, 0x1000040 ] };
    key <AE03> { type="FOUR_LEVEL", [ 0x1000969, 0x1000023, 0x1000033, 0x1000023 ] };
    key <AE04> { type="FOUR_LEVEL", [ 0x100096A, 0x1000930, 0x1000034, 0x1000024 ] };
    key <AE05> { type="FOUR_LEVEL", [ 0x100096B, 0x1000025, 0x1000035, 0x1000025 ] };
    key <AE06> { type="FOUR_LEVEL", [ 0x100096C, 0x100005E, 0x1000036, 0x100005E ] };
    key <AE07> { type="FOUR_LEVEL", [ 0x100096D, 0x1000026, 0x1000037, 0x1000026 ] };
    key <AE08> { type="FOUR_LEVEL", [ 0x100096E, 0x100002A, 0x1000038, 0x100002A ] };
    key <AE09> { type="FOUR_LEVEL", [ 0x100096F, 0x1000028, 0x1000039, 0x1000028 ] };
    key <AE10> { type="FOUR_LEVEL", [ 0x1000966, 0x1000029, 0x1000030, 0x1000029 ] };
    key <AE11> { type="FOUR_LEVEL", [ 0x100002D, 0x100005F, 0x100002D, 0x100005F ] };
    key <AE12> { type="FOUR_LEVEL", [ 0x100200D, 0x100200C, 0x100003D, 0x100002B ] };
    key <BKSL> { type="FOUR_LEVEL", [ 0x1000950, 0x1000903, 0x100005C, 0x100007C ] };
    key <TLDE> { type="FOUR_LEVEL", [ 0x100093C, 0x100093D, 0x1000060, 0x100007E ] };
};
"""
open(sys.argv[1], "w", encoding="utf-8").write(SOURCE)
PY

if [ ! -f "$RULES" ]; then
  $NEED_SUDO cp "$SYSXML" "$RULES"
fi

$NEED_SUDO python3 - "$RULES" <<'PY'
import sys, xml.etree.ElementTree as ET
p = sys.argv[1]
t = ET.parse(p)
root = t.getroot()
ll = None
for e in root.iter():
    if e.tag == "layoutList":
        ll = e
        break
if ll is None:
    raise SystemExit("no layoutList in evdev.xml")
for layout in list(ll.findall("layout")):
    ci = layout.find("configItem")
    if ci is not None:
        nm = ci.find("name")
        if nm is not None and nm.text in ("nepali_mac", "nepali_unicode_romanized"):
            ll.remove(layout)
t.write(p, encoding="utf-8", xml_declaration=True)
t = ET.parse(p)
root = t.getroot()
ll = None
for e in root.iter():
    if e.tag == "layoutList":
        ll = e
        break
layout = ET.SubElement(ll, "layout")
ci = ET.SubElement(layout, "configItem")
ET.SubElement(ci, "name").text = "nepali_unicode_romanized"
ET.SubElement(ci, "shortDescription").text = "ne"
ET.SubElement(ci, "description").text = "Nepali Unicode Romanized"
l = ET.SubElement(ci, "languageList")
ET.SubElement(l, "iso639Id").text = "nep"
v = ET.SubElement(layout, "variantList")
vc = ET.SubElement(v, "variant")
vci = ET.SubElement(vc, "configItem")
ET.SubElement(vci, "name").text = "unicode_romanized"
ET.SubElement(vci, "description").text = "Unicode Romanized"
t.write(p, encoding="utf-8", xml_declaration=True)
print("registered nepali_unicode_romanized in", p)
PY

HYPR_INPUT=""
if [ -d "$HOME/.config/hypr" ]; then
  HYPR_INPUT="$(find -L "$HOME/.config/hypr" -name 'input*.lua' 2>/dev/null | head -n1 || true)"
fi
if [ -n "$HYPR_INPUT" ] && [ -f "$HYPR_INPUT" ]; then
  if [ "$YES" -eq 1 ] || { read -r -p "Preview Hyprland input patch? [y/N] " _hypr; [ "${_hypr:-}" = "y" ]; }; then
    python3 - "$HYPR_INPUT" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p).read()
s2 = s
s2 = re.sub(r'kb_layout\s*=\s*"[^"]*"\s*,', 'kb_layout    = "us,nepali_unicode_romanized",', s2)
s2 = re.sub(r'kb_variant\s*=\s*"[^"]*"\s*,', 'kb_variant   = ",unicode_romanized",', s2)
if "kb_options" in s2:
    s2 = re.sub(r'kb_options\s*=\s*"[^"]*"\s*,', 'kb_options   = "grp:alt_shift_toggle",', s2)
else:
    s2 = s2.replace("input = {", "input = {\n        kb_options   = \"grp:alt_shift_toggle\",", 1)
print(s2)
PY
    if [ "$YES" -eq 1 ] || { read -r -p "Apply? [y/N] " _apply; [ "${_apply:-}" = "y" ]; }; then
      cp "$HYPR_INPUT" "$HYPR_INPUT.bak.altshift" 2>/dev/null || true
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
      echo "Skipped Hyprland patch."
    fi
  fi
fi

xkbcli compile-keymap --include "$BASE" --include-defaults --rules evdev --layout "nepali_unicode_romanized" --variant "unicode_romanized" --test
echo "Install complete. Alt+Shift toggles English (US) <-> Nepali Unicode Romanized."
