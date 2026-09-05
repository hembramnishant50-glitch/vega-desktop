#!/usr/bin/env bash
# Vega Clean Script
set -euo pipefail
CYAN='\033[0;36m'; NC='\033[0m'
info(){ echo -e "${CYAN}[clean]${NC} $*"; }
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

info "Cleaning Vite / Tauri artifacts..."
rm -rf dist/ node_modules/.vite/ src-tauri/target/ 2>/dev/null || true
info "Cleaning caches..."
rm -rf "$HOME/.cache/com.vega.desktop" 2>/dev/null || true
info "Done. Run: npm install && npm run tauri dev  to rebuild"
