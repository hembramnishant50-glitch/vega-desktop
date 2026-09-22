# Vega Desktop

**Native. Ad-free. MPV-powered. Omarchy Linux only.**

Bring your own sources · Stream & download · Sync with mobile

[![Version](https://img.shields.io/badge/version-2.0.5-9e6cff?style=flat-square)](src-tauri/tauri.conf.json)
[![Tauri](https://img.shields.io/badge/Tauri-2.0-24C8DB?style=flat-square&logo=tauri&logoColor=white)](https://tauri.app)
[![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react&logoColor=black)](https://react.dev)
[![Platform](https://img.shields.io/badge/platform-Omarchy%20Linux%20only-00D4AA?style=flat-square)](#download)
[![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)](#license)

> Vega does not host or provide any media. All content is sourced by the user via providers/extensions.

---

### Features

- **BYOS** — bring your own extensions
- **MPV** — hardware-accelerated player using system `mpv` / `libmpv`
- **Ad-free** — multi-audio, external subs, download
- **Watchlist & history** — sync with Vega mobile
- **Torrents, DoH, local proxy** — built-in
- **Omarchy integration** — Hyprland window rules, Wayland-optimized, theme sync

---

### Requirements

- **OS:** Omarchy 4+ / Arch Linux + Hyprland 0.56
- **Packages:** `webkit2gtk-4.1` `gtk3` `librsvg` `pkgconf` `base-devel` `ffmpeg` `mpv` `libmpv` `nodejs` `rust` `cmake` `clang`
- **GPU:** mpv hardware decoding via `hwdec` (configurable in Settings)

---

### Install

```bash
git clone https://github.com/hembramnishant50-glitch/vega-desktop.git
cd vega-desktop
bash scripts/omarchy/install.sh
```

Launch from app launcher as **Vega**, or:

```bash
vega
```

<details>
<summary>What the installer does</summary>

- Checks/installs system packages via `pacman` (`webkit2gtk-4.1`, `gtk3`, `mpv`, etc.)
- Installs Rust toolchain via `rustup` if missing
- Builds frontend (`npm ci` + `vite build`) and backend (`cargo build` release)
- Installs binary to `~/.local/share/vega/bin/Vega` with wrapper `~/.local/bin/vega`
- Adds desktop entry `~/.local/share/applications/vega.desktop` (Wayland env: `GDK_BACKEND=wayland,x11`)
- Installs icons to `~/.local/share/icons/hicolor/*/apps/` (freedesktop)
- Adds Hyprland rules `~/.config/hypr/vega.lua` auto-wired into `hyprland.lua`

</details>

**Uninstall**

```bash
bash scripts/omarchy/uninstall.sh
```

**Run without installing**

```bash
bash scripts/omarchy/run.sh
# or dev mode
bash scripts/omarchy/run.sh --dev
```

---

### In-app Omarchy Settings

`Settings → Omarchy`:

- **Theme Sync** — match Hyprland accent color
- **Wayland** — toggle Wayland/X11 backend
- **Hyprland Status** — window rule status
- **Keybindings** — view shortcuts

Or sync manually:

```bash
bash omarchy/theme/sync-theme.sh
```

---

### Build from source

```bash
git clone https://github.com/hembramnishant50-glitch/vega-desktop.git
cd vega-desktop
npm install
npm run tauri dev        # dev with HMR on http://localhost:1420
npm run tauri build      # → src-tauri/target/release/bundle/
```

**Stack:** Tauri 2 · React 19 · TypeScript · Vite · Zustand · Tailwind 4 · MPV

```
src/               → React app (pages, components, lib)
src-tauri/         → Rust backend (MPV, torrent, DoH, store)
scripts/omarchy/   → Omarchy install / uninstall / run
omarchy/hypr/      → Hyprland window rules
omarchy/theme/     → Theme sync
```

| Script | Description |
|--------|-------------|
| `npm run dev` | Vite dev server |
| `npm run build` | Typecheck + Vite build |
| `npm run tauri dev` | App + HMR |
| `npm run tauri build` | Production bundles |

---

### Providers

Adding sources: **https://vega.8man.in/guide/adding-providers/**

---

### Troubleshooting

**Blank window on Hyprland** → `WEBKIT_DISABLE_DMABUF_RENDERER=1 vega` or use desktop action `Wayland Debug`

**Build fails `cmake` / `boring-sys`** → `sudo pacman -S cmake clang pkgconf` then rebuild

**Missing mpv** → `sudo pacman -S mpv libmpv && mpv --version`

**No decorations** → intentional (`transparent: true`, `decorations: false`); Hyprland draws borders via `vega.lua`

**Window not floating** → `hyprctl reload` and check `~/.config/hypr/vega.lua` exists

---

### License

MIT — Vega does not host, store, or provide any media content. Not affiliated with any provider/extension.
