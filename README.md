<div align="center">

### 🟣 Vega Desktop

**Native · Ad-free · MPV-powered · Omarchy Linux only**

*Bring your own sources — stream, download & sync with mobile*

<br>

[![Official Repo](https://img.shields.io/badge/Official_Repo-vega--org%2Fvega--desktop-1f6feb?style=for-the-badge&logo=github&logoColor=white)](https://github.com/vega-org/vega-desktop)
[![Fork for Omarchy](https://img.shields.io/badge/Fork-Omarchy_Linux-00D4AA?style=for-the-badge&logo=hyprland&logoColor=black)](https://github.com/hembramnishant50-glitch/vega-desktop)
[![Version](https://img.shields.io/badge/version-2.0.5-9e6cff?style=for-the-badge)](src-tauri/tauri.conf.json)
[![Tauri](https://img.shields.io/badge/Tauri-2.0-24C8DB?style=for-the-badge&logo=tauri&logoColor=white)](https://tauri.app)
[![React](https://img.shields.io/badge/React-19-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Rust](https://img.shields.io/badge/Rust-1.98-000000?style=for-the-badge&logo=rust&logoColor=white)](https://www.rust-lang.org)
[![Platform](https://img.shields.io/badge/Platform-Omarchy%20%2F%20Arch%20%2F%20Hyprland-00D4AA?style=for-the-badge&logo=archlinux&logoColor=white)](#-install)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](#-license)

<br>

<sub>
<b>Fork of</b>
<a href="https://github.com/vega-org/vega-desktop">vega-org/vega-desktop</a>
— adapted exclusively for
<a href="https://omarchy.org"><b>Omarchy</b></a> ·
<a href="https://wiki.hyprland.org"><b>Hyprland</b></a> ·
<a href="https://archlinux.org"><b>Arch</b></a>
</sub>

<br>

> ⚠️ **Disclaimer** — Vega does not host or provide any media. All content is sourced by the user via providers/extensions.

</div>

---

## 📑 Table of Contents

<div align="center">

[✨ Features](#-features) ·
[📋 Requirements](#-requirements) ·
[⬇️ Install](#-install) ·
[⚙️ Settings](#%EF%B8%8F-in-app-omarchy-settings) ·
[🛠 Build](#-build-from-source) ·
[🧩 Providers](#-providers) ·
[🚨 Troubleshooting](#-troubleshooting) ·
[📄 License](#-license)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🧩 BYOS
Bring your own extensions — no locked sources.

### 🎬 MPV Player
Hardware-accelerated, desktop-native playback via system `mpv` / `libmpv`.

### 🚫 Ad-free
Stream & download — multi-audio, external subtitles.

</td>
<td width="50%">

### 📺 Watchlist & History
Sync your list with the **Vega mobile app**.

### 🌐 Built-in Networking
Torrents · DoH resolver · local proxy — all inside.

### 🖥 Omarchy Integration
Hyprland window rules · Wayland-optimized · theme sync · in-app settings.

</td>
</tr>
</table>

---

## 📋 Requirements

| | |
|:--|:--|
| 🐧 **OS** | Omarchy 4+ / Arch Linux + Hyprland 0.56 |
| 📦 **Packages** | `webkit2gtk-4.1` `gtk3` `librsvg` `pkgconf` `base-devel` `ffmpeg` `mpv` `libmpv` `nodejs` `rust` `cmake` `clang` |
| 🎮 **GPU** | mpv hardware decoding (`hwdec`, configurable in Settings) |

---

## ⬇️ Install

```bash
git clone https://github.com/hembramnishant50-glitch/vega-desktop.git
cd vega-desktop
bash scripts/omarchy/install.sh
```

Launch from the app launcher as **Vega**, or simply:

```bash
vega
```

<details>
<summary><b>📦 What the installer does</b></summary>
<br>

- ✅ Checks/installs system packages via `pacman` (`webkit2gtk-4.1`, `gtk3`, `mpv`, …)
- 🦀 Installs Rust toolchain via `rustup` if missing
- 🔨 Builds frontend (`npm ci` + `vite build`) and backend (`cargo build --release`)
- 📁 Installs binary → `~/.local/share/vega/bin/Vega`, wrapper → `~/.local/bin/vega`
- 🖼 Adds desktop entry → `~/.local/share/applications/vega.desktop` (Wayland: `GDK_BACKEND=wayland,x11`)
- 🎨 Installs icons → `~/.local/share/icons/hicolor/*/apps/` (freedesktop)
- 🪟 Adds Hyprland rules → `~/.config/hypr/vega.lua`, auto-wired into `hyprland.lua`

</details>

<br>

**🧹 Uninstall**

```bash
bash scripts/omarchy/uninstall.sh
```

**▶️ Run without installing**

```bash
bash scripts/omarchy/run.sh          # release run
bash scripts/omarchy/run.sh --dev    # dev mode
```

---

## ⚙️ In-app Omarchy Settings

Open **`Settings → Omarchy`** inside the app:

| Setting | Description |
|---------|-------------|
| 🎨 **Theme Sync** | Match Hyprland accent color |
| 🪟 **Wayland** | Toggle Wayland / X11 backend |
| 📊 **Hyprland Status** | Show window-rule status |
| ⌨️ **Keybindings** | View configured shortcuts |

Or sync the theme manually:

```bash
bash omarchy/theme/sync-theme.sh
```

---

## 🛠 Build from source

```bash
git clone https://github.com/hembramnishant50-glitch/vega-desktop.git
cd vega-desktop
npm install
npm run tauri dev      # dev + HMR @ http://localhost:1420
npm run tauri build    # → src-tauri/target/release/bundle/
```

### 📚 Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Vite dev server |
| `npm run build` | Typecheck + Vite build |
| `npm run tauri dev` | App + HMR |
| `npm run tauri build` | Production bundles |

### 🧱 Stack

<div align="center">

![Tauri](https://img.shields.io/badge/Tauri-2.0-24C8DB?style=flat-square&logo=tauri&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?style=flat-square&logo=react&logoColor=black)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-8-646CFF?style=flat-square&logo=vite&logoColor=white)
![Zustand](https://img.shields.io/badge/Zustand-state-443E38?style=flat-square&logo=zustand&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-4-06B6D4?style=flat-square&logo=tailwindcss&logoColor=white)
![Rust](https://img.shields.io/badge/Rust-1.98-000000?style=flat-square&logo=rust&logoColor=white)
![mpv](https://img.shields.io/badge/mpv-0.41-CD3400?style=flat-square&logo=mpv&logoColor=white)

</div>

### 📂 Project structure

```
src/               → React app (pages, components, lib)
src-tauri/         → Rust backend (MPV, torrent, DoH, store)
scripts/omarchy/   → Omarchy install / uninstall / run
omarchy/hypr/      → Hyprland window rules
omarchy/theme/     → Theme sync
```

---

## 🧩 Providers

> 💡 **Adding sources:** [vega.8man.in/guide/adding-providers](https://vega.8man.in/guide/adding-providers/)

---

## 🚨 Troubleshooting

<details>
<summary><b>🖥 Blank window on Hyprland</b></summary>

```bash
WEBKIT_DISABLE_DMABUF_RENDERER=1 vega
# or use the desktop action "Wayland Debug"
```

</details>

<details>
<summary><b>🔨 Build fails: <code>cmake</code> / <code>boring-sys</code> not found</b></summary>

```bash
sudo pacman -S cmake clang pkgconf
# then rebuild
```

</details>

<details>
<summary><b>🎬 Missing mpv</b></summary>

```bash
sudo pacman -S mpv libmpv
mpv --version
```

</details>

<details>
<summary><b>🪟 No window decorations</b></summary>

Intentional — `transparent: true`, `decorations: false`. Hyprland draws borders via `vega.lua`.

</details>

<details>
<summary><b>📐 Window not floating / rules not applied</b></summary>

```bash
hyprctl reload
# verify ~/.config/hypr/vega.lua exists
```

</details>

---

## 📄 License

**MIT** — Vega does not host, store, or provide any media content. Not affiliated with any provider/extension.

<div align="center">

**Official upstream:** [vega-org/vega-desktop](https://github.com/vega-org/vega-desktop) ·
**This fork:** [hembramnishant50-glitch/vega-desktop](https://github.com/hembramnishant50-glitch/vega-desktop)

<sub>Vega Desktop for Omarchy Linux — forked & adapted with ❤️</sub>

</div>
