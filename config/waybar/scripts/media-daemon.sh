#!/usr/bin/env bash

CONFIG_TOP="$HOME/.config/waybar/config-top.jsonc"

while true; do
    STATUS=$(playerctl status 2>/dev/null)
    IS_RUNNING=$(pgrep -f "waybar -c $CONFIG_TOP")

    if [ "$STATUS" = "Playing" ]; then
        if [ -z "$IS_RUNNING" ]; then
            waybar -c "$CONFIG_TOP" &
        fi
    else
        if [ ! -z "$IS_RUNNING" ]; then
            pkill -f "waybar -c $CONFIG_TOP"
            
            # Force window manager to recalculate layout positions instantly
            if command -v hyprctl &> /dev/null; then
                hyprctl setprop active opaque toggle &> /dev/null
                hyprctl setprop active opaque toggle &> /dev/null
            fi
        fi
    fi
    sleep 1
done
