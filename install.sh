#!/usr/bin/env bash
# Vega Desktop - Top-level Omarchy installer shim
# Delegates to scripts/install.sh
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "$SCRIPT_DIR/scripts/install.sh" "$@"
