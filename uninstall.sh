#!/bin/bash

# uninstall.sh - Remove extra.power-profiles plugin from Omarchy
# Usage: ./uninstall.sh

set -e

PLUGIN_DIR="$HOME/.config/omarchy/plugins/kaun.power-profiles"
SCRIPTS_DIR="$HOME/.local/bin"
POLICY_DIR="/usr/share/polkit-1/actions"

echo "Removing extra.power-profiles plugin..."

# Restore default power widget in bar layout BEFORE disabling
SHELL_JSON="$HOME/.config/omarchy/shell.json"
if [[ -f "$SHELL_JSON" ]]; then
  if grep -q '"kaun.power-profiles"' "$SHELL_JSON"; then
    echo "Restoring default power widget..."
    python3 << 'PYEOF'
import json, os
path = os.path.expanduser("~/.config/omarchy/shell.json")
with open(path, "r") as f:
    config = json.load(f)
right = config.get("bar", {}).get("layout", {}).get("right", [])
config["bar"]["layout"]["right"] = [item for item in right if item.get("id") != "kaun.power-profiles"]
if not any(item.get("id") == "omarchy.power" for item in config["bar"]["layout"]["right"]):
    config["bar"]["layout"]["right"].append({"id": "omarchy.power"})
with open(path, "w") as f:
    json.dump(config, f, indent=2)
PYEOF
  fi
fi

# Disable the plugin
echo "Disabling plugin..."
omarchy plugin disable kaun.power-profiles 2>/dev/null || true

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
if sudo -n true 2>/dev/null; then
  sudo rm -f "$POLICY_DIR/org.kaun.omarchy.platform-mode-set.policy"
else
  echo "Warning: Cannot remove polkit policy without sudo. Please run:"
  echo "  sudo rm -f $POLICY_DIR/org.kaun.omarchy.platform-mode-set.policy"
fi

# Restart shell to unload the plugin
echo "Restarting shell..."
omarchy restart shell 2>/dev/null || true

echo ""
echo "Done! extra.power-profiles plugin removed."
