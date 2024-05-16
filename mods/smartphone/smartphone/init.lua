smartphone = {}
local mod_path = minetest.get_modpath("smartphone")

dofile(mod_path.."/src/stack.lua")
dofile(mod_path.."/src/utils.lua")
dofile(mod_path.."/src/security.lua")
dofile(mod_path.."/src/apps_navigation.lua")
dofile(mod_path.."/src/api.lua")
dofile(mod_path.."/src/smartphone_formspec.lua")
dofile(mod_path.."/src/cmds.lua")

local function test_include()
	dofile(mod_path.."/src/test/test_apps.lua")
end

--test_include()