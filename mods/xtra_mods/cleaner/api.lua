
--- Cleaner API
--
--  @topic api


local replace_items = {}
local replace_nodes = {}


--- Retrieves list of items to be replaced.
--
--  @treturn table Items to be replaced.
function cleaner.get_replace_items()
	return replace_items
end

--- Retrieves list of nodes to be replaced.
--
--  @treturn table Nodes to be replaced.
function cleaner.get_replace_nodes()
	return replace_nodes
end


--- Registers an entity to be removed.
--
--  @tparam string src Entity technical name.
function cleaner.register_entity_removal(src)
	core.register_entity(":" .. src, {
		on_activate = function(self, ...)
			self.object:remove()
		end,
	})
end

--- Registers a node to be removed.
--
--  @tparam string src Node technical name.
function cleaner.register_node_removal(src)
	core.register_node(":" .. src, {
		groups = {to_remove=1},
	})
end

local function update_list(inv, listname, src, tgt)
	if not inv then
		cleaner.log("error", "cannot update list of unknown inventory")
		return
	end

	local list = inv:get_list(listname)
	if not list then
		cleaner.log("warning", "unknown inventory list: " .. listname)
		return
	end

	for idx, stack in pairs(list) do
		if stack:get_name() == src then
			local new_stack = ItemStack(tgt)
			new_stack:set_count(stack:get_count())
			inv:set_stack(listname, idx, new_stack)
		end
	end
end

--- Replaces an item with another registered item.
--
--  @tparam string src Technical name of item to be replaced.
--  @tparam string tgt Technical name of item to be used in place.
--  @tparam[opt] bool update_players `true` updates inventory lists associated with players (default: `false`).
function cleaner.replace_item(src, tgt, update_players)
	update_players = not (update_players ~= true)

	if not core.registered_items[tgt] then
		return false, S('Cannot use unknown item "@1" as replacement.', tgt)
	end

	if not core.registered_items[src] then
		cleaner.log("info", "\"" .. src .. "\" not registered, not unregistering")
	else
		cleaner.log("warning", "overriding registered item \"" .. src .. "\"")

		core.unregister_item(src)
		if core.registered_items[src] then
			cleaner.log("error", "could not unregister \"" .. src .. "\"")
		end
	end

	core.register_alias(src, tgt)
	if core.registered_aliases[src] == tgt then
		cleaner.log("info", "registered alias \"" .. src .. "\" for \"" .. tgt .. "\"")
	else
		cleaner.log("error", "could not register alias \"" .. src .. "\" for \"" .. tgt .. "\"")
	end

	local bags = core.get_modpath("bags") ~= nil
	local armor = core.get_modpath("3d_armor") ~= nil

	-- update player inventories
	if update_players then
		for _, player in ipairs(core.get_connected_players()) do
			local pinv = player:get_inventory()
			update_list(pinv, "main", src, tgt)

			if bags then
				for i = 1, 4 do
					update_list(pinv, "bag" .. i .. "contents", src, tgt)
				end
			end

			if armor then
				local armor_inv = core.get_inventory({type="detached", name=player:get_player_name() .. "_armor"})
				update_list(armor_inv, "armor", src, tgt)
			end
		end
	end

	return true
end

--- Registeres an item to be replaced.
--
--  @tparam string src Technical name of item to be replaced.
--  @tparam string tgt Technical name of item to be used in place.
function cleaner.register_item_replacement(src, tgt)
	replace_items[src] = tgt
end

--- Registers a node to be replaced.
--
--  @tparam string src Technical name of node to be replaced.
--  @tparam string tgt Technical name of node to be used in place.
function cleaner.register_node_replacement(src, tgt)
	core.register_node(":" .. src, {
		groups = {to_replace=1},
	})

	replace_nodes[src] = tgt
	cleaner.register_item_replacement(src, tgt)
end


--- Unsafe Methods.
--
--  Enabled with [cleaner.unsafe](settings.html#cleaner.unsafe) setting.
--
--  @section unsafe


if cleaner.unsafe then
	local remove_ores = {}

	--- Retrieves list of ores to be removed.
	--
	--  @treturn table Ores to be removed.
	function cleaner.get_remove_ores()
		return remove_ores
	end

	--- Registers an ore to be removed after server startup.
	--
	--  @tparam string src Ore technical name.
	function cleaner.register_ore_removal(src)
		table.insert(remove_ores, src)
	end

	--- Removes an ore definition.
	--
	--  @tparam string src Ore technical name.
	function cleaner.remove_ore(src)
		local remove_ids = {}
		local total_removed = 0
		local registered = false

		for id, def in pairs(core.registered_ores) do
			if def.ore == src then
				table.insert(remove_ids, id)
				registered = true
			end
		end

		for _, id in ipairs(remove_ids) do
			core.registered_ores[id] = nil
			if core.registered_ores[id] then
				cleaner.log("error", "unable to unregister ore " .. id)
			else
				total_removed = total_removed + 1
			end
		end

		return registered, total_removed
	end
end
