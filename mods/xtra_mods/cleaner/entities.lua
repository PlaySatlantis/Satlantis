
local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate entities list from file in world path
local entities_data = aux.get_world_data().entities


-- START: backward compat

local e_path = core.get_worldpath() .. "/clean_entities.json"
local e_file = io.open(e_path, "r")

if e_file then
	cleaner.log("action", "found deprecated clean_entities.json, updating")

	local data_in = core.parse_json(e_file:read("*a"))
	e_file:close()
	if data_in and data_in.remove then
		for _, r in ipairs(data_in.remove) do
			table.insert(entities_data.remove, r)
		end
	end

	-- don't read deprecated file again
	os.rename(e_path, e_path .. ".old")
end

local e_path_old = core.get_worldpath() .. "/clean_entities.txt"
e_file = io.open(e_path_old, "r")

if e_file then
	cleaner.log("action", "found deprecated clean_entities.txt, converting to json")

	local data_in = string.split(e_file:read("*a"), "\n")
	for _, e in ipairs(data_in) do
		e = e:trim()
		if e ~= "" and e:sub(1, 1) ~= "#" then
			table.insert(entities_data.remove, e)
		end
	end

	e_file:close()
	os.rename(e_path_old, e_path_old .. ".bak") -- don't read deprecated file again
end

-- END: backward compat


entities_data.remove = aux.clean_duplicates(entities_data.remove)

-- update json file with any changes
aux.update_world_data("entities", entities_data)

core.register_on_mods_loaded(function()
	for _, e in ipairs(entities_data.remove) do
		cleaner.log("action", "registering entity for removal: " .. e)
		cleaner.register_entity_removal(e)
	end
end)
