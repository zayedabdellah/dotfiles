-- Hyprland 0.56.2 does not seed a tiled pseudotile from MPV's Wayland size.
-- Supply the decoded display ratio once per video format; Dwindle then handles
-- centering and proportional shrinking. No floating or continuous resize loop.
local mp = require "mp"
if not os.getenv("HYPRLAND_INSTANCE_SIGNATURE") then return end

local pid = mp.get_property_number("pid")
local timer, dimensions, previous
local pending = false

local function apply(attempt)
    if not pending or not dimensions or mp.get_property_bool("fullscreen") then return end
    local width, height = dimensions[1], dimensions[2]
    local code = string.format([[
for _, w in ipairs(hl.get_windows({class="mpv", mapped=true, floating=false})) do
    if w.pid == %d and not w.xwayland and w.layout and w.layout.name == "dwindle" then
        if w.fullscreen ~= 0 or w.fullscreen_client ~= 0 then return "deferred" end
        -- Expose the tile bounds without moving or floating the window.
        hl.dispatch(hl.dsp.window.pseudo({action="off", window=w}))
        local tile, m = w.size, w.monitor
        local scale = math.min(tile.x/%d, tile.y/%d,
            0.6*m.width/m.scale/%d, 0.6*m.height/m.scale/%d)
        local x, y = math.floor(%d*scale+0.5), math.floor(%d*scale+0.5)
        hl.dispatch(hl.dsp.window.pseudo({action="on", window=w}))
        -- Absolute resize adds a delta to the stored (possibly larger) pseudo
        -- size in 0.56.2. Reset to its supported minimum first, then grow it.
        -- All dispatches run in one compositor callback before the next frame.
        hl.dispatch(hl.dsp.window.resize({x=-1000000, y=-1000000, relative=true, window=w}))
        hl.dispatch(hl.dsp.window.resize({x=x, y=y, window=w}))
        return "applied"
    end
end
return "unmapped"
]], pid, width, height, width, height, width, height)
    local result = mp.command_native({name="subprocess",
        args={"hyprctl", "repl", code}, capture_stdout=true, capture_stderr=true})
    local output = result.stdout or ""
    if result.status ~= 0 then
        pending = false
        mp.msg.warn("Could not initialize Hyprland pseudotile: " .. (result.stderr or output))
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
