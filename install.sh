#!/bin/bash

# install.sh - Install extra.power-profiles plugin for Omarchy
# Usage: ./install.sh

set -e

PLUGIN_DIR="$HOME/.config/omarchy/plugins/kaun.power-profiles"
SCRIPTS_DIR="$HOME/.local/bin"
POLICY_DIR="/usr/share/polkit-1/actions"

echo "Installing extra.power-profiles plugin..."

# Create plugin directory
mkdir -p "$PLUGIN_DIR"

# Copy plugin files
cp plugin/manifest.json "$PLUGIN_DIR/"
cp plugin/Model.js "$PLUGIN_DIR/"
cp plugin/PlatformModeModel.js "$PLUGIN_DIR/"
cp plugin/Panel.qml "$PLUGIN_DIR/"

# Install helper scripts to PATH
mkdir -p "$SCRIPTS_DIR"
cp plugin/omarchy-platform-mode-list "$SCRIPTS_DIR/"
cp plugin/omarchy-platform-mode-set "$SCRIPTS_DIR/"
chmod +x "$SCRIPTS_DIR/omarchy-platform-mode-list"
chmod +x "$SCRIPTS_DIR/omarchy-platform-mode-set"

# Install polkit policy for passwordless mode switching
echo "Installing polkit policy (requires sudo)..."
if sudo -n true 2>/dev/null; then
  sudo cp polkit/org.kaun.omarchy.platform-mode-set.policy "$POLICY_DIR/"
else
  echo "Warning: Cannot install polkit policy without sudo. Please run:"
  echo "  sudo cp polkit/org.kaun.omarchy.platform-mode-set.policy $POLICY_DIR/"
fi

# Enable the plugin
echo "Enabling plugin..."
omarchy plugin enable kaun.power-profiles 2>/dev/null || true

# Add plugin to bar layout if not already present
SHELL_JSON="$HOME/.config/omarchy/shell.json"
if [[ -f "$SHELL_JSON" ]]; then
  if ! grep -q '"kaun.power-profiles"' "$SHELL_JSON"; then
    echo "Adding plugin to bar layout..."
    python3 << 'PYEOF'
import json, os
path = os.path.expanduser("~/.config/omarchy/shell.json")
with open(path, "r") as f:
    config = json.load(f)
right = config.get("bar", {}).get("layout", {}).get("right", [])
right = [item for item in right if item.get("id") != "omarchy.power"]
if not any(item.get("id") == "kaun.power-profiles" for item in right):
    right.append({"id": "kaun.power-profiles"})
config["bar"]["layout"]["right"] = right
with open(path, "w") as f:
    json.dump(config, f, indent=2)
PYEOF
  fi
fi

# Restart shell to load the plugin
echo "Restarting shell..."
omarchy restart shell 2>/dev/null || true

echo ""
echo "Done! extra.power-profiles plugin installed."
echo "Click the battery icon in the bar to see EXTRA POWER PROFILES."
echo ""
echo "Note: Changing modes requires authentication (polkit dialog)."
