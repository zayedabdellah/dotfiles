-- Hyprland 0.56.2 does not seed a tiled pseudotile from MPV's Wayland size.
-- Supply natural display pixels once per video format; Dwindle handles shrinking.
-- Restore the preferred size on shared-to-solo transitions, without floating.
-- Manual sizes persist until that transition, a video-format change, or a
-- monitor/workspace environment change. No resize commands run while sharing
-- unless the video format or monitor/workspace environment changes.
local mp = require "mp"
if not os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then return end

local pid = mp.get_property_number("pid")
local timer, dimensions, previous
local pending = false

local function apply(attempt)
    if not pending or not dimensions or mp.get_property_bool("fullscreen") then return end
    local width, height = dimensions[1], dimensions[2]
    local code = string.format([[do
-- Keep one compositor timer for all MPV instances. Lua 0.56.2 does not expose
-- window.floating or a geometry event, so use an inexpensive in-process check
-- as a fallback, with an 80ms debounce for the events it does expose.
_mpv_pseudotiles = _mpv_pseudotiles or {windows={}}
local registry = _mpv_pseudotiles
if not registry.timer then
    local function update()
        local windows = hl.get_windows({mapped=true})
        for pid, state in pairs(registry.windows) do
            local w
            for _, candidate in ipairs(windows) do
                if candidate.pid == pid and candidate.class == "mpv" and not candidate.xwayland
                    and (not state.id or candidate.stable_id == state.id) then
                    w = candidate
                    break
                end
            end
            if not w then
                state.attempts = (state.attempts or 0) + 1
                if state.id or state.attempts >= 10 then registry.windows[pid] = nil end
            else
                state.id = w.stable_id
                local ws, m = w.workspace, w.monitor
                if w.floating or w.hidden or not w.visible or not ws or ws.special
                    or not ws.visible or not m or m.active_special_workspace
                    or w.fullscreen ~= 0 or w.fullscreen_client ~= 0 or ws.has_fullscreen
                    or not w.layout or w.layout.name ~= "dwindle" then
                    -- Never resize invisible, floating, fullscreen or special windows.
                    -- Keep occupancy history so returning to a shared workspace
                    -- does not overwrite a manual size. Pending video changes wait.
                else
                    local count = 0
                    for _, other in ipairs(windows) do
                        if other.workspace == ws and not other.floating and not other.hidden
                            and other.visible then count = count + 1 end
                    end
                    local solo = count == 1
                    local r = m.reserved
                    local environment = table.concat({ws.id, m.id, m.scale, m.width, m.height,
                        r.top, r.right, r.bottom, r.left}, ":")
                    local restore = state.dirty or environment ~= state.environment
                        or (solo and not state.solo)
                    -- Record state before dispatching: property events cannot cause
                    -- a resize feedback loop. Ordinary tile changes stay with Dwindle.
                    state.environment, state.solo, state.dirty = environment, solo, false
                    if restore then
                        hl.dispatch(hl.dsp.window.pseudo({action="off", window=w}))
                        local tile = w.size -- actual client bounds after gaps/decorations
                        local width, height = state.width / m.scale, state.height / m.scale
                        local scale = math.min(1, tile.x / width, tile.y / height)
                        local x, y = math.floor(width*scale+0.5), math.floor(height*scale+0.5)
                        hl.dispatch(hl.dsp.window.pseudo({action="on", window=w}))
                        -- Absolute resize adds to the stored pseudo size in 0.56.2.
                        -- Reset to its clamped minimum, then grow; one callback/frame.
                        hl.dispatch(hl.dsp.window.resize({x=-1000000, y=-1000000, relative=true, window=w}))
                        hl.dispatch(hl.dsp.window.resize({x=x, y=y, window=w}))
                    end
                end
            end
        end
        if not next(registry.windows) then registry.timer:set_enabled(false) end
    end
    registry.timer = hl.timer(update, {timeout=500, type="repeat"})
    registry.events = {}
    for _, event in ipairs({"window.open", "window.close", "window.move_to_workspace",
        "window.fullscreen", "workspace.active", "workspace.special_active",
        "workspace.move_to_monitor", "monitor.layout_changed", "config.props_refreshed"}) do
        registry.events[#registry.events+1] = hl.on(event, function()
            if next(registry.windows) then registry.timer:set_timeout(80) end
        end)
    end
end
local pid, width, height = %d, %d, %d
local state = registry.windows[pid] or {}
state.width, state.height, state.dirty = width, height, true
registry.windows[pid] = state
registry.timer:set_timeout(80)
return "applied"
end
]], pid, width, height)
    local result = mp.command_native({name="subprocess",
        args={"hyprctl", "repl", code}, capture_stdout=true, capture_stderr=true})
    local output = result.stdout or ""
    if result.status ~= 0 then
        pending = false
        mp.msg.warn("Could not initialize Hyprland pseudotile: " .. output .. (result.stderr or ""))
    elseif output:find("applied", 1, true) then
        pending = false
    elseif attempt < 10 then
        timer = mp.add_timeout(0.1, function() apply(attempt + 1) end)
    end
end

local function schedule()
    if timer then timer:kill() end
    timer = mp.add_timeout(0.1, function() apply(1) end)
end

mp.observe_property("video-out-params", "native", function(_, params)
    if not params or not params.dw or not params.dh then
        previous, dimensions, pending = nil, nil, false
        return
    end
    local width, height = params.dw, params.dh
    if (params.rotate or 0) % 180 == 90 then width, height = height, width end
    if width <= 0 or height <= 0 then return end
    local key = width .. "x" .. height
    if key == previous then return end
    previous, dimensions, pending = key, {width, height}, true
    schedule()
end)

-- Defer format changes during fullscreen; otherwise leave manual sizes alone.
mp.observe_property("fullscreen", "bool", function(_, fullscreen)
    if not fullscreen and pending then schedule() end
end)
