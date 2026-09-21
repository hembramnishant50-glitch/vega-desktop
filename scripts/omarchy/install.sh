#!/usr/bin/env bash
set -euo pipefail

INSTALL_PREFIX="${HOME}/.local/share/vega"
WRAPPER="${HOME}/.local/bin/vega"
DESKTOP_FILE="${HOME}/.local/share/applications/vega.desktop"
ICON_DIR="${HOME}/.local/share/icons"
RULES_DIR="${HOME}/.config/hypr"
RULES_FILE="${RULES_DIR}/vega.lua"
HYPR_CONFIG="${RULES_DIR}/hyprland.lua"
REPO_DIR="${1:-.}"
MARKER_BEGIN="-- >>> vega-desktop begin"
MARKER_END="-- <<< vega-desktop end"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[vega]${NC} $*"; }
warn()  { echo -e "${YELLOW}[vega]${NC} $*"; }
error() { echo -e "${RED}[vega]${NC} $*" >&2; exit 1; }

# ── 0. Prerequisites ──────────────────────────────────────────────────
command -v node  >/dev/null 2>&1 || error "Node.js not found. Install via: omarchy pkg add node"
command -v npm   >/dev/null 2>&1 || error "npm not found."

info "Checking system packages..."
for pkg in webkit2gtk-4.1 gtk3 librsvg pkgconf base-devel ffmpeg; do
  if ! pacman -Qi "$pkg" &>/dev/null; then
    warn "Package '$pkg' not installed. Installing via omarchy pkg add..."
    command -v omarchy >/dev/null 2>&1 && omarchy pkg add "$pkg" || warn "Run: omarchy pkg add $pkg"
  fi
done

# ── 1. Rust toolchain ─────────────────────────────────────────────────
if ! command -v cargo &>/dev/null; then
  info "Rust not found. Installing rustup..."
  if [ -f "${HOME}/.cargo/env" ]; then
    source "${HOME}/.cargo/env"
  else
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "${HOME}/.cargo/env"
  fi
fi
info "Rust: $(rustc --version 2>/dev/null || echo 'not found')"

# ── 2. Build ──────────────────────────────────────────────────────────
info "Building Vega..."
cd "$REPO_DIR"
npm ci
npm run build
npm run tauri build -- --no-bundle

# ── 3. Install binary + sidecars ──────────────────────────────────────
info "Installing to ${INSTALL_PREFIX}..."
mkdir -p "${INSTALL_PREFIX}/bin"

# Detect binary name from Cargo.toml (default: "Vega")
BINARY_NAME=$(grep -m1 '^name\s*=' src-tauri/Cargo.toml | sed 's/.*"\(.*\)".*/\1/')
BINARY_PATH="src-tauri/target/release/${BINARY_NAME}"

if [ -f "$BINARY_PATH" ]; then
  cp "$BINARY_PATH" "${INSTALL_PREFIX}/bin/${BINARY_NAME}"
  chmod +x "${INSTALL_PREFIX}/bin/${BINARY_NAME}"
  info "Binary: ${BINARY_NAME}"
else
  error "Build artifact not found at $BINARY_PATH"
fi

# Copy sidecars
for sc in src-tauri/binaries/*-unknown-linux-gnu*; do
  [ -f "$sc" ] || continue
  cp "$sc" "${INSTALL_PREFIX}/bin/"
  chmod +x "${INSTALL_PREFIX}/bin/$(basename "$sc")"
done

# Copy resources
[ -d "src-tauri/resources" ] && cp -r src-tauri/resources/* "${INSTALL_PREFIX}/" 2>/dev/null || true

# ── 4. Wrapper script ─────────────────────────────────────────────────
mkdir -p "$(dirname "$WRAPPER")"
cat > "$WRAPPER" <<EOF
#!/usr/bin/env bash
exec "${INSTALL_PREFIX}/bin/${BINARY_NAME}" "\$@"
EOF
chmod +x "$WRAPPER"
info "Wrapper: ${WRAPPER}"

# ── 5. Desktop entry ──────────────────────────────────────────────────
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=Vega
Exec=${WRAPPER}
Icon=vega
Categories=AudioVideo;Player;
Terminal=false
StartupWMClass=vega
EOF
info "Desktop: ${DESKTOP_FILE}"

# ── 6. Icons ──────────────────────────────────────────────────────────
mkdir -p "${ICON_DIR}"
for size in 32 64 128 256; do
  [ -f "src-tauri/icons/${size}x${size}.png" ] && \
    cp "src-tauri/icons/${size}x${size}.png" "${ICON_DIR}/vega-${size}x${size}.png"
done
[ -f "src-tauri/icons/128x128@2x.png" ] && \
  cp "src-tauri/icons/128x128@2x.png" "${ICON_DIR}/vega-256x256.png"
gtk-update-icon-cache -f -t "${ICON_DIR}" 2>/dev/null || true
info "Icons installed to ${ICON_DIR}"

# ── 7. Hyprland window rules ──────────────────────────────────────────
if [ -f "$HYPR_CONFIG" ]; then
  mkdir -p "$RULES_DIR"

  # Write reversible rule module (uses Omarchy's global `o` helper)
  cat > "$RULES_FILE" <<'LUA'
-- vega.lua — auto-generated, reversible by uninstall.sh
o.window({ class = "vega" }, {
  float = true,
  size = { 800, 600 },
  center = true,
  animation = "slide",
})
LUA

  # Remove old marker block if present (handles both "-- >>>" and legacy "# >>>"), then append new one
  for legacy in "$MARKER_BEGIN" "# >>> vega-desktop begin"; do
    if grep -qF "$legacy" "$HYPR_CONFIG" 2>/dev/null; then
      awk -v b="$legacy" -v e1="$MARKER_END" -v e2="# <<< vega-desktop end" '
        $0 ~ b { skip=1; next }
        $0 ~ e1 || $0 ~ e2 { skip=0; next }
        !skip { print }
      ' "$HYPR_CONFIG" > "${HYPR_CONFIG}.tmp" && mv "${HYPR_CONFIG}.tmp" "$HYPR_CONFIG"
    fi
  done

  cat >> "$HYPR_CONFIG" <<LUA

${MARKER_BEGIN}
dofile("${RULES_FILE}")
${MARKER_END}
LUA

  info "Hyprland rules written to ${RULES_FILE}"
fi

# ── Done ──────────────────────────────────────────────────────────────
echo ""
info "Installation complete!"
echo "  Launch:  ${WRAPPER}"
echo "  Desktop: vega (from app launcher)"
echo "  Uninstall: scripts/omarchy/uninstall.sh"
