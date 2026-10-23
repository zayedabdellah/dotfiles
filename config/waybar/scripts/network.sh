#!/usr/bin/env bash

set -u

interface="${DOTFILES_NETWORK_INTERFACE:-}"
if [[ -z "$interface" ]] && command -v ip >/dev/null 2>&1; then
    interface="$(ip -o route show default 2>/dev/null | awk 'NR == 1 { for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }')"
fi

# Default disconnected states
text="󰖪"
tooltip="Network disconnected"
class="disconnected"

if [[ -n "$interface" ]] && command -v nmcli >/dev/null 2>&1; then
    mapfile -t device_info < <(nmcli -g GENERAL.STATE,GENERAL.TYPE,GENERAL.CONNECTION device show "$interface" 2>/dev/null || true)
    state="${device_info[0]:-}"
    type="${device_info[1]:-}"
    connection="${device_info[2]:-}"

    case "$state" in
        100*)
            case "$type" in
                wifi)
                    signal="$(nmcli -t --escape yes -f ACTIVE,SIGNAL device wifi list --rescan no 2>/dev/null | awk -F: '$1 == "yes" { print $2; exit }')"

                    # Core change: only the icon is outputted as the text value
                    text=""

                    # Extra info like connection name and signal % appended strictly to tooltip
                    wifi_details="${connection:-Wi-Fi}"
                    if [[ "$signal" =~ ^[0-9]+$ ]]; then
                        wifi_details+=" (${signal}%)"
                    fi
                    tooltip="Wi-Fi connected on ${interface}: ${wifi_details}"
                    class="wifi"
                    ;;
                ethernet)
                    text="  "
                    tooltip="Ethernet connected on ${interface}: ${connection:-connected}"
                    class="ethernet"
                    ;;
            esac
            ;;
    esac
fi

jq -nc --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
    '{text: $text, tooltip: $tooltip, class: $class}'
