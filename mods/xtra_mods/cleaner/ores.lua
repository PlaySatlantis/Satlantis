
if not cleaner.unsafe then return end

local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

local ores_data = aux.get_world_data().ores

for _, ore in ipairs(ores_data.remove) do
	cleaner.register_ore_removal(ore)
end

core.register_on_mods_loaded(function()
	for _, ore in ipairs(cleaner.get_remove_ores()) do
		cleaner.log("action", "unregistering ore: " .. ore)
		cleaner.remove_ore(ore)
	end
end)
