#!/usr/bin/env bash

set -euo pipefail

WAYBAR_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
WAYBAR_TEMPLATE="$WAYBAR_CONFIG_DIR/config.jsonc.template"
WAYBAR_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
WAYBAR_RUNTIME_CONFIG="$WAYBAR_RUNTIME_DIR/dotfiles-waybar-${UID:-$(id -u)}.jsonc"

if [[ ! -r "$WAYBAR_TEMPLATE" ]]; then
    echo "dotfiles: missing Waybar template: $WAYBAR_TEMPLATE" >&2
    exit 1
fi

interface="${DOTFILES_NETWORK_INTERFACE:-}"
if [[ -z "$interface" ]] && command -v ip >/dev/null 2>&1; then
    interface="$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit }}' || true)"
fi

if [[ -n "$interface" && ! "$interface" =~ ^[[:alnum:]_.:-]+$ ]]; then
    echo "dotfiles: ignoring invalid network interface value: $interface" >&2
    interface=""
fi

umask 077
if [[ -n "$interface" ]]; then
    sed "s#__DOTFILES_NETWORK_INTERFACE__#$interface#g" "$WAYBAR_TEMPLATE" > "$WAYBAR_RUNTIME_CONFIG"
else
    sed '/"interface": "__DOTFILES_NETWORK_INTERFACE__"/d' "$WAYBAR_TEMPLATE" > "$WAYBAR_RUNTIME_CONFIG"
fi

pkill waybar 2>/dev/null || true
waybar -c "$WAYBAR_RUNTIME_CONFIG" &
