#!/usr/bin/env bash
set -euo pipefail

# Resolve sink IDs by stable node.name substring (survives unplug/replug)
get_sink_id() {
  local pattern="$1"
  wpctl list audio sinks 2>/dev/null | awk -v p="$pattern" 'tolower($0) ~ tolower(p) {print $1; exit}'
}

RAZER_ID=$(get_sink_id "blackshark")
PEBBLE_ID=$(get_sink_id "pebble")
CURRENT_ID=$(wpctl list audio sinks 2>/dev/null | awk '/\*/ {print $1}')

# Available targets, Razer first (preferred fallback)
TARGETS=()
[ -n "$RAZER_ID" ] && TARGETS+=("$RAZER_ID")
[ -n "$PEBBLE_ID" ] && TARGETS+=("$PEBBLE_ID")

if [ ${#TARGETS[@]} -eq 0 ]; then
  noctalia msg notification-show "Audio Toggle" -- "Neither Razer BlackShark nor Pebble V3 is available."
  exit 1
elif [ ${#TARGETS[@]} -eq 1 ]; then
  TARGET_ID="${TARGETS[0]}"
elif [ "$CURRENT_ID" = "${TARGETS[0]}" ]; then
  TARGET_ID="${TARGETS[1]}"
else
  TARGET_ID="${TARGETS[0]}"
fi

[ "$CURRENT_ID" = "$TARGET_ID" ] && exit 0

wpctl set-default "$TARGET_ID"
