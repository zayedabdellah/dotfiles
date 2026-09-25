-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

local machine = require("machine")

local function set_env(name)
    if machine.env[name] ~= nil then
        hl.env(name, machine.env[name])
    end
end

-- Waybar consumes this selected-profile value. Generic leaves it unset so the
-- launcher can use the system's active route/interface.
if machine.network_interface ~= nil and machine.network_interface ~= "" then
    hl.env("DOTFILES_NETWORK_INTERFACE", machine.network_interface)
end
hl.env("DOTFILES_MACHINE_PROFILE", machine.name)

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
set_env("XCURSOR_THEME")
set_env("XCURSOR_SIZE")
set_env("XCURSOR_PATH")
set_env("HYPRCURSOR_THEME")
set_env("HYPRCURSOR_SIZE")

-- Toolkit Backend --
set_env("GDK_BACKEND")
set_env("QT_QPA_PLATFORM")
-- hl.env("SDL_VIDEODRIVER", "wayland")
set_env("CLUTTER_BACKEND")

-- XDG Specifications --
set_env("XDG_CURRENT_DESKTOP")
set_env("XDG_SESSION_TYPE")
set_env("XDG_SESSION_DESKTOP")

-- QT Specific Tuning (Keeps Native Qt Apps Unscaled) --
set_env("QT_AUTO_SCREEN_SCALE_FACTOR")
set_env("QT_ENABLE_HIGHDPI_SCALING")
hl.env("QT_QPA_PLATFORMTHEME", os.getenv("DOTFILES_QT_PLATFORMTHEME") or machine.env.QT_QPA_PLATFORMTHEME)
local qtStyleOverride = os.getenv("DOTFILES_QT_STYLE_OVERRIDE")
if qtStyleOverride ~= nil and qtStyleOverride ~= "" then
    hl.env("QT_STYLE_OVERRIDE", qtStyleOverride)
end
-- hl.env("QT_STYLE_OVERRIDE", "kvantum")
set_env("QT_WAYLAND_DISABLE_WINDOWDECORATION")
set_env("QT_NO_XDG_DESKTOP_PORTAL")

-- GTK Specific Tuning --
set_env("GTK_THEME")
set_env("GDK_SCALE")

-- GLOBAL XWAYLAND SCALING FIX --
set_env("XFT_DPI")

-- NVIDIA Support Variables --
set_env("LIBVA_DRIVER_NAME")
set_env("GBM_BACKEND")
set_env("__GLX_VENDOR_LIBRARY_NAME")
set_env("NVD_BACKEND")
set_env("WLR_DRM_NO_ATOMIC")

-- Steam Fixes --
set_env("STEAM_FORCE_DESKTOPUI_SCALING")

---------------------------------
---- XWAYLAND SCALING FIX -------
---------------------------------

-- This stops Hyprland from blurrily auto-stretching non-Wayland applications
hl.config({
    xwayland = {
        force_zero_scaling = machine.xwayland.force_zero_scaling
    }
})
