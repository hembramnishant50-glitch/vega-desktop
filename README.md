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
- **MPV** — hardware-accelerated, desktop-native player (uses system mpv)
- **Ad-free** — stream & download, multi-audio, external subs
- **Watchlist & history** — sync with Vega mobile
- **Torrents, DoH, local proxy** — built-in
- **Omarchy Settings** — in-app settings for Hyprland window rules, theme sync, keybindings

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
| Windows | `.msi` / `.exe` — [Releases](https://github.com/vega-org/vega-desktop/releases/latest) |
| macOS | `.dmg` — [Releases](https://github.com/vega-org/vega-desktop/releases/latest) |

---

### Omarchy / Arch — install

Optimized for **Omarchy 4+ · Hyprland 0.56 · Arch**.

```bash
# clone the repo
git clone https://github.com/hembramnishant50-glitch/vega-desktop.git
cd vega-desktop

# install (builds + sets up desktop entry + Hyprland rules)
bash scripts/omarchy/install.sh
```

Launch from app launcher as **Vega**, or:

```bash
vega
```

<details>
<summary>What install.sh does</summary>

- Checks/installs system packages (`webkit2gtk-4.1 gtk3 librsvg pkgconf base-devel ffmpeg mpv`) via `pacman`
- Installs Rust toolchain via `rustup` if missing
- Runs `npm ci` + `vite build` + `tauri build` (release binary)
- Installs binary to `~/.local/share/vega/bin/Vega`
- Creates wrapper at `~/.local/bin/vega`
- Adds `.desktop` entry at `~/.local/share/applications/vega.desktop`
- Installs icons to `~/.local/share/icons/`
- Adds Hyprland window rules via `~/.config/hypr/vega.lua` (auto-wired into `hyprland.lua`)

</details>

**Uninstall**

```bash
bash scripts/omarchy/uninstall.sh
```

**Direct run (no install)**

```bash
bash scripts/omarchy/run.sh
```

---

### In-app Omarchy Settings

Open **Settings → Omarchy** in the app to configure:

- **Theme Sync** — match Hyprland accent color
- **Wayland** — toggle Wayland/X11 backend
- **Hyprland Status** — shows window rule status
- **Keybindings** — view/configure keyboard shortcuts

---

### Generic Linux

```bash
# Tauri prerequisites: https://tauri.app/start/prerequisites/
npm install
npm run tauri dev        # dev
npm run tauri build      # → src-tauri/target/release/bundle/
```

Requires: `mpv`, `libmpv`, `webkit2gtk-4.1`, `gtk3`

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
git clone https://github.com/hembramnishant50-glitch/vega-desktop.git
cd vega-desktop
npm install
npm run tauri dev
```

| Script | Description |
|--------|-------------|
| `npm run dev` | Vite dev server |
| `npm run build` | Typecheck + Vite build |
| `npm run tauri dev` | App + HMR (port 1420) |
| `npm run tauri build` | Production bundles |

**Stack** — Tauri 2 · React 19 · TypeScript · Vite · Zustand · Tailwind 4 · MPV

```
src/          → React app (pages, components, lib)
src-tauri/    → Rust backend (MPV, torrent, DoH, store)
scripts/omarchy/  → Omarchy install/uninstall/run
scripts/      → build helpers
```

---

### Troubleshooting

**Blank window on Hyprland** → `WEBKIT_DISABLE_DMABUF_RENDERER=1 vega`

**`cmake` not found / build failed** → `sudo pacman -S cmake clang pkgconf` then rebuild

**Missing mpv** → `sudo pacman -S mpv libmpv`

**No decorations** → intentional (`decorations: false`); borders drawn by Hyprland via `vega.lua`

**SUPER+V not working** → `hyprctl reload` and check keybindings in Settings → Omarchy

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
