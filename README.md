# Mouse Remapper for macOS

A Swift-based daemon that remaps mouse buttons to keyboard shortcuts and provides configurable scroll direction control.

## Features

- 🖱️ Remap mouse buttons to keyboard shortcuts
- 📜 Separate scroll direction control for mouse and trackpad (Y-axis only)
- ⚙️ JSON-based configuration
- 🔄 Runs as a background daemon process

## Installation
```bash
# 1. Clone/create the project
git clone <repo> && cd MouseRemapper

# 2. Build and create the app bundle
make app

# 3. Install to /Applications
make install

# 4. Grant Accessibility Permissions
# Open System Preferences > Privacy & Security > Accessibility
# Click the lock icon to unlock
# Click "+" and add: /Applications/MouseRemapper.app
# Make sure the checkbox is enabled

# 5. Set up autostart (optional)
make autostart
```

## Usage

Once installed and permissions are granted, the daemon runs automatically in the background.

### Makefile Commands
```bash
make build      # Build the executable
make app        # Create app bundle
make install    # Install to /Applications
make autostart  # Set up automatic launch on login
make start      # Start the daemon
make stop       # Stop the daemon
make status     # Check if daemon is running
make logs       # View daemon logs
make uninstall  # Remove app and launch agent
make clean      # Clean build artifacts
```

### Managing the Daemon
```bash
# Start the daemon
make start

# Stop the daemon
make stop

# Check status
make status

# View logs in real-time
make logs

# View logs manually
cat /tmp/mouse-remapper.log
cat /tmp/mouse-remapper.error.log
```

## Configuration

The daemon uses a JSON config file at `~/.config/mouse-remapper/config.json`.

A default config is created automatically on first run:
```json
{
  "reverseMouseScroll": true,
  "reverseTrackpadScroll": false,
  "buttonMappings": [
    {
      "button": 3,
      "action": {
        "type": "key",
        "keyCode": 123,
        "modifiers": ["control"]
      }
    },
    {
      "button": 4,
      "action": {
        "type": "key",
        "keyCode": 124,
        "modifiers": ["control"]
      }
    }
  ]
}
```

### Configuration Options

**Scroll Settings:**
- `reverseMouseScroll`: Reverse Y-axis scrolling for mice only
- `reverseTrackpadScroll`: Reverse Y-axis scrolling for trackpad
- Note: X-axis (horizontal) scrolling is never reversed

**Button Mappings:**

Each button mapping has:
- `button`: Mouse button number (0=Left, 1=Right, 2=Middle, 3=Back, 4=Forward, 5+=Other)
- `action`: What to do when the button is pressed

**Action Types:**

1. **Keyboard Shortcut** (`type: "key"`):
```json
{
  "button": 3,
  "action": {
    "type": "key",
    "keyCode": 123,
    "modifiers": ["control", "shift"]
  }
}
```

2. **Mouse Button** (`type: "mouse"`):
```json
{
  "button": 3,
  "action": {
    "type": "mouse",
    "mouseButton": 1
  }
}
```

3. **Pass Through** (`type: "passthrough"`):
```json
{
  "button": 3,
  "action": {
    "type": "passthrough"
  }
}
```

### Key Codes Reference

Common key codes for use in configuration:

**Arrow Keys:**
- Left: 123
- Right: 124
- Up: 126
- Down: 125

**Common Keys:**
- Tab: 48
- Space: 49
- Escape: 53
- Return: 36
- Delete: 51

**Function Keys:**
- F1: 122
- F2: 120
- F3: 99
- F4: 118

**Modifiers:**
- `"control"` or `"ctrl"` - Control key
- `"shift"` - Shift key
- `"command"` or `"cmd"` - Command key
- `"option"` or `"alt"` - Option/Alt key

### Reloading Configuration

After editing the config file:
```bash
# Stop and restart the daemon
make stop
make start

# Or use launchctl directly
launchctl unload ~/Library/LaunchAgents/com.user.MouseRemapper.plist
launchctl load ~/Library/LaunchAgents/com.user.MouseRemapper.plist
```

## Troubleshooting

### Daemon won't start

1. Check if accessibility permissions are granted:
   - System Preferences > Privacy & Security > Accessibility
   - MouseRemapper.app should be in the list with checkbox enabled

2. Check logs for errors:
```bash
   cat /tmp/mouse-remapper.error.log
```

3. Try running manually to see errors:
```bash
   /Applications/MouseRemapper.app/Contents/MacOS/MouseRemapper
```

### Button mappings not working

1. Verify the daemon is running:
```bash
   make status
```

2. Check your config syntax:
```bash
   cat ~/.config/mouse-remapper/config.json
```

3. Look at the startup logs to see what mappings were loaded:
```bash
   cat /tmp/mouse-remapper.log
```

### Desktop switching not working

Make sure Mission Control shortcuts are enabled:
- System Preferences > Keyboard > Keyboard Shortcuts > Mission Control
- Enable "Move left a space" (^←) and "Move right a space" (^→)

## Uninstallation
```bash
# Remove app, daemon, and config
make uninstall

# Manually remove from Accessibility preferences:
# System Preferences > Privacy & Security > Accessibility
# Select MouseRemapper and click "-"

# Remove config (optional)
rm -rf ~/.config/mouse-remapper
```

## Project Structure
```
MouseRemapper/
├── Package.swift
├── Makefile
├── Info.plist
├── README.md
├── Sources/
│   └── MouseRemapper/
│       ├── main.swift
│       ├── MouseRemapper.swift
│       ├── ConfigManager.swift
│       ├── Config.swift
│       └── EventHandler.swift
└── Resources/
    └── config.example.json
```

## Building
```bash
# Development build
swift build

# Release build
swift build -c release

# Create app bundle
make app
```

## License

MIT