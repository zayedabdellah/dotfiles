#!/usr/bin/env bash

set -u

percent="$(brightnessctl -m 2>/dev/null | awk -F, 'NR == 1 { gsub(/%/, "", $4); print $4; exit }')"
if [[ "$percent" =~ ^[0-9]+$ ]]; then
    text="󰃠 ${percent}%"
    tooltip="Backlight brightness: ${percent}%"
    class="available"
else
    text="󰃠 --"
    tooltip="Backlight status unavailable"
    class="unavailable"
fi

jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
    '{text: $text, tooltip: $tooltip, class: $class}'
