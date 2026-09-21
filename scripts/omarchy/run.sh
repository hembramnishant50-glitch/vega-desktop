#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
BINARY_NAME="Vega"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}[vega]${NC} $*"; }
error() { echo -e "${RED}[vega]${NC} $*" >&2; exit 1; }

# ── Build mode ────────────────────────────────────────────────────────
if [ "${1:-}" = "--build" ] || [ "${1:-}" = "--dev" ]; then
  info "Building and running..."
  cd "$REPO_DIR"
  npm run tauri dev
  exit $?
fi

# ── Prebuilt binary ──────────────────────────────────────────────────
PREBUILT="${REPO_DIR}/src-tauri/target/release/${BINARY_NAME}"
if [ -f "$PREBUILT" ]; then
  info "Running prebuilt: $PREBUILT"
  exec "$PREBUILT" "$@"
fi

# ── Dev fallback ──────────────────────────────────────────────────────
info "No prebuilt binary found. Starting dev mode..."
cd "$REPO_DIR"
exec npm run tauri dev
