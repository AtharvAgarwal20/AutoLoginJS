#!/bin/bash

# Stop the AutoLogin Watchdog LaunchAgent

LABEL="com.autologinjs.watchdog"

if launchctl list | grep -q "$LABEL"; then
	launchctl unload ~/Library/LaunchAgents/$LABEL.plist 2>/dev/null
	echo "✅ Watchdog stopped."
else
	echo "ℹ️  Watchdog is not running."
fi
