#!/bin/bash

# AutoLogin Watchdog for BITS Wi-Fi
# Continuously monitors the captive portal session and re-authenticates when needed.
# Works by checking Apple's captive portal detection URL.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/watchdog.log"
CHECK_INTERVAL=300 # 5 minutes

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$LOG_FILE"
}

# Trim log file to last 500 lines on start
if [ -f "$LOG_FILE" ]; then
	tail -500 "$LOG_FILE" >"$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

log "🔁 Watchdog started (checking every ${CHECK_INTERVAL}s)"

while true; do
	RESPONSE=$(curl -s -L --max-time 5 http://captive.apple.com 2>/dev/null)

	if echo "$RESPONSE" | grep -q "Success"; then
		log "✅ Session active."
	else
		log "🔐 Captive portal detected! Re-authenticating..."
		cd "$SCRIPT_DIR" && node index.js >>"$LOG_FILE" 2>&1
		log "✅ Login script finished."
	fi

	sleep "$CHECK_INTERVAL"
done
