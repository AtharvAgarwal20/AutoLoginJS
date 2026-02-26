#!/bin/bash

# AutoLogin Watchdog for BITS Wi-Fi
# Continuously monitors the captive portal session and re-authenticates when needed.
# Supports: BITS-STAFF, BITS-STUDENT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/watchdog.log"
CHECK_INTERVAL=300 # 5 minutes

KNOWN_NETWORKS=("BITS-STAFF" "BITS-STUDENT")

log() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >>"$LOG_FILE"
}

# Trim log file to last 500 lines on start
if [ -f "$LOG_FILE" ]; then
	tail -500 "$LOG_FILE" >"$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

log "🔁 Watchdog started (checking every $((CHECK_INTERVAL / 60))m)"

while true; do
	CURRENT_WIFI=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/{print $2}')

	MATCHED=false
	for NETWORK in "${KNOWN_NETWORKS[@]}"; do
		if [ "$CURRENT_WIFI" = "$NETWORK" ]; then
			MATCHED=true
			break
		fi
	done

	if [ "$MATCHED" = false ]; then
		log "⏸  Not on a known network (current: ${CURRENT_WIFI:-none}). Skipping."
		sleep "$CHECK_INTERVAL"
		continue
	fi

	RESPONSE=$(curl -s -L --max-time 5 http://captive.apple.com 2>/dev/null)

	if echo "$RESPONSE" | grep -q "Success"; then
		log "✅ Session active on $CURRENT_WIFI."
	else
		log "🔐 Session expired on $CURRENT_WIFI! Re-authenticating..."
		cd "$SCRIPT_DIR" && node index.js >>"$LOG_FILE" 2>&1
		log "✅ Login script finished."
	fi

	sleep "$CHECK_INTERVAL"
done
