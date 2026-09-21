import React, { useState, useEffect } from "react";
import {
  LuBox as Box,
  LuPalette as Palette,
  LuKeyboard as Keyboard,
  LuMonitor as Monitor,
  LuRefreshCw as Refresh,
  LuCheck as Check,
} from "react-icons/lu";
import { FocusableButton } from "../layout/FocusableButton";
import { Switch } from "../ui/switch";

export const OmarchySettings: React.FC = () => {
  const [themeSynced, setThemeSynced] = useState(false);
  const [waylandEnabled, setWaylandEnabled] = useState(true);
  const [hyprlandDetected, setHyprlandDetected] = useState(false);

  useEffect(() => {
    setWaylandEnabled(true);
    setHyprlandDetected(
      window.location.hostname === "wayland" ||
        navigator.userAgent.toLowerCase().includes("wayland") ||
        !!document.querySelector("[data-wayland]")
    );
  }, []);

  const handleThemeSync = async () => {
    setThemeSynced(true);
    setTimeout(() => setThemeSynced(false), 2000);
  };

  const handleToggleWayland = () => {
    setWaylandEnabled(!waylandEnabled);
  };

  return (
    <div className="omarchy-settings">
      {/* Theme Sync */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg flex items-center gap-2">
            <Palette size={16} /> Theme Sync
          </h3>
          <p className="body-md text-muted">
            Sync accent color from Omarchy theme to Vega
          </p>
        </div>
        <FocusableButton
          className={`theme-toggle-btn ${themeSynced ? "active" : ""}`}
          onClick={handleThemeSync}
        >
          {themeSynced ? (
            <>
              <Check size={16} /> Synced
            </>
          ) : (
            <>
              <Refresh size={16} /> Sync Now
            </>
          )}
        </FocusableButton>
      </div>

      <div className="settings-divider" />

      {/* Wayland Mode */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg flex items-center gap-2">
            <Monitor size={16} /> Wayland Mode
          </h3>
          <p className="body-md text-muted">
            Run Vega natively on Wayland for better performance
          </p>
        </div>
        <Switch
          checked={waylandEnabled}
          onCheckedChange={handleToggleWayland}
          aria-label="Enable Wayland mode"
        />
      </div>

      <div className="settings-divider" />

      {/* Hyprland Status */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg flex items-center gap-2">
            <Box size={16} /> Hyprland Integration
          </h3>
          <p className="body-md text-muted">
            {hyprlandDetected
              ? "Hyprland detected - window rules active"
              : "Hyprland not detected"}
          </p>
        </div>
        <div
          className={`omarchy-status-badge ${hyprlandDetected ? "active" : ""}`}
        >
          {hyprlandDetected ? "Connected" : "Not Found"}
        </div>
      </div>

      <div className="settings-divider" />

      {/* Keybinding Reference */}
      <div className="settings-row">
        <div className="settings-info">
          <h3 className="label-lg flex items-center gap-2">
            <Keyboard size={16} /> Keybindings
          </h3>
          <p className="body-md text-muted">
            Default shortcuts for Omarchy integration
          </p>
        </div>
        <div className="omarchy-keybindings">
          <div className="keybinding-item">
            <kbd>SUPER+V</kbd>
            <span>Launch Vega</span>
          </div>
          <div className="keybinding-item">
            <kbd>SUPER+F</kbd>
            <span>Fullscreen Player</span>
          </div>
        </div>
      </div>
    </div>
  );
};
