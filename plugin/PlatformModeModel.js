var BASIC_MODES = ["balanced", "performance"]

function parsePlatformModes(raw) {
  var lines = String(raw || "").split("\n")
  var modes = []
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim()
    if (!line) continue
    var name = ""
    var active = false
    if (line.indexOf("\t") >= 0) {
      var parts = line.split("\t")
      name = parts[0]
      active = parts[1] === "1"
    } else {
      name = line
    }
    if (BASIC_MODES.indexOf(name) !== -1) continue
    modes.push({ name: name, active: active })
  }
  return modes
}

function modeIcon(name) {
  if (name === "low-power") return "󰌪"
  if (name === "balanced") return "󰊚"
  if (name === "performance") return "󰓅"
  if (name === "max-power") return "󰄀"
  if (name === "custom") return "󰊗"
  return "󰂄"
}

function modeDisplayName(name) {
  var map = {
    "low-power": "Quiet",
    "balanced": "Balanced",
    "performance": "Performance",
    "max-power": "Turbo",
    "custom": "Custom"
  }
  return map[name] || name.charAt(0).toUpperCase() + name.slice(1)
}

if (typeof module !== "undefined") {
  module.exports = {
    parsePlatformModes: parsePlatformModes,
    modeIcon: modeIcon,
    modeDisplayName: modeDisplayName
  }
}
