#!/usr/bin/env bash
# Vega Desktop - Omarchy Uninstaller
set -euo pipefail
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
info(){ echo -e "${CYAN}[vega]${NC} $*"; }
ok(){ echo -e "${GREEN}[vega]${NC} $*"; }
warn(){ echo -e "${YELLOW}[vega]${NC} $*"; }

SYSTEM=false
PURGE=false
KEEP_HYPR=false
for arg in "$@"; do
  case "$arg" in
    --system) SYSTEM=true ;;
    --purge) PURGE=true ;;
    --keep-hypr) KEEP_HYPR=true ;;
    --help|-h)
      cat <<EOF
Usage: $0 [options]
  --system     Remove system-wide install (/opt + /usr/share)
  --purge      Also remove Vega data: ~/.local/share/com.vega.desktop , caches
  --keep-hypr  Don't touch Hyprland config
EOF
      exit 0 ;;
  esac
done

info "Uninstalling Vega Desktop..."

# Binaries
if [[ "$SYSTEM" == true ]]; then
  info "Removing system install..."
  sudo rm -f /opt/vega-desktop/vega-desktop /usr/bin/vega-desktop /usr/share/applications/vega-desktop.desktop
  sudo rm -f /usr/share/icons/hicolor/*/apps/vega-desktop.png
  sudo rmdir /opt/vega-desktop 2>/dev/null || true
else
  info "Removing local install..."
  rm -f "$HOME/.local/bin/vega-desktop"
  rm -f "$HOME/.local/share/applications/vega-desktop.desktop"
  rm -f "$HOME/.local/share/icons/hicolor/128x128/apps/vega-desktop.png"
  rm -f "$HOME/.local/share/icons/hicolor/32x32/apps/vega-desktop.png"
fi
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
gtk-update-icon-cache -q "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

# Hyprland
if [[ "$KEEP_HYPR" == false ]]; then
  if [[ -f "$HOME/.config/hypr/vega.lua" ]]; then
    rm -f "$HOME/.config/hypr/vega.lua"
    ok "Removed ~/.config/hypr/vega.lua"
  fi
  # Remove wired require line
  for f in "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/bindings.lua"; do
    if [[ -f "$f" ]]; then
      # backup
      cp "$f" "$f.bak.$(date +%s)" 2>/dev/null || true
      sed -i '/vega\.lua/d; /hypr\.vega/d; /vega-desktop/d; /-- Vega (auto-added)/d' "$f" 2>/dev/null || true
    fi
  done
  ok "Cleaned Hyprland config (backup .bak created)"
fi

# Purge data
if [[ "$PURGE" == true ]]; then
  warn "Purging Vega data..."
  rm -rf "$HOME/.local/share/com.vega.desktop" 2>/dev/null || true
  rm -rf "$HOME/.cache/com.vega.desktop" 2>/dev/null || true
  rm -rf "$HOME/.config/com.vega.desktop" 2>/dev/null || true
  # Tauri store in XDG_DATA_HOME
  find "$HOME/.local/share" -name "*vega*" -type d 2>/dev/null | while read -r d; do rm -rf "$d"; done
  ok "Purged Vega data. Watchlist/settings are gone!"
else
  info "Keeping Vega data (~/.local/share/com.vega.desktop). Use --purge to wipe."
fi

ok "Uninstall complete. To fully reload Hyprland: hyprctl reload"
