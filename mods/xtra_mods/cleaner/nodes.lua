
local aux = dofile(cleaner.modpath .. "/misc_functions.lua")

-- populate nodes list from file in world path
local nodes_data = aux.get_world_data().nodes


-- START: backward compat

local n_path = core.get_worldpath() .. "/clean_nodes.json"
local n_file = io.open(n_path, "r")

if n_file then
	cleaner.log("action", "found deprecated clean_nodes.json, updating")

	local data_in = core.parse_json(n_file:read("*a"))
	n_file:close()
	if data_in then
		if data_in.remove then
			for _, r in ipairs(data_in.remove) do
				table.insert(nodes_data.remove, r)
			end
		end

		if data_in.replace then
			for k, v in pairs(data_in.replace) do
				if not nodes_data.replace[k] then
					nodes_data.replace[k] = v
				end
			end
		end
	end

	-- don't read deprecated file again
	os.rename(n_path, n_path .. ".old")
end

local n_path_old = core.get_worldpath() .. "/clean_nodes.txt"
n_file = io.open(n_path_old, "r")

if n_file then
	cleaner.log("action", "found deprecated clean_nodes.txt, converting to json")

	local data_in = string.split(n_file:read("*a"), "\n")
	for _, e in ipairs(data_in) do
		e = e:trim()
		if e ~= "" and e:sub(1, 1) ~= "#" then
			table.insert(nodes_data.remove, e)
		end
	end

	n_file:close()
	os.rename(n_path_old, n_path_old .. ".old") -- don't read deprecated file again
end

-- END: backward compat


nodes_data.remove = aux.clean_duplicates(nodes_data.remove)

-- update json file with any changes
aux.update_world_data("nodes", nodes_data)

core.register_lbm({
	name = "cleaner:remove_nodes",
	nodenames = {"group:to_remove"},
	run_at_every_load = true,
	action = function(pos, node)
		core.remove_node(pos)
	end,
})

core.register_lbm({
	name = "cleaner:replace_nodes",
	nodenames = {"group:to_replace"},
	run_at_every_load = true,
	action = function(pos, node)
		local new_node_name = cleaner.get_replace_nodes()[node.name]
		if core.registered_nodes[new_node_name] then
			core.swap_node(pos, {name=new_node_name})
		else
			cleaner.log("error", "cannot replace with unregistered node \"" .. tostring(new_node_name) .. "\"")
		end
	end,
})

core.register_on_mods_loaded(function()
	for _, n in ipairs(nodes_data.remove) do
		cleaner.log("action", "registering node for removal: " .. n)
		cleaner.register_node_removal(n)
	end

	for n_old, n_new in pairs(nodes_data.replace) do
		cleaner.log("action", "registering node \"" .. n_old .. "\" to be replaced with \"" .. n_new .. "\"")
		cleaner.register_node_replacement(n_old, n_new)
	end
end)
