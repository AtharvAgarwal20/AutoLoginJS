#!/bin/bash

# Start the AutoLogin Watchdog on Linux (systemd)

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SERVICE_FILE="$SCRIPT_DIR/linux/autologin-watchdog.service"
SERVICE_NAME="autologin-watchdog"

# Update the ExecStart path in the service file to point to the actual location
sudo cp "$SERVICE_FILE" /etc/systemd/system/$SERVICE_NAME.service
sudo sed -i "s|/opt/autologinjs/watchdog.sh|$SCRIPT_DIR/watchdog.sh|g" /etc/systemd/system/$SERVICE_NAME.service

sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "✅ Watchdog started! It will now run in the background and persist across reboots."
echo "   Logs: $SCRIPT_DIR/watchdog.log"
echo "   Status: sudo systemctl status $SERVICE_NAME"
echo "   Stop: ./linux/stop.sh"
