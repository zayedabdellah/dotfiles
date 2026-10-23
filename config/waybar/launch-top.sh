#!/usr/bin/env bash

set -euo pipefail

WAYBAR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
WAYBAR_CONFIG="$WAYBAR_CONFIG_DIR/config-top.jsonc"
WAYBAR_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WAYBAR_LOCK_DIR="$WAYBAR_RUNTIME_DIR/dotfiles-waybar-locks"

if [[ ! -r "$WAYBAR_CONFIG" ]]; then
    echo "dotfiles: missing top Waybar config: $WAYBAR_CONFIG" >&2
    exit 1
fi

mkdir -p "$WAYBAR_LOCK_DIR"
exec 9>"$WAYBAR_LOCK_DIR/top.lock"
flock -n 9 || exit 0
exec waybar -c "$WAYBAR_CONFIG"
