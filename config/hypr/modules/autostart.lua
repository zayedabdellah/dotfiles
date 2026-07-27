-------------------
---- AUTOSTART ----
-------------------

local machine = require("machine")

local function optional(command, probe)
    hl.exec_cmd(probe .. " >/dev/null 2>&1 && " .. command)
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
    optional(machine.commands.bluetooth_applet, "command -v blueman-applet")
    optional(machine.commands.tailscale_systray, "command -v tailscale")
    --hl.exec_cmd("rog-control-center")
    optional(machine.commands.polkit_agent, machine.commands.polkit_probe)
end)
