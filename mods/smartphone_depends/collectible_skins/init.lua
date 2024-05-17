collectible_skins = {}
collectible_skins.SETTINGS = {}

local version = "0.1-dev"
local modpath = minetest.get_modpath("collectible_skins")
local srcpath = modpath .. "/src"

dofile(modpath .. "/libs/chatcmdbuilder.lua")

dofile(srcpath .. "/_load.lua")
dofile(srcpath .. "/api.lua")
dofile(srcpath .. "/callbacks.lua")
dofile(srcpath .. "/commands.lua")
dofile(srcpath .. "/items.lua")
dofile(srcpath .. "/player_manager.lua")
dofile(srcpath .. "/privs.lua")
dofile(srcpath .. "/GUI/gui_collection.lua")

minetest.log("action", "[COLLECTIBLE SKINS] Mod initialised, running version " .. version)
