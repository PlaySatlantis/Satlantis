assert(not minetest.is_singleplayer(), "\n____________________\n\nMULTIPLAYER ONLY\n____________________\n")

satlantis = {}

satlantis._requires = {}
satlantis.require = function(name)
    local path = minetest.get_modpath(minetest.get_current_modname()) .. "/" .. name
    return satlantis._requires[path] or dofile(path)
end

satlantis._PATH = minetest.get_worldpath() .. "/satlantis" -- Satlantis data directory
minetest.mkdir(satlantis._PATH)

satlantis.require("config.lua")
satlantis.require("items.lua")
satlantis.require("entity.lua")

minetest.get_server_status = function() end
