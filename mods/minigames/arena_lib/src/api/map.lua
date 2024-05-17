local S = minetest.get_translator("arena_lib")

----------------------------------------------
-----------------OVERRIDES--------------------
----------------------------------------------

-- stop people from editing the map if can_build is false
local old_is_protected = minetest.is_protected

function minetest.is_protected(pos, name)
  -- se lə giocatorə è in arena e il minigioco non permette di costruire, annulla
  if arena_lib.is_player_in_arena(name) then
    local arena = arena_lib.get_arena_by_player(name)

    if arena.in_game then
      local mod_ref = arena_lib.mods[arena_lib.get_mod_by_player(name)]
      if not mod_ref.can_build then
        return true
      end
    end
  end

  local arena = arena_lib.get_arena_by_pos(pos)

  -- evita che l'arena venga modificata fuori dall'editor se si rigenera
  if arena and arena.is_resetting ~= nil and arena.enabled and not arena.matchID then
    arena_lib.print_error(name, S("You can't modify the map whilst enabled!"))
    return true
  end

  return old_is_protected(pos, name)
end



-- stop people from dropping items if can_drop is false
local old_item_drop = minetest.item_drop

minetest.item_drop = function(itemstack, player, pos)
  if player then
    local p_name = player:get_player_name()
    if arena_lib.is_player_in_arena(p_name) then
      local mod = arena_lib.get_mod_by_player(p_name)
      if not arena_lib.mods[mod].can_drop then
        return itemstack
      end
    end
  end

  return old_item_drop(itemstack, player, pos)
end



-- stop people from editing their inventories in case disable_inventory is true and
-- they've opened some inventory through a node (e.g. chests)
minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
  local p_name = player:get_player_name()
  if not arena_lib.is_player_in_arena(p_name) then return end

  local mod = arena_lib.get_mod_by_player(p_name)

  if arena_lib.mods[mod].disable_inventory then return 0 end
end)





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function arena_lib.get_mod_by_pos(pos)
  for mod, mg_data in pairs(arena_lib.mods) do
    for _, arena in pairs(mg_data.arenas) do
      if arena.pos1 then
        local p1, p2 = vector.sort(arena.pos1, arena.pos2)

        if vector.in_area(pos, p1, p2) then
          return mod
        end
      end
    end
  end
end



function arena_lib.get_arena_by_pos(pos, minigame)
  if minigame then
    for _, arena in pairs(arena_lib.mods[minigame].arenas) do
      if arena.pos1 then
        local v1, v2 = vector.sort(arena.pos1, arena.pos2)

        if vector.in_area(pos, v1, v2) then
          return arena
        end
      end
    end

  else
    for _, mg_data in pairs(arena_lib.mods) do
      for _, arena in pairs(mg_data.arenas) do
        if arena.pos1 then
          local v1, v2 = vector.sort(arena.pos1, arena.pos2)

          if vector.in_area(pos, v1, v2) then
            return arena
          end
        end
      end
    end
  end
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function arena_lib.is_player_in_region(arena, p_name)
    if not arena then return end

    if not arena.pos1 then
      minetest.log("[ARENA_LIB] Attempt to check whether a player is inside an arena region (" .. arena.name .. "), when the arena has got no region declared")
      return end

    local v1, v2  = vector.sort(arena.pos1, arena.pos2)
    local p_pos   = minetest.get_player_by_name(p_name):get_pos()

    return vector.in_area(p_pos, v1, v2)
  end
