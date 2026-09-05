#!/usr/bin/env bash
# Vega Desktop - Omarchy/Arch Linux Installer
# Installs deps -> builds -> installs binary + desktop entry + Hyprland rules
set -euo pipefail

# ── colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}[vega]${NC} $*"; }
ok()    { echo -e "${GREEN}[vega]${NC} $*"; }
warn()  { echo -e "${YELLOW}[vega]${NC} $*"; }
die()   { echo -e "${RED}[vega]${NC} $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OMARCHY_HYPR_SRC="$PROJECT_ROOT/omarchy/hypr/vega.lua"
DESKTOP_SRC="$PROJECT_ROOT/omarchy/desktop/vega.desktop"
ICON_SRC="$PROJECT_ROOT/src-tauri/icons/icon.png"
ICON_128_SRC="$PROJECT_ROOT/src-tauri/icons/128x128.png"

# Flags
INSTALL_DEPS=true
BUILD=true
INSTALL_DESKTOP=true
INSTALL_HYPR=true
SYSTEM_INSTALL=false   # if true, install to /opt + /usr/share/applications
SKIP_BUILD_IF_EXISTS=false

for arg in "$@"; do
  case "$arg" in
    --no-deps) INSTALL_DEPS=false ;;
    --no-build) BUILD=false ;;
    --no-desktop) INSTALL_DESKTOP=false ;;
    --no-hypr) INSTALL_HYPR=false ;;
    --system) SYSTEM_INSTALL=true ;;
    --skip-build-if-exists) SKIP_BUILD_IF_EXISTS=true ;;
    --help|-h)
      cat <<EOF
Usage: $0 [options]
  --no-deps              Skip pacman dependency install
  --no-build             Skip cargo/npm build (only install integration)
  --no-desktop           Skip desktop entry install
  --no-hypr              Skip Hyprland config
  --system               Install system-wide to /opt/vega-desktop + /usr/share/applications (requires sudo)
  --skip-build-if-exists Skip build if binary already exists
EOF
      exit 0 ;;
  esac
done

# ── 1. Check Arch/Omarchy ──
if ! command -v pacman >/dev/null 2>&1; then
  die "pacman not found. This installer is for Arch/Omarchy only."
fi
info "Detected $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Arch")"
info "Project: $PROJECT_ROOT"

