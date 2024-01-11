satlantis.flora = {}
satlantis.flora.MODPATH = minetest.get_modpath(minetest.get_current_modname())

-- satlantis.require("dye.lua")
-- satlantis.require("cotton.lua")

satlantis.require("trees.lua")

satlantis.crops = {}
satlantis.require("crops/api.lua")
satlantis.require("crops/melon.lua")
satlantis.require("crops/potatoes.lua")
satlantis.require("crops/pumpkin.lua")
satlantis.require("crops/wheat.lua")
