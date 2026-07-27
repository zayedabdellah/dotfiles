#!/bin/bash
set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPER="$CONFIG_HOME/hypr/wallpapers/torii.jpg"

if [[ ! -r "$WALLPAPER" ]]; then
    echo "dotfiles: Torii wallpaper not found; retaining the current wallpaper" >&2
    exit 0
fi

if ! command -v awww >/dev/null 2>&1; then
    echo "dotfiles: awww client is unavailable; Torii was not applied" >&2
    exit 1
fi
if ! command -v awww-daemon >/dev/null 2>&1; then
    echo "dotfiles: awww-daemon is unavailable; Torii was not applied" >&2
    exit 1
fi

if ! awww query >/dev/null 2>&1; then
    awww-daemon --no-cache >/dev/null 2>&1 &
    for _ in {1..100}; do
        if awww query >/dev/null 2>&1; then
            break
        fi
        sleep 0.1
    done
fi

if ! awww query >/dev/null 2>&1; then
    echo "dotfiles: awww-daemon did not become ready within 10 seconds; Torii was not applied" >&2
    exit 1
fi

if ! awww img --transition-type none "$WALLPAPER"; then
    echo "dotfiles: awww failed to apply Torii wallpaper: $WALLPAPER" >&2
    exit 1
fi
