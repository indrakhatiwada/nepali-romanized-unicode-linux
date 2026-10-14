#!/usr/bin/env python3
import argparse, html, re
from pathlib import Path

MAC2XKB = {
    0: "AC01", 1: "AC02", 2: "AC03", 3: "AC04", 5: "AC05", 4: "AC06",
    38: "AC07", 40: "AC08", 37: "AC09", 41: "AC10", 39: "AC11",
    42: "BKSL", 33: "AD11", 30: "AD12", 35: "AD10", 34: "AD08",
    32: "AD07", 31: "AD09", 16: "AD06", 17: "AD05", 15: "AD04",
    14: "AD03", 13: "AD02", 12: "AD01", 6: "AB01", 7: "AB02",
    8: "AB03", 9: "AB04", 11: "AB05", 45: "AB06", 46: "AB07",
    43: "AB08", 47: "AB09", 44: "AB10", 50: "TLDE", 18: "AE01",
    19: "AE02", 20: "AE03", 21: "AE04", 23: "AE05", 22: "AE06",
    26: "AE07", 28: "AE08", 25: "AE09", 29: "AE10", 27: "AE11",
    24: "AE12",
}

LAYER_MAP = {0: 0, 1: 1, 4: 2, 5: 3}


def parse_keymaps(text):
    out = {}
    for m in re.finditer(r'<keyMap\s+index="(\d+)"\s*>(.*?)</keyMap>', text, re.S):
        out[int(m.group(1))] = {
            int(k.group(1)): html.unescape(k.group(2) or "")
            for k in re.finditer(r'<key code="(\d+)"(?:\s+output="([^"]*)")?/>', m.group(2))
        }
    return out


def keysym(ch):
    if len(ch) == 1 and ord(ch) >= 0x20:
        return "0x100%04X" % ord(ch)
    return None


def convert(src, dst):
    text = Path(src).read_text(encoding="utf-8")
    maps = parse_keymaps(text)
    rows = [
        "default partial alphanumeric_keys",
        'xkb_symbols "unicode_romanized" {',
        '    name[Group1] = "Nepali Unicode Romanized";',
        '    include "level3(ralt_switch)"',
        "",
    ]
    for mac_code, xkb in sorted(MAC2XKB.items(), key=lambda item: item[1]):
        levels = [None, None, None, None]
        for src_idx, dst_idx in LAYER_MAP.items():
            if src_idx not in maps:
                continue
            raw = maps[src_idx].get(mac_code, "")
            if len(raw) == 1:
                value = keysym(raw)
                if value is not None:
                    levels[dst_idx] = value
            elif len(raw) > 1 and mac_code == 21 and src_idx == 1:
                levels[dst_idx] = keysym(raw[0])
        for i in range(4):
            if levels[i] is None:
                levels[i] = levels[0] or "NoSymbol"
        if levels[0] == "NoSymbol":
            continue
        rows.append(
            "    key <%s> { type=\"FOUR_LEVEL\", [ %s, %s, %s, %s ] };"
            % (xkb, levels[0], levels[1], levels[2], levels[3])
        )
    rows.extend(["};", ""])
    Path(dst).write_text("\n".join(rows), encoding="utf-8")
    print("wrote", dst)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("keylayout")
    parser.add_argument("-o", "--output", default="nepali_unicode_romanized")
    args = parser.parse_args()
    convert(args.keylayout, args.output)


if __name__ == "__main__":
    main()
