-------------------
---- AUTOSTART ----
-------------------

local machine = require("machine")

local function shell_quote(value)
    return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function launch(name, command, probe)
    local script = table.concat({
        'state="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles"',
        'mkdir -p "$state" || exit 0',
        'log="$state/autostart.log"',
        probe and ('if ! (' .. probe .. ') >/dev/null 2>&1; then printf "%s\\n" "[dotfiles] ' .. name .. ' prerequisite unavailable; skipped" >>"$log"; exit 0; fi') or "",
        '{ ' .. command .. '; } >>"$log" 2>&1',
        'status=$?',
        '[ "$status" -eq 0 ] || printf "%s\\n" "[dotfiles] ' .. name .. ' exited with status $status" >>"$log"',
    }, "; ")
    hl.exec_cmd("sh -c " .. shell_quote(script) .. " >/dev/null 2>&1 &")
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
    launch("audio", machine.commands.pipewire_launcher)
    launch("waybar", shell_quote(machine.commands.waybar_launcher), "test -x " .. shell_quote(machine.commands.waybar_launcher))
    launch("media bar", "waybar -c " .. shell_quote(machine.commands.waybar_top_config), "command -v waybar")
    launch("media daemon", shell_quote(machine.commands.media_daemon), "test -x " .. shell_quote(machine.commands.media_daemon))
    launch("swaync", "swaync", "command -v swaync")
    launch("wallpaper", shell_quote(machine.commands.wallpaper), "test -x " .. shell_quote(machine.commands.wallpaper))
    tray_once("blueman-applet", "blueman-applet", "blueman-applet")
    tray_once("tailscale-systray", "tailscale systray", "tailscale")
    --hl.exec_cmd("rog-control-center")
    launch("polkit agent", machine.commands.polkit_agent, machine.commands.polkit_probe)
end)
