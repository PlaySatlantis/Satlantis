phone_rewards = {}
local mod_path = minetest.get_modpath("phone_rewards")

dofile(mod_path.."/src/files_loader.lua")
dofile(mod_path.."/src/api.lua")
dofile(mod_path.."/src/quest_points_awarding.lua")
dofile(mod_path.."/src/app.lua")
dofile(mod_path.."/src/cmds.lua")

minetest.register_privilege(phone_rewards.premium_priv, {
	description = "For premium users",
	give_to_singleplayer = false,
})