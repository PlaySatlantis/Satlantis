local S = minetest.get_translator("arena_lib")

local function async_reset_map() end
local function reset_node_inventory() end

local on_step = minetest.registered_entities["__builtin:item"].on_step
local get_position_from_hash =  minetest.get_position_from_hash
local add_node = minetest.add_node
local get_inventory = minetest.get_inventory

-- to associate each dropped item with the match it was dropped in
minetest.registered_entities["__builtin:item"]._matchID = -1
-- last checked age, in order to perform the check for the drop to be removed; once per sec
minetest.registered_entities["__builtin:item"]._last_age = 0



minetest.register_on_mods_loaded(function()
	-- resets all maps in case the server crashed during the last match
  minetest.after(0, function ()
    for mod, mod_data in pairs(arena_lib.mods) do
      if mod_data.regenerate_map then
        for _, arena in pairs(mod_data.arenas) do
          arena.is_resetting = false
          arena_lib.reset_map(mod, arena)
        end
      end
    end
  end)
end)



function arena_lib.reset_map(mod, arena)
  if not arena.pos1 or arena.is_resetting then return end

  if not arena_lib.mods[mod].regenerate_map or not arena.enabled then return end
  async_reset_map(mod, arena)
end



function arena_lib.hard_reset_map(sender, mod, arena_name)
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  -- se l'arena non esiste
  if not arena then
    arena_lib.print_error(sender, S("This arena doesn't exist!"))
    return end

  local schem_path = minetest.get_worldpath() .. ("/arena_lib/Schematics/%s_%d.mts"):format(mod, id)
  local schem = io.open(schem_path, "r")

  -- se la schematica non esiste
  if not schem then
    arena_lib.print_error(sender, S("There is no schematic to paste!"))
    return end

  schem:close()

  -- se l'area non esiste
  if not arena.pos1 then
    arena_lib.print_error(sender, S("Region not declared!"))
    return end

  arena.pos1, arena.pos2 = vector.sort(arena.pos1, arena.pos2)

  minetest.place_schematic(
    arena.pos1,
    ("%s/arena_lib/Schematics/%s_%d.mts"):format(minetest.get_worldpath(), mod, id),
    "0",
    nil,
    true
  )

  arena_lib.print_info(sender, arena_lib.mods[mod].prefix .. S("Schematic of arena @1 successfully pasted", arena_name))
end



-- removing drops based on the match_id
minetest.registered_entities["__builtin:item"].on_step = function(self, dtime, moveresult)
	-- returning if it passed less than 1s from the last check
	if self.age - self._last_age < 1 then
		on_step(self, dtime, moveresult)
		return
	end

	local pos = self.object:get_pos()
	local arena = arena_lib.get_arena_by_pos(pos)
	local mod = arena_lib.get_mod_by_pos(pos)
	self._last_age = self.age

	if arena and arena_lib.mods[mod].regenerate_map and arena.matchID then
		-- if the drop has not been initializated yet
		if self._matchID == -1 then
			self._matchID = arena.matchID
		elseif self._matchID ~= arena.matchID then
			self.object:remove()
			return
		end
	elseif arena then
		self.object:remove()
		return
	end

	on_step(self, dtime, moveresult)
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function async_reset_map(mod, arena, recursive_data)
	recursive_data = recursive_data or {}

	-- when the function gets called again it uses the same maps table
	local maps = recursive_data.maps or arena_lib.load_maps_from_db()
  local id = arena_lib.get_arena_by_name(mod, arena.name)
  local idx = mod .. "_" .. id

	-- the indexes are useful to count the reset nodes across func calls
	local current_index = 1
	local last_index = recursive_data.last_index or 0
	local nodes_to_reset = maps[idx].changed_nodes
	local nodes_per_tick = recursive_data.nodes_per_tick or arena_lib.RESET_NODES_PER_TICK

	-- resets a node if it hasn't been reset yet and, if it resets more than "nodes_per_tick"
	-- nodes, invokes this function again after one step
	arena.is_resetting = true

	for hash_pos, node in pairs(nodes_to_reset) do
		if current_index > last_index then
			local pos = get_position_from_hash(hash_pos)

			add_node(pos, node)
			reset_node_inventory(pos)
		end

		-- if more than nodes_per_tick nodes have been reset this cycle
		if current_index - last_index >= nodes_per_tick then
			minetest.after(0, function()
				async_reset_map(mod, arena, {
					last_index = current_index,
					nodes_per_tick = nodes_per_tick,
					original_maps = maps,
				})
			end)
			return
		end

		current_index = current_index + 1
	end

	arena.is_resetting = false

	maps = arena_lib.load_maps_from_db()
	maps[idx].changed_nodes = {}
	arena_lib.save_maps_onto_db(maps)
end



function reset_node_inventory(pos)
	local location = {type="node", pos = pos}
	local inv = get_inventory(location)

	if not inv then return end

	for _, list in ipairs(inv:get_lists()) do
		inv:set_list(list, {})
	end
end
