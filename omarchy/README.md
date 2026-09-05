# Vega Desktop — Omarchy Integration

This folder contains Arch / Omarchy (Hyprland) specific integration for **Vega Desktop** (Tauri + MPV).

## Quick Start

```bash
# 1. Clone (if not already)
cd ~/vega-desktop

# 2. Full install (deps + build + desktop + hyprland)
./install.sh
# or
./scripts/install.sh

# 3. Launch
vega-desktop
# or SUPER + V (added by installer)

# 4. Verify
hyprctl clients | grep -A5 Vega
```

## Scripts

| Script | Purpose |
|--------|---------|
| `install.sh` / `scripts/install.sh` | Full Omarchy installer: pacman deps → npm/cargo build → install binary to `~/.local/bin` + desktop entry + Hyprland rules + SUPER+V |
| `scripts/install.sh --system` | System-wide install to `/opt/vega-desktop` + `/usr/share/applications` (requires sudo) |
| `scripts/install.sh --no-deps` | Skip pacman deps (if you manage deps yourself) |
| `scripts/install.sh --no-build` | Only install desktop/hypr integration (use prebuilt binary) |
| `uninstall.sh` / `scripts/uninstall.sh` | Remove local install; `--purge` wipes Vega data, `--system` removes system install |
| `scripts/build.sh` | `npm ci` + `vite build` + `tauri build` (Linux bundle: deb + AppImage) |
| `scripts/build.sh debug` | Debug bundle (faster, larger) |
| `scripts/dev.sh` | `npm run tauri dev` with Wayland envs (`GDK_BACKEND=wayland,x11`) |
| `scripts/clean.sh` | Remove `dist/` + `src-tauri/target/` + cache |
| `scripts/setup-omarchy.sh` | Only Hyprland + desktop entry, no build |

## What the Installer Does on Omarchy

1. **Dependencies** (`pacman -S` if missing):
   `webkit2gtk-4.1 gtk3 base-devel curl wget file openssl appmenu-gtk-module libappindicator-gtk3 librsvg mpv mpv-mpris nodejs npm rust`

   All are available in Arch repos. `webkit2gtk-4.1` is the WebKitGTK engine Tauri needs; `mpv` + `libmpv` are for the hardware-accelerated player.

2. **Build**:
   - `npm ci` → `npm run build` (Vite + Tailwind)
   - `npx tauri build --config src-tauri/tauri.linux.conf.json` → `src-tauri/target/release/bundle/` (deb, AppImage, binary)

3. **Install**:
   - Local: `~/.local/bin/vega-desktop` → `~/.local/share/applications/vega-desktop.desktop` → icons → `gtk-update-icon-cache`
   - System (`--system`): `/opt/vega-desktop/vega-desktop` + `/usr/bin/vega-desktop` symlink

4. **Hyprland** (Omarchy lua):
   - Copies `omarchy/hypr/vega.lua` → `~/.config/hypr/vega.lua`
   - Auto-wires `pcall(require, "hypr.vega")` into `~/.config/hypr/hyprland.lua`
   - Adds `o.bind("SUPER + V", "Vega", "vega-desktop")` to `~/.config/hypr/bindings.lua`

5. **Theme** (optional):
   ```bash
   bash omarchy/theme/sync-theme.sh
   ```
   Reads `accent` from current Omarchy theme (`colors.toml`) and patches Vega's Tauri store (`primaryColor`). Restart Vega after.

## Hyprland Details

`omarchy/hypr/vega.lua` (`~/.config/hypr/vega.lua:1`) defines:

- Opaque window (`opacity 1 1`, `rounding 12`) — removes default Omarchy translucency which distorts video
- Fullscreen player: `border 0`, `rounding 0`, `idle_inhibit fullscreen`
- Floating file-picker dialogs, PIP support
- Commented `workspace = "4"` if you want Vega pinned to workspace 4

Omarchy's Hyprland is configured via Lua (`/usr/share/omarchy/default/hypr/` + `~/.config/hypr/*.lua`), not `hyprland.conf`. The installer respects that.

## Desktop Entry

`omarchy/desktop/vega.desktop` (`~/.local/share/applications/vega-desktop.desktop:1`):

- `Exec=vega-desktop` (patched to absolute path on local install)
- `Categories=AudioVideo;Player;Video`
- `StartupWMClass=Vega` (matches `tauri.conf.json:identifier = com.vega.desktop`, `productName = Vega`)
- Wayland wrapper `omarchy/desktop/vega-wayland.sh` available for manual use.

## Tauri Config

- `src-tauri/tauri.conf.json:34` — Linux deb depends `["libmpv2","mpv"]` (Debian) + `appimage.bundleMediaFramework`
- `src-tauri/tauri.linux.conf.json:1` — Linux overlay: bundles `lib/*.so`, expands deb deps to include `webkit2gtk-4.1`, and enlarges default window to `1280x800` (better for media) with `minWidth/minHeight`.
- `src-tauri/build.rs:10` — copies `libmpv-wrapper.so` + `libmpv.so` next to binary for runtime loading (Linux/macOS/Windows).

## Wayland Notes (Omarchy)

Hyprland is Wayland-native. Tauri/WebKitGTK respects:

```
GDK_BACKEND=wayland,x11
WEBKIT_DISABLE_DMABUF_RENDERER=0   # set in scripts/dev.sh & vega-wayland.sh
```

If you see blank window or DMABuf errors, run via `omarchy/desktop/vega-wayland.sh` or set `WEBKIT_DISABLE_DMABUF_RENDERER=1`.

## Manual Steps (if you skip installer)

```bash
mkdir -p ~/.config/hypr
cp omarchy/hypr/vega.lua ~/.config/hypr/vega.lua
echo 'pcall(require, "hypr.vega")' >> ~/.config/hypr/hyprland.lua
echo 'o.bind("SUPER + V", "Vega", "vega-desktop")' >> ~/.config/hypr/bindings.lua
hyprctl reload

mkdir -p ~/.local/share/applications
cp omarchy/desktop/vega.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications
```

## PKGBUILD

For AUR-style install:

```bash
makepkg -si
# or
yay -S vega-desktop  # after publishing
```

See `PKGBUILD:1`.

## Uninstall

```bash
./uninstall.sh                # local
./uninstall.sh --purge        # + wipe ~/.local/share/com.vega.desktop
./uninstall.sh --system       # system-wide
./uninstall.sh --keep-hypr    # keep Hyprland rules
```

## Troubleshooting

- **Missing libmpv**: `sudo pacman -S mpv libmpv` and rebuild; check `src-tauri/lib/` contains `libmpv.so`
- **Blank WebView**: `WEBKIT_DISABLE_DMABUF_RENDERER=1 vega-desktop`
- **No window decorations**: intentional (`decorations: false` + `transparent: true`); Hyprland draws borders via `vega.lua`
- **SUPER+V not working**: `hyprctl reload` or check `~/.config/hypr/bindings.lua` for conflicts, then `omarchy menu keybindings --print`

## Upstream Docs

- Tauri prerequisites: https://tauri.app/v1/guides/getting-started/prerequisites
- Hyprland wiki: https://wiki.hypr.land/Configuring/Window-Rules/
- Omarchy manual: https://learn.omacom.io/2/the-omarchy-manual
