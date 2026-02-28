#!/bin/bash

# AutoLogin Watchdog for BITS Wi-Fi
# Continuously monitors the captive portal session and re-authenticates when needed.
# Works by checking Apple's captive portal detection URL.
# Configuration is read from the .env file.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/watchdog.log"

# Load CHECK_INTERVAL from .env (default: 300 seconds)
if [ -f "$SCRIPT_DIR/.env" ]; then
	CHECK_INTERVAL=$(grep -E '^CHECK_INTERVAL=' "$SCRIPT_DIR/.env" | cut -d'=' -f2 | tr -d '"' | tr -d ' ')
fi
CHECK_INTERVAL="${CHECK_INTERVAL:-300}"

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$LOG_FILE"
}

# Trim log file to last 500 lines on start
if [ -f "$LOG_FILE" ]; then
	tail -500 "$LOG_FILE" >"$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

log "🔁 Watchdog started (interval: ${CHECK_INTERVAL}s)"

LOOP_COUNT=0

while true; do
	RESPONSE=$(curl -s -L --max-time 5 http://captive.apple.com 2>/dev/null)
	CURL_EXIT=$?

	if [ "$CURL_EXIT" -ne 0 ]; then
		log "📡 No network connection (Wi-Fi off?). Skipping."
	elif echo "$RESPONSE" | grep -q "Success"; then
		log "✅ Session active."
	else
		log "🔐 Captive portal detected! Re-authenticating..."

		# Disconnect Cloudflare WARP if it's running (it blocks captive portal)
		if command -v warp-cli &>/dev/null; then
			WARP_STATUS=$(warp-cli status 2>/dev/null | grep -i "connected" || true)
			if [ -n "$WARP_STATUS" ]; then
				log "🛑 Disconnecting Cloudflare WARP..."
				warp-cli disconnect >>"$LOG_FILE" 2>&1
				sleep 2
			fi
		fi

		cd "$SCRIPT_DIR" && node index.js >>"$LOG_FILE" 2>&1
		log "✅ Login script finished."

		# Reconnect WARP after successful login
		if command -v warp-cli &>/dev/null; then
			log "🔄 Reconnecting Cloudflare WARP..."
			warp-cli connect >>"$LOG_FILE" 2>&1
		fi
	fi

	# Trim log every ~50 checks to prevent bloat
	LOOP_COUNT=$((LOOP_COUNT + 1))
	if [ "$LOOP_COUNT" -ge 50 ]; then
		tail -200 "$LOG_FILE" >"$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
		LOOP_COUNT=0
	fi

	sleep "$CHECK_INTERVAL"
done