# ── 2. Install dependencies ──
if [[ "$INSTALL_DEPS" == true ]]; then
  info "Checking dependencies..."
  DEPS=(
    webkit2gtk-4.1
    gtk3
    base-devel
    curl
    wget
    file
    openssl
    appmenu-gtk-module
    libappindicator-gtk3
    librsvg
    mpv
    mpv-mpris
    nodejs
    npm
    rust
  )
  # rust is provided by `rust` or `rustup`; check
  MISSING=()
  for pkg in "${DEPS[@]}"; do
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
      # special case: rust may be rustup
      if [[ "$pkg" == "rust" ]] && pacman -Qi rustup >/dev/null 2>&1; then
        continue
      fi
      MISSING+=("$pkg")
    fi
  done

  if [[ ${#MISSING[@]} -gt 0 ]]; then
    info "Installing missing deps: ${MISSING[*]}"
    if [[ "$SYSTEM_INSTALL" == true || "$EUID" -eq 0 ]]; then
      sudo pacman -S --needed --noconfirm "${MISSING[@]}"
    else
      # Try without sudo first, fallback to sudo
      if pacman -Qi yay >/dev/null 2>&1; then
        info "If install fails, re-run with --system or via sudo"
      fi
      sudo pacman -S --needed --noconfirm "${MISSING[@]}" || {
        warn "pacman install failed. Continuing - you may need to install manually:"
        warn "  sudo pacman -S ${MISSING[*]}"
      }
    fi
  else
    ok "All system deps present."
  fi

  # Ensure Rust target exists
  if command -v rustup >/dev/null 2>&1; then
    rustup target add wasm32-unknown-unknown 2>/dev/null || true
  fi
  # Node check
  if ! command -v node >/dev/null 2>&1; then
    die "node not found after install. Install nodejs manually: sudo pacman -S nodejs npm"
  fi
  info "node $(node --version)  npm $(npm --version)  rustc $(rustc --version 2>/dev/null || echo 'not found')"
else
  info "Skipping deps (--no-deps)"
fi

# ── 3. Install npm deps & build ──
cd "$PROJECT_ROOT"

if [[ "$BUILD" == true ]]; then
  if [[ "$SKIP_BUILD_IF_EXISTS" == true && -f "$PROJECT_ROOT/src-tauri/target/release/vega-desktop" ]]; then
    ok "Binary already exists, skipping build (--skip-build-if-exists)"
  else
    info "Installing npm dependencies..."
    if [[ -f package-lock.json ]]; then
      npm ci || npm install
    else
      npm install
    fi

    info "Building Vega (this may take 5-15 min on first build)..."
    # Prefer tauri build via npm script; uses tauri.conf.json + tauri.linux.conf.json
    if command -v cargo >/dev/null 2>&1; then
      npm run build || die "vite build failed"
      # Use tauri build for Linux bundle
      npx tauri build --config src-tauri/tauri.linux.conf.json || npx tauri build || die "tauri build failed"
    else
      die "cargo not found. Install rust: sudo pacman -S rust"
    fi
    ok "Build complete."
    # Show artifacts
    ls -lh src-tauri/target/release/bundle/ 2>/dev/null | head -n 30 || true
  fi
else
  info "Skipping build (--no-build)"
fi

# ── 4. Install binary + desktop entry ──
install_local() {
  local bin_src
  bin_src="$(find "$PROJECT_ROOT/src-tauri/target/release" -maxdepth 1 -type f -name "vega*" -executable | head -n1 || true)"
  if [[ -z "$bin_src" ]]; then
    bin_src="$(find "$PROJECT_ROOT/src-tauri/target/release/bundle" -type f -name "*.AppImage" | head -n1 || true)"
  fi
  # fallback: the binary is named `vega` (package name = Vega -> binary `vega`)
  for cand in "$PROJECT_ROOT/src-tauri/target/release/vega" "$PROJECT_ROOT/src-tauri/target/release/Vega" "$PROJECT_ROOT/src-tauri/target/release/bundle/appimage"/*; do
    if [[ -f "$cand" ]]; then bin_src="$cand"; break; fi
  done

  if [[ -z "$bin_src" || ! -f "$bin_src" ]]; then
    warn "No built binary found. Expected src-tauri/target/release/vega or AppImage."
    warn "Looked in src-tauri/target/release/bundle/"
    ls -R src-tauri/target/release/bundle 2>/dev/null | head -n 50 || true
    # Don't fail if --no-build was used
    if [[ "$BUILD" == true ]]; then
      die "Build artifact not found."
    else
      return 0
    fi
  fi

  info "Found binary: $bin_src"

  if [[ "$SYSTEM_INSTALL" == true ]]; then
    info "Installing system-wide to /opt/vega-desktop..."
    sudo mkdir -p /opt/vega-desktop /usr/share/applications /usr/share/icons/hicolor/128x128/apps /usr/share/icons/hicolor/32x32/apps
    sudo cp -f "$bin_src" /opt/vega-desktop/vega-desktop
    sudo chmod +x /opt/vega-desktop/vega-desktop
    # symlink
    sudo ln -sf /opt/vega-desktop/vega-desktop /usr/bin/vega-desktop
    # desktop
    if [[ -f "$DESKTOP_SRC" ]]; then
      sudo cp -f "$DESKTOP_SRC" /usr/share/applications/vega-desktop.desktop
      sudo sed -i 's|Exec=vega-desktop|Exec=/opt/vega-desktop/vega-desktop|' /usr/share/applications/vega-desktop.desktop
    fi
    # icons
    [[ -f "$ICON_128_SRC" ]] && sudo cp -f "$ICON_128_SRC" /usr/share/icons/hicolor/128x128/apps/vega-desktop.png || true
    [[ -f "$ICON_SRC" ]] && sudo cp -f "$ICON_SRC" /usr/share/icons/hicolor/32x32/apps/vega-desktop.png || true
    sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
    sudo update-desktop-database /usr/share/applications 2>/dev/null || true
    ok "System install done. Run: vega-desktop  or  /opt/vega-desktop/vega-desktop"
  else
    # Local install: ~/.local/bin + ~/.local/share/applications
    info "Installing locally to ~/.local/bin + ~/.local/share/applications..."
    mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/128x128/apps" "$HOME/.local/share/icons/hicolor/32x32/apps"
    # If AppImage, copy as-is; if deb, inform
    local dest_bin="$HOME/.local/bin/vega-desktop"
    if [[ "$bin_src" == *.AppImage ]]; then
      cp -f "$bin_src" "$dest_bin"
      chmod +x "$dest_bin"
    elif [[ "$bin_src" == *.deb ]]; then
      warn "Built .deb found at $bin_src. Install via: sudo pacman -U <or> sudo dpkg -i ... (Debian) or extract."
      warn "For Arch/Omarchy, AppImage or binary is preferred. Copying binary if exists..."
      # try to find binary alongside
      local bin_alt
      bin_alt="$(find "$PROJECT_ROOT/src-tauri/target/release" -maxdepth 1 -type f -executable -name "vega" | head -n1 || true)"
      if [[ -n "$bin_alt" ]]; then cp -f "$bin_alt" "$dest_bin"; chmod +x "$dest_bin"; fi
    else
      cp -f "$bin_src" "$dest_bin"
      chmod +x "$dest_bin"
    fi
    if [[ -f "$DESKTOP_SRC" && "$INSTALL_DESKTOP" == true ]]; then
      cp -f "$DESKTOP_SRC" "$HOME/.local/share/applications/vega-desktop.desktop"
      # patch Exec to absolute path
      sed -i "s|Exec=vega-desktop|Exec=$HOME/.local/bin/vega-desktop|" "$HOME/.local/share/applications/vega-desktop.desktop"
      ok "Desktop entry: ~/.local/share/applications/vega-desktop.desktop"
    fi
    [[ -f "$ICON_128_SRC" ]] && cp -f "$ICON_128_SRC" "$HOME/.local/share/icons/hicolor/128x128/apps/vega-desktop.png" || true
    [[ -f "$ICON_SRC" ]] && cp -f "$ICON_SRC" "$HOME/.local/share/icons/hicolor/32x32/apps/vega-desktop.png" || true
    gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null || true
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
    ok "Local install done. Run: ~/.local/bin/vega-desktop  (ensure ~/.local/bin is in PATH)"
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      warn "Add to PATH: echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
    fi
  fi
}

if [[ "$INSTALL_DESKTOP" == true ]]; then
  install_local
else
  info "Skipping desktop install (--no-desktop)"
fi

# ── 5. Hyprland / Omarchy integration ──
if [[ "$INSTALL_HYPR" == true ]]; then
  info "Installing Hyprland integration..."
  mkdir -p "$HOME/.config/hypr"
  if [[ -f "$OMARCHY_HYPR_SRC" ]]; then
    cp -f "$OMARCHY_HYPR_SRC" "$HOME/.config/hypr/vega.lua"
    ok "Hypr rule: ~/.config/hypr/vega.lua"
  fi
  # Auto-wire require in hyprland.lua if not already present
  local hypr_main="$HOME/.config/hypr/hyprland.lua"
  if [[ -f "$hypr_main" ]]; then
    if ! grep -q 'hypr.vega\|vega.lua' "$hypr_main" 2>/dev/null; then
      echo '' >> "$hypr_main"
      echo '-- Vega Desktop (auto-added by vega install)' >> "$hypr_main"
      echo 'pcall(require, "hypr.vega")' >> "$hypr_main"
      ok "Wired require(\"hypr.vega\") into ~/.config/hypr/hyprland.lua"
    else
      ok "Hyprland.lua already references vega"
    fi
  else
    warn "No ~/.config/hypr/hyprland.lua found (Omarchy uses lua). Manual add: require(\"hypr.vega\")"
  fi

  # Optional keybind: SUPER + V to launch Vega
  # Add to bindings.lua if not present
  local bindings="$HOME/.config/hypr/bindings.lua"
  if [[ -f "$bindings" ]] && ! grep -q 'vega-desktop' "$bindings" 2>/dev/null; then
    echo '' >> "$bindings"
    echo '-- Vega (auto-added)' >> "$bindings"
    echo 'o.bind("SUPER + V", "Vega", "vega-desktop")' >> "$bindings"
    ok "Added SUPER+V bind to ~/.config/hypr/bindings.lua"
    info "Reload Hyprland: hyprctl reload  or  omarchy restart"
  fi
else
  info "Skipping Hyprland integration (--no-hypr)"
fi

# ── 6. Summary ──
echo ""
ok "=== Vega Omarchy install complete ==="
echo "  Launch:  vega-desktop  (or SUPER+V)"
echo "  Logs:    ~/.local/share/com.vega.desktop/logs/  (if enabled)"
echo "  Config:  ~/.config/hypr/vega.lua"
echo "  Desktop: ~/.local/share/applications/vega-desktop.desktop"
echo ""
echo "  Tip: omarchy/theme/sync-theme.sh to sync Omarchy accent to Vega"
echo "  Uninstall: ./scripts/uninstall.sh  or  ./uninstall.sh"
