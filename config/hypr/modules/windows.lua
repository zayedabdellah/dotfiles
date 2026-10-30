--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.layer_rule({
    name  = "waybar-click-passthrough",
    match = { namespace = "^waybar$" },

    no_anim = true,
})
hl.window_rule({
    name  = "fix-pseudo-fullscreen",
    match = { fullscreen = true },

    pseudo = false,
})

-- MPV's scripts/hyprland-pseudotile.lua supplies the video's display ratio.
-- Hyprland 0.56 initializes tiled pseudo sizes from layout geometry, not autofit.
-- After the fullscreen rule: pseudo geometry is bypassed while fullscreen.
hl.window_rule({
    name  = "mpv-pseudotile",
    match = { class = "^mpv$", float = false },

    pseudo = true,
})

-- Thunar File Chooser & Dialog Rules
hl.window_rule({
    name  = "thunar-file-dialogs",
    match = {
        class = "thunar",
        title = "Open File|Save File|Open Folder|Save As|Select a File|File Operation Progress|Confirm to replace files"
    },

    -- Window management states
    float  = true,
    center = true,
    size   = "1280 800",
})
