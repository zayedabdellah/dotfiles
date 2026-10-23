-- Select a portable machine profile without changing the rice's behavior.
-- Generic is deliberately safe. The laptop profile must be selected explicitly
-- with DOTFILES_MACHINE_PROFILE or machine.local.lua.

local function merge(destination, overrides)
    for key, value in pairs(overrides or {}) do
        if type(value) == "table" and type(destination[key]) == "table" then
            merge(destination[key], value)
        else
            destination[key] = value
        end
    end
    return destination
end

local selected = os.getenv("DOTFILES_MACHINE_PROFILE")
if selected == nil or selected == "" then
    selected = "generic"
end

-- `require("machine.local")` maps the dot to a directory separator and looks
-- for machine/local.lua. The installer writes the literal filename
-- machine.local.lua, so resolve it next to this module and load that path.
local machine_path = package.searchpath("machine", package.path)
local local_path = machine_path and machine_path:gsub("machine%.lua$", "machine.local.lua")
local local_file = local_path and io.open(local_path, "r")
local local_ok, local_config = false, nil
if local_file then
    local_file:close()
    local_ok, local_config = pcall(dofile, local_path)
    if not local_ok then
        error("Failed to load " .. local_path .. ": " .. tostring(local_config))
    end
end

if local_ok then
    if type(local_config) ~= "table" then
        error("config/hypr/machine.local.lua must return a table")
    end
    if local_config.profile ~= nil then
        selected = local_config.profile
    end
end

local profile_ok, profile = pcall(require, "profiles." .. selected)
if not profile_ok then
    error("Invalid machine profile '" .. tostring(selected) .. "'. " .. tostring(profile))
end

if local_ok and local_config.overrides ~= nil then
    profile = merge(profile, local_config.overrides)
end

return profile
