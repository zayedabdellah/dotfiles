-- Portable fallback profile. The installer should replace genuinely
-- machine-specific values through machine.local.lua or profile selection.

local home = os.getenv("HOME") or "~"

return {
    name = "generic",
    monitor = {
        output = "",
        mode = "preferred",
        position = "auto",
        scale = 1,
    },
    workspace = {
        monitor = nil,
        first = 1,
        last = 5,
    },
    network_interface = "",
    gpu_driver = "",
    mangohud_gpu_list = "0",
    qt_scale_factor = "1",
    env = {
        XCURSOR_THEME = "Bibata-Modern-Amber",
        XCURSOR_SIZE = "24",
        XCURSOR_PATH = home .. "/.local/share/icons:/usr/share/icons:/usr/share/pixmaps",
        HYPRCURSOR_THEME = "Bibata-Modern-Amber",
        HYPRCURSOR_SIZE = "24",
        GDK_BACKEND = "wayland,x11,*",
        QT_QPA_PLATFORM = "wayland;xcb",
        CLUTTER_BACKEND = "wayland",
        XDG_CURRENT_DESKTOP = "Hyprland",
        XDG_SESSION_TYPE = "wayland",
        XDG_SESSION_DESKTOP = "Hyprland",
        QT_AUTO_SCREEN_SCALE_FACTOR = "0",
        QT_ENABLE_HIGHDPI_SCALING = "0",
        QT_QPA_PLATFORMTHEME = "qt6ct",
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1",
        QT_NO_XDG_DESKTOP_PORTAL = "1",
        GTK_THEME = "gruvbox-dark-gtk",
        GDK_SCALE = "1",
        XFT_DPI = "96",
        STEAM_FORCE_DESKTOPUI_SCALING = "1.0",
    },
    xwayland = {
        force_zero_scaling = true,
    },
    commands = {
        terminal = "kitty",
        file_manager = "thunar",
        menu = "rofi -show drun",
        browser = "brave-browser",
        hyprlock = home .. "/.config/hypr/scripts/hyprlock.sh",
        osd = home .. "/.config/hypr/scripts/osd.sh",
        waybar_launcher = home .. "/.config/waybar/launch.sh",
        waybar_top_config = home .. "/.config/waybar/config-top.jsonc",
        media_daemon = home .. "/.config/waybar/scripts/media-daemon.sh",
        pipewire_launcher = "if command -v gentoo-pipewire-launcher >/dev/null 2>&1; then gentoo-pipewire-launcher; elif command -v systemctl >/dev/null 2>&1; then systemctl --user start pipewire pipewire-pulse wireplumber; fi",
        wallpaper = home .. "/.config/hypr/scripts/wallpaper.sh",
        polkit_agent = "if command -v hyprpolkitagent >/dev/null 2>&1; then hyprpolkitagent; elif test -x /run/current-system/sw/libexec/hyprpolkitagent; then /run/current-system/sw/libexec/hyprpolkitagent; elif test -x /usr/lib/hyprpolkitagent/hyprpolkitagent; then /usr/lib/hyprpolkitagent/hyprpolkitagent; elif test -x /usr/libexec/hyprpolkitagent; then /usr/libexec/hyprpolkitagent; fi",
        polkit_probe = "command -v hyprpolkitagent || test -x /run/current-system/sw/libexec/hyprpolkitagent || test -x /usr/lib/hyprpolkitagent/hyprpolkitagent || test -x /usr/libexec/hyprpolkitagent",
    },
}
