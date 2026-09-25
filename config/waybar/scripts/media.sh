#!/usr/bin/env bash
status=$(playerctl status 2>/dev/null)
if [ "$status" == "Playing" ] || [ "$status" == "Paused" ]; then
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    echo "{\"text\": \"$artist - $title\", \"class\": \"playing\"}"
else
    echo "{\"text\": \"\", \"class\": \"hidden\"}"
fi
