#!/usr/bin/env bash
# Vega Dev Script - Omarchy/Hyprland
set -euo pipefail
CYAN='\033[0;36m'; GREEN='\033[0;32m'; NC='\033[0m'
info(){ echo -e "${CYAN}[dev]${NC} $*"; }
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Wayland env for dev
export GDK_BACKEND="wayland,x11"
export WEBKIT_DISABLE_DMABUF_RENDERER=0

if ! command -v npm >/dev/null 2>&1; then echo "npm not found"; exit 1; fi
if [[ ! -d node_modules ]]; then
  info "node_modules missing, running npm install..."
  npm install
fi

info "Starting Tauri dev server..."
info "  Vite: http://localhost:1420"
info "  Hyprland tip: Vega will tile; toggle float with SUPER+SPACE or use vega.lua rules"
info "  Logs: RUST_LOG=debug npm run tauri dev  (for verbose)"

# Pass through args to tauri
exec npm run tauri -- dev "$@"
