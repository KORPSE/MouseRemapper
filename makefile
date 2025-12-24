.PHONY: build clean install uninstall app

APP_NAME = MouseRemapper
BUNDLE_ID = com.user.MouseRemapper
BUILD_DIR = .build/release
EXECUTABLE = $(BUILD_DIR)/mouse-remapper
APP_DIR = $(BUILD_DIR)/$(APP_NAME).app
CONTENTS_DIR = $(APP_DIR)/Contents
MACOS_DIR = $(CONTENTS_DIR)/MacOS
INSTALL_DIR = /Applications

build:
	@echo "Building MouseRemapper..."
	swift build -c release
	@echo "Build complete"
	@echo "Checking for executable..."
	@if [ -f "$(EXECUTABLE)" ]; then \
		echo "Found: $(EXECUTABLE)"; \
	else \
		echo "Executable not found at $(EXECUTABLE)"; \
		echo "Contents of $(BUILD_DIR):"; \
		ls -la "$(BUILD_DIR)" 2>/dev/null || echo "Build directory doesn't exist"; \
		exit 1; \
	fi

app: build
	@echo "Creating app bundle..."
	mkdir -p "$(MACOS_DIR)"
	cp "$(EXECUTABLE)" "$(MACOS_DIR)/MouseRemapper"
	cp Info.plist "$(CONTENTS_DIR)/"
	@echo "App bundle created at $(APP_DIR)"

install: app
	@echo "Installing to $(INSTALL_DIR)..."
	rm -rf "$(INSTALL_DIR)/$(APP_NAME).app"
	cp -R "$(APP_DIR)" "$(INSTALL_DIR)/"
	@echo "Installed successfully"
	@echo ""
	@echo "Next steps:"
	@echo "1. Open System Preferences > Privacy & Security > Accessibility"
	@echo "2. Click the '+' button and add: $(INSTALL_DIR)/$(APP_NAME).app"
	@echo "3. Run 'make autostart' to set up automatic launch on login"

autostart: install
	@echo "Setting up autostart..."
	@mkdir -p ~/Library/LaunchAgents
	@echo '<?xml version="1.0" encoding="UTF-8"?>' > ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '<plist version="1.0">' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '<dict>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <key>Label</key>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <string>$(BUNDLE_ID)</string>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <key>ProgramArguments</key>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <array>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '        <string>$(INSTALL_DIR)/$(APP_NAME).app/Contents/MacOS/MouseRemapper</string>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    </array>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <key>RunAtLoad</key>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <true/>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <key>KeepAlive</key>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <true/>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <key>StandardOutPath</key>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <string>/tmp/mouse-remapper.log</string>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <key>StandardErrorPath</key>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '    <string>/tmp/mouse-remapper.error.log</string>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '</dict>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo '</plist>' >> ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	launchctl unload ~/Library/LaunchAgents/$(BUNDLE_ID).plist 2>/dev/null || true
	launchctl load ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	@echo "Autostart configured. Daemon is now running and will start on login."
	@echo "Logs: /tmp/mouse-remapper.log"

uninstall:
	@echo "Uninstalling..."
	launchctl unload ~/Library/LaunchAgents/$(BUNDLE_ID).plist 2>/dev/null || true
	rm -rf ~/Library/LaunchAgents/$(BUNDLE_ID).plist
	rm -rf "$(INSTALL_DIR)/$(APP_NAME).app"
	@echo "Uninstalled. You can manually remove it from Accessibility preferences."

clean:
	swift package clean
	rm -rf $(BUILD_DIR)
	@echo "Cleaned build artifacts"

start:
	launchctl load ~/Library/LaunchAgents/$(BUNDLE_ID).plist

stop:
	launchctl unload ~/Library/LaunchAgents/$(BUNDLE_ID).plist

status:
	@launchctl list | grep $(BUNDLE_ID) || echo "Daemon not running"

logs:
	@tail -f /tmp/mouse-remapper.log

debug:
	@echo "Checking build output..."
	@ls -la $(BUILD_DIR) 2>/dev/null || echo "Build directory not found"