# Nepali Unicode Romanized for Linux

Primary target: **Arch Linux** (Hyprland/Wayland tested).
Also supported: Debian/Ubuntu and Fedora.

Converted from the macOS `Nepali Romanized Unicode.keylayout`
(`/tmp/opencode/nepali_romanized_for_mac_fnfx5xz.zip`) into an XKB layout usable
on modern Linux (X11 and Wayland via libxkbcommon).

## Generated identifiers
- Layout (XKB): `nepali_unicode_romanized`
- Variant: `unicode_romanized`
- Display name: **Nepali Unicode Romanized**

## Requirements
- Python 3
- `xkbcli` or `xkbcomp` (usually from `libxkbcommon` / `xkeyboard-config`)
- `setxkbmap` for X11 sessions (optional)

## One-line verified install
```bash
tmp=$(mktemp -d)
curl -fsSL https://YOUR-HOST/install-nepali-unicode-romanized.sh -o "$tmp/install.sh"
curl -fsSL https://YOUR-HOST/install.sha256 -o "$tmp/install.sha256"
(cd "$tmp" && sha256sum -c install.sha256) || exit 1
bash "$tmp/install.sh" --yes
```

## Quick test (no install)
```bash
xkbcli compile-keymap \
  --include "$(pwd)/xkb" --include-defaults \
  --rules evdev \
  --layout nepali_unicode_romanized --variant unicode_romanized --test
```
Should exit with code `0`.

## Install — user-level (no sudo, recommended)
```bash
cd /home/indra/Desktop/exp/nepali-romanized-linux
./install-user.sh
```
This installs into `~/.config/xkb` and registers the layout in
`~/.config/xkb/rules/evdev.xml`. It also migrates/removes the older
`nepali_mac` artifact if present.

## Install — system-wide (sudo)
```bash
sudo ./install-system.sh
```

## Activate

### Ubuntu / Debian notes
- Prerequisites: `sudo apt install xkb-data libxkbcommon-tools python3 whiptail`
- Optional Devanagari fonts: `sudo apt install fonts-noto`

### Fedora notes
- Prerequisites: `sudo dnf install xkeyboard-config libxkbcommon-tools python3 libnewt`
- Optional Devanagari fonts: `sudo dnf install google-noto-sans-devanagari-fonts`
- On KDE Plasma: `./enable-alt-shift.sh` writes `~/.config/kxkbrc`

### Hyprland (Wayland)
The installer keeps your current Hypr config; to switch with **Alt+Shift**, either run:
```bash
./enable-alt-shift.sh
```
or manually add to `~/.config/hypr/input.lua`:
```lua
kb_layout    = "us,nepali_unicode_romanized",
kb_variant   = ",unicode_romanized",
kb_options   = "grp:alt_shift_toggle",
```
then `hyprctl reload`.

### GNOME (Wayland/X11)
```bash
./enable-alt-shift.sh
```
or manually:
```bash
gsettings set org.gnome.desktop.input-sources sources "[('xkb','us'), ('xkb','nepali_unicode_romanized+unicode_romanized')]"
gsettings set org.gnome.desktop.input-sources xkb-options "['grp:alt_shift_toggle']"
```

### KDE Plasma (X11/Wayland)
Set `~/.config/kxkbrc`:
```ini
[Layout]
LayoutList=us,nepali_unicode_romanized
VariantList=,unicode_romanized
Options=grp:alt_shift_toggle
```
Then log out and back in.

### X11 (other desktops)
```bash
setxkbmap -layout "us,nepali_unicode_romanized" -variant ",unicode_romanized" -option "grp:alt_shift_toggle"
```
and persist it in `~/.xprofile` or your display manager setup.

### Disable the Alt+Shift toggle
```bash
./disable-alt-shift.sh
```

## Test the XKB compile
```bash
xkbcli compile-keymap \
  --include "$HOME/.config/xkb" --include-defaults \
  --rules evdev --layout nepali_unicode_romanized --variant unicode_romanized --test
echo "compile exit: $?"
```

## Interactive installer (whiptail)
```bash
./install-nepali-tui.sh
```
Runs a dialog-based installer that asks for scope (`user` / `system`), optionally installs Noto Devanagari fonts, validates XKB compilation, and enables Alt+Shift.

## Go terminal UI (Bubble Tea)
Build:
```bash
cd installer
go build -o nepali-tui-installer
./nepali-tui-installer
```
Features: scope selection, optional fonts, validation, verified command output.

## Uninstall
```bash
./uninstall-user.sh
sudo ./uninstall-system.sh
```

## Regenerate from the Mac source
```bash
python3 convert.py "source/Nepali Romaized for mac/Nepali Romanized Unicode.keylayout" -o nepali_unicode_romanized
cp nepali_unicode_romanized xkb/symbols/nepali_unicode_romanized
./install-user.sh
```

## Known limitations
1. XKB emits **one keysym per key level**. The macOS layout’s single multi-character
   output `रु.` (Shift+4) cannot be reproduced on one key; this conversion keeps
   the first character only and documents the gap. Full parity (including strings)
   would require an IBus/m17n engine.
2. Modifier layers are simplified to four levels:
   base / shift / AltGr / Shift+AltGr. macOS Caps/Command behavior is normalized.
3. Some terminals (kitty, Alacritty) may not auto-fallback for Devanagari.
   Use `Noto Sans Devanagari` as the font or a terminal with HarfBuzz shaping
   (e.g. `foot`) if glyphs show as boxes (tofu).
4. On Wayland compositors, reload/re-login after install so the new layout is
   picked up by applications.
