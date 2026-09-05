#!/usr/bin/env bash
# Sync Omarchy current theme accent to Vega primary color
# Vega stores primaryColor in Tauri store: ~/.local/share/com.vega.desktop/*.dat or localStorage
# This script extracts accent from Omarchy's colors.toml and writes to Vega's store if found.
set -euo pipefail

OMARCHY_THEME_DIR="$HOME/.config/omarchy/current/theme"
OMARCHY_COLORS=""
if [[ -f "$HOME/.config/omarchy/themes/macchiato-core/colors.toml" ]]; then
  # fallback
  true
fi

# Try to locate colors.toml for current theme
find_accent() {
  local theme_name
  theme_name="$(omarchy theme current 2>/dev/null | tr -d '\n' || echo "")"
  local candidates=(
    "$HOME/.config/omarchy/current/theme/colors.toml"
    "$HOME/.config/omarchy/themes/$theme_name/colors.toml"
    "$HOME/.local/share/omarchy/current/theme/colors.toml"
  )
  for f in "${candidates[@]}"; do
    if [[ -f "$f" ]]; then
      # parse accent = "#xxxxxx"
      local accent
      accent="$(grep -E '^\s*accent\s*=' "$f" | head -n1 | sed -E 's/.*"(.*)".*/\1/' | tr -d " '\"")"
      if [[ -n "$accent" && "$accent" =~ ^#[0-9a-fA-F]{3,6}$ ]]; then
        echo "$accent"
        return 0
      fi
    fi
  done
  # fallback: try alacritty.toml
  for f in "${candidates[@]/colors.toml/alacritty.toml}"; do
    if [[ -f "$f" ]]; then
      local blue
      blue="$(grep -E 'blue\s*=' "$f" | head -n1 | sed -E 's/.*"(.*)".*/\1/')"
      if [[ -n "$blue" ]]; then echo "$blue"; return 0; fi
    fi
  done
  echo ""
}

ACCENT="$(find_accent)"
if [[ -z "$ACCENT" ]]; then
  echo "[vega-theme-sync] No accent found, using default #c6a0f6 (macchiato-core)"
  ACCENT="#c6a0f6"
fi

echo "[vega-theme-sync] Omarchy accent: $ACCENT"

# Find Vega store file (tauri-plugin-store uses .dat JSON)
VEGA_STORE_DIR="$HOME/.local/share/com.vega.desktop"
VEGA_STORE_FILE=""
if [[ -d "$VEGA_STORE_DIR" ]]; then
  VEGA_STORE_FILE="$(find "$VEGA_STORE_DIR" -name "*.dat" -o -name "*.json" | head -n1 || true)"
fi

if [[ -n "$VEGA_STORE_FILE" && -f "$VEGA_STORE_FILE" ]]; then
  echo "[vega-theme-sync] Found Vega store: $VEGA_STORE_FILE"
  # Backup
  cp "$VEGA_STORE_FILE" "$VEGA_STORE_FILE.bak.$(date +%s)" 2>/dev/null || true
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$VEGA_STORE_FILE" "$ACCENT" << 'PY'
import json, sys, pathlib
path, accent = sys.argv[1], sys.argv[2]
p = pathlib.Path(path)
try:
    data = json.loads(p.read_text())
except:
    data = {}
# Vega uses primaryColor and isCustomTheme via StorageService (tauri store)
# Store is a flat JSON: keys are strings
data["primaryColor"] = accent
data["isCustomTheme"] = True
data["customColor"] = accent
p.write_text(json.dumps(data, indent=2))
print(f"[vega-theme-sync] Updated Vega store primaryColor -> {accent}")
PY
  else
    echo "[vega-theme-sync] python3 not found, skipping store patch. Set accent manually in Vega Settings: $ACCENT"
  fi
else
  echo "[vega-theme-sync] Vega store not found (launch Vega once first). Accent to set manually in Vega Settings: $ACCENT"
  echo "[vega-theme-sync] Or set via localStorage in DevTools: localStorage.setItem('theme-storage', JSON.stringify({state:{primary:'$ACCENT',isCustom:true}}))"
fi

# Also offer to write a CSS override for future builds
echo "[vega-theme-sync] Done. Restart Vega to apply if it was running."
