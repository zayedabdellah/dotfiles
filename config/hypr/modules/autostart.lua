-------------------
---- AUTOSTART ----
-------------------

local machine = require("machine")

local function optional(command, probe)
    hl.exec_cmd(probe .. " >/dev/null 2>&1 && " .. command)
end

hl.on("hyprland.start", function()
    hl.exec_cmd("echo 'Xft.dpi: " .. tostring(machine.env.XFT_DPI or "96") .. "' | xrdb -merge")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd(machine.commands.pipewire_launcher)
    optional(machine.commands.waybar_launcher, "command -v waybar")
    optional(machine.commands.media_daemon, "test -x " .. machine.commands.media_daemon)
    hl.exec_cmd("swaync")
    optional(machine.commands.wallpaper, "test -x " .. machine.commands.wallpaper)
    optional("blueman-applet", "command -v blueman-applet")
    optional("tailscale systray", "command -v tailscale")
    hl.exec_cmd("sleep 2 && rog-control-center")
    optional(machine.commands.polkit_agent, machine.commands.polkit_probe)
end)
