#!/usr/bin/env bash
set -euo pipefail

INSTALL_PREFIX="${HOME}/.local/share/vega"
WRAPPER="${HOME}/.local/bin/vega"
DESKTOP_FILE="${HOME}/.local/share/applications/vega.desktop"
ICON_DIR="${HOME}/.local/share/icons"
RULES_FILE="${HOME}/.config/hypr/vega.lua"
HYPR_CONFIG="${HOME}/.config/hypr/hyprland.lua"
MARKER_BEGIN="-- >>> vega-desktop begin"
MARKER_END="-- <<< vega-desktop end"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[vega]${NC} $*"; }
warn()  { echo -e "${YELLOW}[vega]${NC} $*"; }

echo "This will remove Vega from your system."
read -p "Continue? [y/N] " -r
[[ $REPLY =~ ^[Yy]$ ]] || exit 0

# ── 1. Remove install directory ──────────────────────────────────────
if [ -d "$INSTALL_PREFIX" ]; then
  rm -rf "$INSTALL_PREFIX"
  info "Removed ${INSTALL_PREFIX}"
fi

# ── 2. Remove wrapper ────────────────────────────────────────────────
if [ -f "$WRAPPER" ]; then
  rm -f "$WRAPPER"
  info "Removed ${WRAPPER}"
fi

# ── 3. Remove desktop entry ──────────────────────────────────────────
if [ -f "$DESKTOP_FILE" ]; then
  rm -f "$DESKTOP_FILE"
  info "Removed ${DESKTOP_FILE}"
fi

# ── 4. Remove icons ──────────────────────────────────────────────────
# hicolor icons + top-level fallbacks + legacy misnamed
for f in "${ICON_DIR}"/vega.png "${ICON_DIR}"/vega.svg "${ICON_DIR}"/vega-*.png; do
  [ -f "$f" ] && rm -f "$f" && info "Removed $(basename "$f")"
done
for size in 32 64 128 256 512; do
  f="${ICON_DIR}/hicolor/${size}x${size}/apps/vega.png"
  [ -f "$f" ] && rm -f "$f" && info "Removed hicolor/${size}x${size}/apps/vega.png"
done
[ -f "${ICON_DIR}/hicolor/scalable/apps/vega.svg" ] && rm -f "${ICON_DIR}/hicolor/scalable/apps/vega.svg" && info "Removed hicolor/scalable/apps/vega.svg"
gtk-update-icon-cache -f -t "${ICON_DIR}/hicolor" 2>/dev/null || true
update-desktop-database "$(dirname "$DESKTOP_FILE")" 2>/dev/null || true
# also clean hicolor cache left behind by old installer
rm -f "${ICON_DIR}/icon-theme.cache" 2>/dev/null || true

# ── 5. Remove Hyprland rules ─────────────────────────────────────────
if [ -f "$RULES_FILE" ]; then
  rm -f "$RULES_FILE"
  info "Removed ${RULES_FILE}"
fi

for legacy in "$MARKER_BEGIN" "# >>> vega-desktop begin"; do
  if [ -f "$HYPR_CONFIG" ] && grep -qF "$legacy" "$HYPR_CONFIG" 2>/dev/null; then
    awk -v b="$legacy" -v e1="$MARKER_END" -v e2="# <<< vega-desktop end" '
      $0 ~ b { skip=1; next }
      $0 ~ e1 || $0 ~ e2 { skip=0; next }
      !skip { print }
    ' "$HYPR_CONFIG" > "${HYPR_CONFIG}.tmp" && mv "${HYPR_CONFIG}.tmp" "$HYPR_CONFIG"
    info "Removed marker block from hyprland.lua"
  fi
done

echo ""
info "Vega has been uninstalled."
