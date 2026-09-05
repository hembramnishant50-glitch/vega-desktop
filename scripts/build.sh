#!/usr/bin/env bash
# Vega Build Script - Omarchy optimized (Arch)
set -euo pipefail
CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
info(){ echo -e "${CYAN}[build]${NC} $*"; }
ok(){ echo -e "${GREEN}[build]${NC} $*"; }
die(){ echo -e "${RED}[build]${NC} $*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

MODE="${1:-release}"
# allow: ./scripts/build.sh debug  OR  ./scripts/build.sh release

info "Project: $PROJECT_ROOT  Mode: $MODE"
info "node $(node --version)  cargo $(cargo --version)"

if [[ ! -f package.json ]]; then die "Not in vega-desktop root"; fi

info "→ npm install"
if [[ -f package-lock.json ]]; then npm ci || npm install; else npm install; fi

info "→ vite build (tsc + vite)"
npm run build || die "vite build failed"

info "→ tauri build (Linux bundle)"
# Use linux config which bundles lib*.so and sets deb depends
if [[ "$MODE" == "debug" ]]; then
  npx tauri build --debug --config src-tauri/tauri.linux.conf.json || npx tauri build --debug
else
  npx tauri build --config src-tauri/tauri.linux.conf.json || npx tauri build
fi

ok "Build done. Artifacts:"
ls -lh src-tauri/target/release/bundle/ 2>/dev/null | sed 's/^/  /' || ls -lh src-tauri/target/release/vega* 2>/dev/null | sed 's/^/  /' || true
echo ""
echo "Install locally: ./scripts/install.sh --no-deps --no-hypr"
echo "System deb: src-tauri/target/release/bundle/deb/*.deb"
echo "AppImage:   src-tauri/target/release/bundle/appimage/*.AppImage"
