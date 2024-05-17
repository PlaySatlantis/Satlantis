local S = minetest.get_translator("arena_lib")



minetest.register_tool("arena_lib:editor_players", {

    description = S("Players"), -- or "Players and teams", changed in editor_main
    inventory_image = "arenalib_editor_players.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena = arena_lib.get_arena_by_name(mod, arena_name)
      local mod_ref = arena_lib.mods[mod]

      if arena.teams_enabled and (mod_ref.can_disable_teams or mod_ref.variable_teams_amount) then
        minetest.chat_send_player(user:get_player_name(), minetest.colorize("#ffdddd", "[arena_lib] " .. S("Values are PER TEAM! Use item #4 to change value")))
      end

      user:get_meta():set_int("arena_lib_editor.players_number", 2)
      arena_lib.give_players_tools(user:get_inventory(), mod, arena)
    end
})



minetest.register_tool("arena_lib:editor_spawners", {

    description = S("Spawners"),
    inventory_image = "arenalib_editor_spawners.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      user:get_meta():set_int("arena_lib_editor.team_ID", 1)
      arena_lib.give_spawners_tools(user)
    end
})



minetest.register_tool("arena_lib:editor_map", {
  description = S("Map"),
  inventory_image = "arenalib_editor_map.png",
  groups = {not_in_creative_inventory = 1},
  on_place = function() end,
  on_drop = function() end,

  on_use = function(itemstack, user)
    local mod = user:get_meta():get_string("arena_lib_editor.mod")

    arena_lib.give_map_tools(user:get_inventory(), mod)
  end
})



minetest.register_tool("arena_lib:editor_customise", {

    description = S("Customise"),
    inventory_image = "arenalib_editor_customise.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      arena_lib.give_customise_tools(user)
    end
})



minetest.register_tool("arena_lib:editor_settings", {

    description = S("Settings"),
    inventory_image = "arenalib_editor_settings.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      arena_lib.give_settings_tools(user)
    end
})



minetest.register_tool("arena_lib:editor_info", {

    description = S("Info"),
    inventory_image = "arenalib_editor_info.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")

      arena_lib.print_arena_info(user:get_player_name(), mod, arena_name)
    end
})



minetest.register_tool("arena_lib:editor_return", {

    description = S("Go back"),
    inventory_image = "arenalib_editor_return.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      arena_lib.show_main_editor(user)
    end
})



minetest.register_tool("arena_lib:editor_enable", {

    description = S("Enable and leave"),
    inventory_image = "arenalib_editor_enable.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")

      arena_lib.enable_arena(user:get_player_name(), mod, arena_name, true)
    end
})



minetest.register_tool("arena_lib:editor_quit", {

    description = S("Leave"),
    inventory_image = "arenalib_editor_quit.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user)
      arena_lib.quit_editor(user)
    end
})
