#!/usr/bin/env bash
# Vega Wayland wrapper for Omarchy/Hyprland
# Ensures correct Wayland flags and env for WebKitGTK + MPV
set -euo pipefail

# Force Wayland for Electron/WebKit where possible, but keep X11 fallback
export GDK_BACKEND="wayland,x11"
export WEBKIT_DISABLE_DMABUF_RENDERER=0
export MOZ_ENABLE_WAYLAND=1

# Use system mpv if bundled libmpv fails
export MPV_LOG_LEVEL="${MPV_LOG_LEVEL:-warn}"

exec /usr/bin/vega-desktop "$@" 2>/dev/null || exec /opt/vega-desktop/vega-desktop "$@" 2>/dev/null || exec "$HOME/.local/share/vega-desktop/vega-desktop" "$@"
