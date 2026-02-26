#!/bin/bash

# Start the AutoLogin Watchdog LaunchAgent

LABEL="com.autologinjs.watchdog"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_SRC="$SCRIPT_DIR/$LABEL.plist"
PLIST_DST="$HOME/Library/LaunchAgents/$LABEL.plist"

# Create LaunchAgents directory if it doesn't exist
mkdir -p ~/Library/LaunchAgents

# Unload if already loaded
launchctl unload "$PLIST_DST" 2>/dev/null

# Copy plist to LaunchAgents
cp "$PLIST_SRC" "$PLIST_DST"

# Load the agent
launchctl load "$PLIST_DST"

echo "✅ Watchdog started! It will now run in the background and persist across reboots."
echo "   Logs: $SCRIPT_DIR/watchdog.log"
echo "   Stop: ./stop.sh"
