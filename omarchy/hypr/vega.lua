-- Vega Desktop - Omarchy Hyprland integration
-- Place this file at: ~/.config/hypr/vega.lua
-- And add `require("hypr.vega")` to your ~/.config/hypr/hyprland.lua
-- or it will be auto-required if you use the install.sh script.

-- Vega uses Tauri with transparent window + custom decorations (client-side)
-- These rules make it feel native on Hyprland/Omarchy

-- Main Vega window: opaque, rounded, tiled by default, no extra opacity
o.window({ class = "^(Vega|com.vega.desktop)$" }, {
  tag = "-default-opacity",
  opacity = "1 1",
  rounding = 12,
  decorate = true,
  border_size = 2,
})

-- When Vega is in fullscreen (player mode), remove borders/shadows
o.window({ class = "^(Vega|com.vega.desktop)$", fullscreen = true }, {
  border_size = 0,
  rounding = 0,
  no_shadow = true,
  idle_inhibit = "fullscreen",
})

-- Floating for dialogs (Tauri dialog plugin opens file pickers)
o.window({ class = "^(Vega|com.vega.desktop)$", title = ".*(Open|Save|File|Folder).*" }, {
  float = true,
  center = true,
  size = { 900, 600 },
})

-- Picture-in-picture from Vega player: keep on top, small corner
o.window({ class = "^(Vega|com.vega.desktop)$", title = ".*Picture.?in.?[Pp]icture.*" }, {
  tag = "+pip",
  pin = true,
})

-- Optional: assign Vega to workspace 4 (media workspace) on launch
-- Uncomment if you want auto-workspace:
-- o.window({ class = "^(Vega|com.vega.desktop)$" }, { workspace = "4" })

-- Fix XWayland fallback (shouldn't trigger, Tauri is Wayland-native, but safe)
o.window({ class = "^(Vega)$", xwayland = true }, { center = true })
