#!/usr/bin/env bash

set -u

WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
LOCK_DIR="$RUNTIME_DIR/dotfiles-waybar-locks"
MEDIA_PID="$LOCK_DIR/media-bar.pid"
mkdir -p "$LOCK_DIR"

# Only one monitor may own the top media bar lifecycle.
exec 9>"$LOCK_DIR/media-monitor.lock"
flock -n 9 || exit 0

stop_bar() {
    if [[ -r "$MEDIA_PID" ]]; then
        local pid
        read -r pid < "$MEDIA_PID"
        if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null \
            && [[ -r "/proc/$pid/cmdline" ]] \
            && tr '\0' ' ' < "/proc/$pid/cmdline" | grep -Eq 'launch-top\.sh|config-top\.jsonc'; then
            kill -TERM "$pid" 2>/dev/null || true
            for _ in {1..20}; do
                kill -0 "$pid" 2>/dev/null || break
                sleep 0.1
            done
            kill -KILL "$pid" 2>/dev/null || true
        fi
        rm -f "$MEDIA_PID"
    fi
}

cleanup() {
    stop_bar
}
trap cleanup EXIT
trap 'exit 0' INT TERM HUP

active_player() {
    local player status
    while IFS= read -r player; do
        [[ -n "$player" ]] || continue
        status=$(playerctl --player="$player" status 2>/dev/null) || continue
        if [[ "$status" == "Playing" ]]; then
            return 0
        fi
    done < <(playerctl --list-all 2>/dev/null || true)
    return 1
}

bar_pid=""
while true; do
    if active_player; then
        if [[ -z "$bar_pid" ]] || ! kill -0 "$bar_pid" 2>/dev/null; then
            rm -f "$MEDIA_PID"
            "$WAYBAR_DIR/launch-top.sh" &
            bar_pid=$!
            printf '%s\n' "$bar_pid" > "$MEDIA_PID"
        fi
    else
        stop_bar
        bar_pid=""
    fi
    sleep 1
done
