#!/bin/bash

# install.sh - Install kaun.power plugin for Omarchy
# Usage: ./install.sh

set -e

PLUGIN_DIR="$HOME/.config/omarchy/plugins/kaun.power"
SCRIPTS_DIR="$HOME/.local/bin"
POLICY_DIR="/usr/share/polkit-1/actions"

echo "Installing kaun.power plugin..."

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
sudo cp polkit/org.kaun.omarchy.platform-mode-set.policy "$POLICY_DIR/"

# Enable the plugin
echo "Enabling plugin..."
omarchy plugin enable kaun.power 2>/dev/null || true

# Restart shell to load the plugin
echo "Restarting shell..."
omarchy restart shell 2>/dev/null || true

echo ""
echo "Done! kaun.power plugin installed."
echo "Click the battery icon in the bar to see EXTRA POWER PROFILES."
echo ""
echo "Note: Changing modes requires authentication (polkit dialog)."
