# kaun.power - Extra Power Profiles for Omarchy

An [Omarchy](https://omarchy.org/) shell plugin that extends the built-in battery/power panel with additional platform power profiles (e.g., Quiet, Turbo, Custom) for laptops that support ACPI `platform_profile`.

## Compatibility

Works on laptops with ACPI platform profile support:

- **Lenovo LOQ / IdeaPad** — `low-power`, `balanced`, `performance`, `max-power`, `custom`
- **Lenovo ThinkPad** — varies by model
- **Other Linux laptops** — check if `/sys/firmware/acpi/platform_profile_choices` exists

The plugin automatically detects available modes. If your laptop doesn't support `platform_profile`, the extra section simply won't appear.

## What It Does

Extends the battery popup panel with:

| Section | Source | Modes |
|---------|--------|-------|
| **POWER PROFILE** | `powerprofilesctl` | power-saver, balanced, performance |
| **EXTRA POWER PROFILES** | `platform_profile` | quiet, turbo, custom (varies) |

The extra section filters out `balanced` and `performance` to avoid duplicates with the standard power profiles.

## Installation

### Prerequisites

- [Omarchy](https://omarchy.org/) Linux with Hyprland
- A laptop with ACPI platform profile support
- `pkexec` (polkit) for privilege escalation

### Manual Install

```bash
git clone https://github.com/youruser/omarchy-plugin.git
cd omarchy-plugin
chmod +x install.sh
./install.sh
```

The install script will:
1. Copy plugin files to `~/.config/omarchy/plugins/kaun.power/`
2. Install helper scripts to `~/.local/bin/`
3. Install a polkit policy for mode switching
4. Enable the plugin and restart the shell

### Omarchy Plugin Install (stub)

```bash
omarchy plugin add https://github.com/youruser/omarchy-plugin.git
```

> **Note:** This repo is not yet in the official Omarchy plugin registry. Use manual install for now.

## Removal

### Manual Remove

```bash
cd omarchy-plugin
chmod +x uninstall.sh
./uninstall.sh
```

### Omarchy Plugin Remove (stub)

```bash
omarchy plugin remove kaun.power
```

## Files

```
omarchy-plugin/
├── README.md
├── install.sh
├── uninstall.sh
├── polkit/
│   └── org.kaun.omarchy.platform-mode-set.policy
└── plugin/
    ├── manifest.json
    ├── Panel.qml
    ├── Model.js
    ├── PlatformModeModel.js
    ├── omarchy-platform-mode-list
    └── omarchy-platform-mode-set
```

| File | Purpose |
|------|---------|
| `manifest.json` | Plugin metadata, registers as `kaun.power` bar widget |
| `Panel.qml` | Extended power panel UI with extra profiles section |
| `Model.js` | Battery/power profile parsing (from stock Omarchy) |
| `PlatformModeModel.js` | Platform mode parsing, icons, display names |
| `omarchy-platform-mode-list` | Reads available modes from `/sys/firmware/acpi/` |
| `omarchy-platform-mode-set` | Sets the active platform mode (requires polkit auth) |
| `polkit/*.policy` | Polkit policy for passwordless-inactive authentication |

## How It Works

1. **Detection**: `omarchy-platform-mode-list` reads `/sys/firmware/acpi/platform_profile_choices`
2. **Filtering**: `PlatformModeModel.js` removes `balanced` and `performance` (already in POWER PROFILE)
3. **Display**: Remaining modes show as buttons under "EXTRA POWER PROFILES"
4. **Switching**: Clicking a button runs `omarchy-platform-mode-set` via `pkexec` (polkit auth dialog)

## Adding Support for New Mode Names

Edit `PlatformModeModel.js` to add icons and display names for new platform mode names:

```javascript
function modeIcon(name) {
  if (name === "low-power") return "󰌪"
  if (name === "max-power") return "󰄀"
  if (name === "custom") return "󰊗"
  return "󰂄"  // fallback icon
}

function modeDisplayName(name) {
  var map = {
    "low-power": "Quiet",
    "max-power": "Turbo",
    "custom": "Custom"
  }
  return map[name] || name.charAt(0).toUpperCase() + name.slice(1)
}
```

## License

MIT
