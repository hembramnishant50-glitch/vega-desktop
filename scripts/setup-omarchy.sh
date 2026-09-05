#!/usr/bin/env bash
# Setup Omarchy integration only (no build)
set -euo pipefail
CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
info(){ echo -e "${CYAN}[omarchy]${NC} $*"; }
ok(){ echo -e "${GREEN}[omarchy]${NC} $*"; }
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMARCHY_HYPR_SRC="$PROJECT_ROOT/omarchy/hypr/vega.lua"
DESKTOP_SRC="$PROJECT_ROOT/omarchy/desktop/vega.desktop"
ICON_SRC="$PROJECT_ROOT/src-tauri/icons/icon.png"
ICON_128_SRC="$PROJECT_ROOT/src-tauri/icons/128x128.png"

info "Installing Hyprland rule..."
mkdir -p "$HOME/.config/hypr"
cp -f "$OMARCHY_HYPR_SRC" "$HOME/.config/hypr/vega.lua"
ok "→ ~/.config/hypr/vega.lua"

if ! grep -q 'hypr.vega' "$HOME/.config/hypr/hyprland.lua" 2>/dev/null; then
  echo 'pcall(require, "hypr.vega")' >> "$HOME/.config/hypr/hyprland.lua"
  ok "Wired into hyprland.lua"
fi

if ! grep -q 'vega-desktop' "$HOME/.config/hypr/bindings.lua" 2>/dev/null; then
  echo 'o.bind("SUPER + V", "Vega", "vega-desktop")' >> "$HOME/.config/hypr/bindings.lua"
  ok "Added SUPER+V"
fi

info "Installing desktop entry (local)..."
mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons/hicolor/128x128/apps"
cp -f "$DESKTOP_SRC" "$HOME/.local/share/applications/vega-desktop.desktop"
# If binary exists locally, patch Exec, else keep generic
if [[ -f "$HOME/.local/bin/vega-desktop" ]]; then
  sed -i "s|Exec=vega-desktop|Exec=$HOME/.local/bin/vega-desktop|" "$HOME/.local/share/applications/vega-desktop.desktop"
fi
[[ -f "$ICON_128_SRC" ]] && cp -f "$ICON_128_SRC" "$HOME/.local/share/icons/hicolor/128x128/apps/vega-desktop.png" || true
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

ok "Omarchy integration done. Reload: hyprctl reload"
