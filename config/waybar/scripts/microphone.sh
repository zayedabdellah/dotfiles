#!/usr/bin/env bash

set -u

icon='󰍬'
fallback=$(jq -cn --arg text "$icon" --arg tooltip 'Microphone state unavailable' \
  '{text:$text,tooltip:$tooltip,class:"unavailable"}')

if ! command -v pactl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
    printf '%s\n' "$fallback"
    exit 0
fi

sources=$(pactl -f json list sources 2>/dev/null) || {
    printf '%s\n' "$fallback"
    exit 0
}
streams=$(pactl -f json list source-outputs 2>/dev/null) || streams='[]'

default_name=$(pactl get-default-source 2>/dev/null) || default_name=''
source=$(jq -c --arg name "$default_name" '[.[] | select(.name == $name)][0] // empty' <<<"$sources")

if [[ -z "$source" ]]; then
    printf '%s\n' "$fallback"
    exit 0
fi

index=$(jq -r '.index // ""' <<<"$source")
description=$(jq -r '.description // .name // "Microphone"' <<<"$source")
muted=$(jq -r '.mute // false' <<<"$source")
recording=false
if [[ "$muted" != true && -n "$index" ]] \
    && jq -e --argjson index "$index" 'any(.[]; .source == $index)' <<<"$streams" >/dev/null 2>&1; then
    recording=true
fi

if [[ "$recording" == true ]]; then
    text="$icon REC"
    tooltip="Recording · $description"
    class='recording'
elif [[ "$muted" == true ]]; then
    text='󰍭'
    tooltip="Muted · $description"
    class='muted'
else
    text="$icon"
    tooltip="Microphone · $description"
    class='idle'
fi

jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{text:$text,tooltip:$tooltip,class:$class}'
