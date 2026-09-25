#!/usr/bin/env bash

set -euo pipefail

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_FILE="$CONFIG_HOME/hypr/hyprlock.conf"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
RUNTIME_CONFIG="$RUNTIME_DIR/dotfiles-hyprlock-${UID:-$(id -u)}.conf"
WALLPAPER="$CONFIG_HOME/hypr/wallpapers/torii.jpg"

if [[ ! -r "$CONFIG_FILE" ]]; then
    echo "dotfiles: missing Hyprlock configuration: $CONFIG_FILE" >&2
    exec hyprlock "$@"
fi

if [[ -e "$WALLPAPER" && ! -r "$WALLPAPER" ]]; then
    echo "dotfiles: Torii wallpaper exists but is unreadable: $WALLPAPER" >&2
    exit 1
elif [[ -r "$WALLPAPER" ]]; then
    # The shared Torii image is only read by this wrapper and is never
    # replaced or removed by it, regardless of the selected machine profile.
    wallpaper_path="$WALLPAPER"
else
    wallpaper_path="screenshot"
    echo "dotfiles: Torii wallpaper not found; using Hyprlock screenshot fallback" >&2
fi

escaped_path=${wallpaper_path//\\/\\\\}
escaped_path=${escaped_path//&/\\&}
escaped_path=${escaped_path//#/\\#}

umask 077
sed "s#^[[:space:]]*path = .*#    path = $escaped_path#" "$CONFIG_FILE" > "$RUNTIME_CONFIG"
exec hyprlock --config "$RUNTIME_CONFIG" "$@"
