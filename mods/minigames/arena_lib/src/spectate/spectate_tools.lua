local S = minetest.get_translator("arena_lib")



minetest.register_tool("arena_lib:spectate_changeplayer", {

    description = S("Change player"),
    inventory_image = "arenalib_spectate_changeplayer.png",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user)
      arena_lib.find_and_spectate_player(user:get_player_name())
    end,

    on_secondary_use = function(itemstack, user)
      arena_lib.find_and_spectate_player(user:get_player_name(), false, true)
    end,

    on_place = function(itemstack, user)
      arena_lib.find_and_spectate_player(user:get_player_name(), false, true)
    end
})



minetest.register_tool("arena_lib:spectate_changeteam", {

    description = S("Change team"),
    inventory_image = "arenalib_spectate_changeteam.png",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local arena = arena_lib.get_arena_by_player(p_name)

      -- non far cambiare se c'è rimasto solo una squadra da seguire
      if arena_lib.get_active_teams(arena) == 1 then return end

      arena_lib.find_and_spectate_player(p_name, true)
    end,

    on_secondary_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local arena = arena_lib.get_arena_by_player(p_name)

      -- non far cambiare se c'è rimasto solo una squadra da seguire
      if arena_lib.get_active_teams(arena) == 1 then return end

      arena_lib.find_and_spectate_player(p_name, true, true)
    end,

    on_place = function(itemstack, user)
      local p_name = user:get_player_name()
      local arena = arena_lib.get_arena_by_player(p_name)

      -- non far cambiare se c'è rimasto solo una squadra da seguire
      if arena_lib.get_active_teams(arena) == 1 then return end

      arena_lib.find_and_spectate_player(p_name, true, true)
    end
})



minetest.register_tool("arena_lib:spectate_changeentity", {

    description = S("Change entity"),
    inventory_image = "arenalib_spectate_changeentity.png",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena = arena_lib.get_arena_by_player(p_name)

      arena_lib.find_and_spectate_entity(mod, arena, p_name)
    end,

    on_secondary_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena = arena_lib.get_arena_by_player(p_name)

      arena_lib.find_and_spectate_entity(mod, arena, p_name, true)
    end,

    on_place = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena = arena_lib.get_arena_by_player(p_name)

      arena_lib.find_and_spectate_entity(mod, arena, p_name, true)
    end
})



minetest.register_tool("arena_lib:spectate_changearea", {

    description = S("Change area"),
    inventory_image = "arenalib_spectate_changearea.png",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena = arena_lib.get_arena_by_player(p_name)

      arena_lib.find_and_spectate_area(mod, arena, p_name)
    end,

    on_secondary_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena = arena_lib.get_arena_by_player(p_name)

      arena_lib.find_and_spectate_area(mod, arena, p_name, true)
    end,

    on_place = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena = arena_lib.get_arena_by_player(p_name)

      arena_lib.find_and_spectate_area(mod, arena, p_name, true)
    end
})



minetest.register_tool("arena_lib:spectate_join", {

    description = S("Enter the match"),
    inventory_image = "arenalib_spectate_join.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      local p_name = user:get_player_name()
      local mod = arena_lib.get_mod_by_player(p_name)
      local arena_id = arena_lib.get_arenaID_by_player(p_name)

      arena_lib.join_arena(mod, p_name, arena_id)
    end
})



minetest.register_tool("arena_lib:spectate_quit", {

    description = S("Leave"),
    inventory_image = "arenalib_editor_quit.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      arena_lib.remove_player_from_arena(user:get_player_name(), 3)
    end
})
