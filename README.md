<div align="center">

![Vega](https://github.com/Zenda-Cross/vega-app/assets/143804558/b2eb446f-8e7f-4800-81e1-3320c82f33de)

# Vega Desktop

**Native. Ad-free. MPV-powered.**

Bring your own sources · Stream & download · Sync with mobile

[![Version](https://img.shields.io/badge/version-2.0.5-9e6cff?style=flat-square)](src-tauri/tauri.conf.json)
[![Tauri](https://img.shields.io/badge/Tauri-2.0-24C8DB?style=flat-square&logo=tauri&logoColor=white)](https://tauri.app)
[![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react&logoColor=black)](https://react.dev)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Windows%20%7C%20macOS-lightgrey?style=flat-square)](#download)
[![Downloads](https://img.shields.io/github/downloads/vega-org/vega-desktop/total?style=flat-square&label=downloads)](https://github.com/vega-org/vega-desktop/releases)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](#)

[Download](https://github.com/vega-org/vega-desktop/releases/latest) · [Mobile App](https://github.com/vega-org/vega-app) · [Providers Guide](https://vega.8man.in/guide/adding-providers/) · [Discord](https://discord.gg/cr42m6maWy)

</div>

---

### Features

- **BYOS** — bring your own extensions
- **MPV** — hardware-accelerated, desktop-native player
- **Ad-free** — stream & download, multi-audio, external subs
- **Watchlist & history** — sync with Vega mobile
- **Torrents, DoH, local proxy** — built-in

> Vega does not host or provide any media. All content is sourced by the user via providers/extensions.

---

### Screenshots

<img width="2047" alt="Vega Home" src="https://github.com/user-attachments/assets/ade6354c-cc1c-448a-a353-dc6912246471" />

<details>
<summary>More</summary>

<img width="853" alt="Search" src="https://github.com/user-attachments/assets/28e7a630-a822-4dc5-9a26-f102ac3b0240" />
<img width="853" alt="Player" src="https://github.com/user-attachments/assets/43f2119a-b61c-498e-8421-00cd9ca8f3da" />
<img width="2042" alt="Details" src="https://github.com/user-attachments/assets/ad8692ac-d9ed-4784-b4e1-3243cd16d966" />

</details>

---

### Download

| Platform | Artifact |
|----------|----------|
| Linux (Omarchy/Arch) | `AppImage` · `.deb` · `PKGBUILD` — see below |
| Windows | `.msi` / `.exe` — [Releases](https://github.com/vega-org/vega-desktop/releases/latest) · [Microsoft Store](https://apps.microsoft.com/detail/9n3fdt30wdlb?referrer=appbadge&mode=full) |
| macOS | `.dmg` — [Releases](https://github.com/vega-org/vega-desktop/releases/latest) |

---

### Omarchy / Arch — one command

Optimized for **Omarchy 4+ · Hyprland 0.56 · Arch**.

```bash
git clone https://github.com/vega-org/vega-desktop.git
cd vega-desktop
./install.sh              # deps → build → ~/.local/bin + Hyprland + SUPER+V
```

Launch with `SUPER+V` or:

```bash
vega-desktop
```

<details>
<summary>What it does</summary>

- Installs `webkit2gtk-4.1 gtk3 mpv libmpv nodejs rust` via `pacman` (if missing)
- `npm ci` + `vite build` + `tauri build` (AppImage + deb)
- Installs to `~/.local/bin/vega-desktop` + `~/.local/share/applications/vega-desktop.desktop`
- Adds Hyprland rules (`~/.config/hypr/vega.lua`) — opaque window, fullscreen player, floating dialogs
- Binds `SUPER+V`

See [`omarchy/README.md`](omarchy/README.md) for full details.

</details>

**Options**

```bash
./install.sh --system      # → /opt/vega-desktop + /usr/share/applications (sudo)
./install.sh --no-deps     # skip pacman
./install.sh --no-build    # only desktop + Hyprland (use prebuilt binary)
./uninstall.sh             # remove
./uninstall.sh --purge     # + wipe data
```

**Other helpers**

```bash
./scripts/dev.sh           # tauri dev with Wayland envs
./scripts/build.sh         # production bundles
./scripts/build.sh debug   # fast debug bundle
./scripts/clean.sh         # wipe dist + target
bash omarchy/theme/sync-theme.sh  # sync Omarchy accent → Vega
```

**Hyprland**

- Rule: `omarchy/hypr/vega.lua` → `~/.config/hypr/vega.lua`
- Auto-wired: `pcall(require, "hypr.vega")` in `hyprland.lua`
- Wayland: `GDK_BACKEND=wayland,x11` — if blank window, try `WEBKIT_DISABLE_DMABUF_RENDERER=1 vega-desktop`
- Manual reload: `hyprctl reload`

**PKGBUILD**

```bash
makepkg -si
```

---

### Generic Linux

```bash
# Tauri prerequisites: https://tauri.app/start/prerequisites/
npm install
npm run tauri dev        # dev
npm run tauri build      # → src-tauri/target/release/bundle/
```

Deb depends: `libmpv2, mpv` (Debian) · Arch: `mpv libmpv webkit2gtk-4.1`

---

### Windows & macOS

```bash
npm install
npm run tauri dev
npm run tauri build      # .exe / .msi / .dmg
```

Prerequisites: [Tauri Setup](https://tauri.app/start/prerequisites/)

---

### Providers

> [!TIP]
> Adding sources: **https://vega.8man.in/guide/adding-providers/**

---

### Development

```bash
git clone https://github.com/vega-org/vega-desktop.git
cd vega-desktop
npm install
./scripts/dev.sh          # or: npm run tauri dev
```

| Script | Description |
|--------|-------------|
| `dev` | Vite dev server |
| `build` | Typecheck + Vite build |
| `tauri dev` | App + HMR (port 1420) |
| `tauri build` | Production bundles |

**Stack** — Tauri 2 · React 19 · TypeScript · Vite · Zustand · Tailwind 4 · MPV

```
src/          → React app (pages, components, lib)
src-tauri/    → Rust backend (MPV, torrent, DoH, store)
omarchy/      → Hyprland + desktop + theme (Arch)
scripts/      → install / build / dev helpers
```

---

### Troubleshooting

**Blank window on Hyprland** → `WEBKIT_DISABLE_DMABUF_RENDERER=1 vega-desktop` or use `omarchy/desktop/vega-wayland.sh`

**Missing libmpv** → `sudo pacman -S mpv libmpv` and rebuild. Check `src-tauri/lib/` has `libmpv.so`

**No decorations** → intentional (`transparent: true`, `decorations: false`); borders drawn by Hyprland via `vega.lua`

**SUPER+V not working** → `hyprctl reload` and `omarchy menu keybindings --print`

---

<div align="center">

[![Discord](https://custom-icon-badges.demolab.com/badge/-Join_Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/cr42m6maWy)
[![Download](https://custom-icon-badges.demolab.com/badge/-Download-black?style=for-the-badge&logo=download&logoColor=white)](https://github.com/vega-org/vega-desktop/releases/latest)

**If Vega is useful, leave a star ⭐**

<a href="https://www.star-history.com/?repos=vega-org%2Fvega-desktop&type=date&legend=top-left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=vega-org/vega-desktop&type=date&theme=dark&legend=top-left&sealed_token=Mc7MDJCA35XmRx1ycfPVcXq4cnRqiQX_7PruvIWc6XGQhApqIDC79vStshevTXUwV5VoBB63uYI1HQQF2L7zvc4jBzX7NYHYo4k9fW2pPLbuMbk_hfLD_w" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=vega-org/vega-desktop&type=date&legend=top-left&sealed_token=Mc7MDJCA35XmRx1ycfPVcXq4cnRqiQX_7PruvIWc6XGQhApqIDC79vStshevTXUwV5VoBB63uYI1HQQF2L7zvc4jBzX7NYHYo4k9fW2pPLbuMbk_hfLD_w" />
    <img alt="Star History" src="https://api.star-history.com/chart?repos=vega-org/vega-desktop&type=date&legend=top-left&sealed_token=Mc7MDJCA35XmRx1ycfPVcXq4cnRqiQX_7PruvIWc6XGQhApqIDC79vStshevTXUwV5VoBB63uYI1HQQF2L7zvc4jBzX7NYHYo4k9fW2pPLbuMbk_hfLD_w" />
  </picture>
</a>

<sub>Vega Desktop does not host, store, or provide any media content. Not affiliated with any provider/extension.</sub>

</div>
