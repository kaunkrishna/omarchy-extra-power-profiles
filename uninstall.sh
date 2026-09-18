#!/bin/bash

# uninstall.sh - Remove kaun.power plugin from Omarchy
# Usage: ./uninstall.sh

set -e

PLUGIN_DIR="$HOME/.config/omarchy/plugins/kaun.power"
SCRIPTS_DIR="$HOME/.local/bin"
POLICY_DIR="/usr/share/polkit-1/actions"

echo "Removing kaun.power plugin..."

# Disable the plugin
echo "Disabling plugin..."
omarchy plugin disable kaun.power 2>/dev/null || true

# Remove plugin directory
if [[ -d "$PLUGIN_DIR" ]]; then
  rm -rf "$PLUGIN_DIR"
  echo "Removed plugin directory"
fi

# Remove helper scripts
rm -f "$SCRIPTS_DIR/omarchy-platform-mode-list"
rm -f "$SCRIPTS_DIR/omarchy-platform-mode-set"
echo "Removed helper scripts"

# Remove polkit policy
echo "Removing polkit policy (requires sudo)..."
sudo rm -f "$POLICY_DIR/org.kaun.omarchy.platform-mode-set.policy"

# Restart shell to unload the plugin
echo "Restarting shell..."
omarchy restart shell 2>/dev/null || true

echo ""
echo "Done! kaun.power plugin removed."
