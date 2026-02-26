#!/bin/bash

# Stop the AutoLogin Watchdog on Linux (systemd)

SERVICE_NAME="autologin-watchdog"

if systemctl is-active --quiet $SERVICE_NAME; then
	sudo systemctl stop $SERVICE_NAME
	sudo systemctl disable $SERVICE_NAME
	echo "✅ Watchdog stopped."
else
	echo "ℹ️  Watchdog is not running."
fi
