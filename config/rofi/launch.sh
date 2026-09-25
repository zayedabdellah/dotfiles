#!/usr/bin/env bash

set -euo pipefail

icon_theme_installed() {
    local theme="$1"
    local data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
    local path

    for path in \
        "$data_home/icons/$theme" \
        "$HOME/.local/share/icons/$theme" \
        "/usr/local/share/icons/$theme" \
        "/usr/share/icons/$theme"; do
        if [[ -f "$path/index.theme" ]]; then
            return 0
        fi
    done
    return 1
}

if icon_theme_installed "Oranchelo"; then
    exec rofi -icon-theme Oranchelo "$@"
fi

if icon_theme_installed "Papirus-Dark"; then
    echo "dotfiles: Oranchelo is unavailable; using Papirus-Dark for Rofi icons" >&2
    exec rofi -icon-theme Papirus-Dark "$@"
fi

echo "dotfiles: neither Oranchelo nor Papirus-Dark was found; Rofi will use its default icon behavior" >&2
exec rofi "$@"
