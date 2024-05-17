
local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate items list from file in world path
local items_data = aux.get_world_data().items


-- START: backward compat

local i_path = core.get_worldpath() .. "/clean_items.json"
local i_file = io.open(i_path, "r")

if i_file then
	cleaner.log("action", "found deprecated clean_items.json, updating")

	local data_in = core.parse_json(i_file:read("*a"))
	i_file:close()
	if data_in and data_in.replace then
		for k, v in pairs(data_in.replace) do
			if not items_data.replace[k] then
				items_data.replace[k] = v
			end
		end
	end

	-- don't read deprecated file again
	os.rename(i_path, i_path .. ".old")
end

-- END: backward compat


aux.update_world_data("items", items_data)

for i_old, i_new in pairs(items_data.replace) do
	cleaner.register_item_replacement(i_old, i_new)
end

-- register actions for after server startup
core.register_on_mods_loaded(function()
	for i_old, i_new in pairs(cleaner.get_replace_items()) do
		cleaner.log("action", "registering item \"" .. i_old .. "\" to be replaced with \"" .. i_new .. "\"")

		local retval, msg = cleaner.replace_item(i_old, i_new)
		if not retval then
			cleaner.log("warning", msg)
		end
	end
end)
