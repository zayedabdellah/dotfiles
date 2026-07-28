-------------------
---- AUTOSTART ----
-------------------

local machine = require("machine")

local function optional(command, probe)
    hl.exec_cmd(probe .. " >/dev/null 2>&1 && " .. command)
end

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

-- Keep tray launch policy here so every machine profile behaves identically.
-- Non-blocking flock locks survive Hyprland reloads for exactly as long as the
-- corresponding tray process, and failures are recorded without aborting the
-- compositor session.
local function tray_once(name, command, executable)
    local script = table.concat({
        'state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"',
        'runtime="${XDG_RUNTIME_DIR:-$state/runtime}/dotfiles-tray"',
        'mkdir -p "$runtime" "$state" || exit 0',
        'chmod 700 "$runtime" 2>/dev/null || true',
        'log="$state/autostart.log"',
        'if ! command -v ' .. executable .. ' >/dev/null 2>&1; then printf "%s\\n" "[dotfiles] ' .. executable .. ' unavailable; tray skipped" >>"$log"; exit 0; fi',
        'if ! command -v flock >/dev/null 2>&1; then printf "%s\\n" "[dotfiles] flock unavailable; ' .. name .. ' tray skipped" >>"$log"; exit 0; fi',
        'flock -E 75 -n "$runtime/' .. name .. '.lock" ' .. command .. ' >>"$log" 2>&1',
        'status=$?',
        '[ "$status" -eq 75 ] && exit 0',
        '[ "$status" -eq 0 ] || printf "%s\\n" "[dotfiles] ' .. name .. ' exited with status $status" >>"$log"',
    }, "; ")
    hl.exec_cmd("sh -c " .. shell_quote(script) .. " >/dev/null 2>&1 &")
end

hl.on("hyprland.start", function()
    hl.exec_cmd("echo 'Xft.dpi: 96' | xrdb -merge")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd(machine.commands.pipewire_launcher)
    hl.exec_cmd(machine.commands.waybar_launcher)
    hl.exec_cmd("waybar -c " .. machine.commands.waybar_top_config)
    hl.exec_cmd(machine.commands.media_daemon)
    hl.exec_cmd("swaync")
    optional(machine.commands.wallpaper, "test -x " .. machine.commands.wallpaper)
    tray_once("blueman-applet", "blueman-applet", "blueman-applet")
    tray_once("tailscale-systray", "tailscale systray", "tailscale")
    --hl.exec_cmd("rog-control-center")
    optional(machine.commands.polkit_agent, machine.commands.polkit_probe)
end)
