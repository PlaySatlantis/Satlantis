local S = minetest.get_translator("arena_lib")

local function change_amount() end
local function to_pmax_limitless() end
local function to_pmax_limit() end

local players_tools = {
  "",                                 -- arena_lib:players_min
  "",                                 -- arena_lib:players_max or players_max_inf
  "",                                 -- arena_lib:teams_amount
  "",                                 -- arena_lib:players_change
  "",
  "",                                 -- arena_lib:players_teams_on/off/---
  "",
  "",
  "arena_lib:editor_return",
  "arena_lib:editor_quit",
}



minetest.register_node("arena_lib:players_min", {

    description = S("Players required"),
    inventory_image = "arenalib_tool_players_min.png",
    wield_image = "arenalib_tool_players_min.png",
    node_placement_prediction = "",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
      local players_amount = user:get_meta():get_int("arena_lib_editor.players_number")

      if not arena_lib.change_players_amount(user:get_player_name(), mod, arena_name, players_amount, nil, true) then return end

      -- aggiorno la quantità se il cambio è andato a buon fine
      itemstack:get_meta():set_string("count_meta", players_amount)
      return itemstack
    end
})



minetest.register_node("arena_lib:players_max", {

    description = S("Players supported (right click to remove the limit)"),
    inventory_image = "arenalib_tool_players_max.png",
    wield_image = "arenalib_tool_players_max.png",
    node_placement_prediction = "",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
      local players_amount = user:get_meta():get_int("arena_lib_editor.players_number")

      if not arena_lib.change_players_amount(user:get_player_name(), mod, arena_name, nil, players_amount, true) then return end

      -- aggiorno la quantità se il cambio è andato a buon fine
      itemstack:get_meta():set_string("count_meta", players_amount)
      return itemstack
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
      to_pmax_limitless(user)
    end,

    on_place = function(itemstack, user, pointed_thing)
      to_pmax_limitless(user)
    end
})



minetest.register_node("arena_lib:players_max_inf", {

    description = S("Players supported (click to set a limit)"),
    inventory_image = "arenalib_tool_players_max_inf.png",
    wield_image = "arenalib_tool_players_max_inf.png",
    node_placement_prediction = "",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      to_pmax_limit(user)
    end,

    on_secondary_use = function(itemstack, user, pointed_thing)
      to_pmax_limit(user)
    end,

    on_place = function(itemstack, user, pointed_thing)
      to_pmax_limit(user)
    end
})



minetest.register_node("arena_lib:players_teams_amount", {

    description = S("Teams amount"),
    inventory_image = "arenalib_tool_players_teams_amount.png",
    wield_image = "arenalib_tool_players_teams_amount.png",
    node_placement_prediction = "",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
      local teams_amount = user:get_meta():get_int("arena_lib_editor.players_number")

      if not arena_lib.change_teams_amount(user:get_player_name(), mod, arena_name, teams_amount, true) then return end

      -- aggiorno la quantità se il cambio è andato a buon fine
      user:set_wielded_item("arena_lib:players_teams_amount " .. teams_amount)
    end
})



minetest.register_node("arena_lib:players_change", {

    description = S("Change value (LMB decreases, RMB increases)"),
    inventory_image = "arenalib_tool_players_change.png",
    wield_image = "arenalib_tool_players_change.png",
    node_placement_prediction = "",
    groups = {not_in_creative_inventory = 1},
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      change_amount(user, true)
    end,

    on_secondary_use = function(itemstack, placer, pointed_thing)
      change_amount(placer, false)
    end,

    on_place = function(itemstack, user, pointed_thing)
      change_amount(user, false)
    end
})



minetest.register_tool("arena_lib:players_teams_on", {

    description = S("Teams: on (click to toggle off)"),
    inventory_image = "arenalib_tool_players_teams_on.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)

      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")

      arena_lib.toggle_teams_per_arena(user:get_player_name(), mod, arena_name, false, true)

      user:get_inventory():set_stack("main", 3, "")
      user:get_inventory():set_stack("main", 6, "arena_lib:players_teams_off")
    end
})



minetest.register_tool("arena_lib:players_teams_off", {

    description = S("Teams: off (click to toggle on)"),
    inventory_image = "arenalib_tool_players_teams_off.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name = user:get_meta():get_string("arena_lib_editor.arena")

      arena_lib.toggle_teams_per_arena(user:get_player_name(), mod, arena_name, true, true)

      if arena_lib.mods[mod].variable_teams_amount then
        local _, arena = arena_lib.get_arena_by_name(mod, arena_name)
        user:get_inventory():set_stack("main", 3, "arena_lib:players_teams_amount " .. #arena.teams)
      end
      user:get_inventory():set_stack("main", 6, "arena_lib:players_teams_on")
    end
})



function arena_lib.give_players_tools(inv, mod, arena)
  inv:set_list("main", players_tools)

  local min_item = ItemStack("arena_lib:players_min")
  local max_item = ItemStack("arena_lib:players_max")
  local chg_item = ItemStack("arena_lib:players_change")

  min_item:get_meta():set_string("count_meta", arena.min_players)
  chg_item:get_meta():set_string("count_meta", 2)
  inv:set_stack("main", 1, min_item)
  inv:set_stack("main", 4, chg_item)

  if arena.max_players == -1 then
    inv:set_stack("main", 2, "arena_lib:players_max_inf")
  else
    max_item:get_meta():set_string("count_meta", arena.max_players)
    inv:set_stack("main", 2, max_item)
  end

  local mod_ref = arena_lib.mods[mod]

  -- se non ha le squadre, non do l'oggetto per attivarle/disattivarle
  if #mod_ref.teams == 1 then return end

  if arena.teams_enabled and mod_ref.variable_teams_amount then
    inv:set_stack("main", 3, "arena_lib:players_teams_amount " .. #arena.teams)
  end

  local team_toggle_item = ""

  if mod_ref.can_disable_teams then
    team_toggle_item = arena.teams_enabled and "arena_lib:players_teams_on" or "arena_lib:players_teams_off"
  end

  inv:set_stack("main", 6, team_toggle_item)
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function change_amount(player, decrease)
  local amount = player:get_meta():get_int("arena_lib_editor.players_number")

  if not decrease then
    amount = amount +1
  else
    if amount > 1 then
      amount = amount -1
    else return end
  end

  local item = player:get_wielded_item()

  item:get_meta():set_string("count_meta", amount)
  player:set_wielded_item(item)
  player:get_meta():set_int("arena_lib_editor.players_number", amount)
end



function to_pmax_limitless(user)
  local mod = user:get_meta():get_string("arena_lib_editor.mod")
  local arena_name = user:get_meta():get_string("arena_lib_editor.arena")

  arena_lib.change_players_amount(user:get_player_name(), mod, arena_name, nil, -1, true)
  user:set_wielded_item("arena_lib:players_max_inf")
end



function to_pmax_limit(user)
  local mod = user:get_meta():get_string("arena_lib_editor.mod")
  local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
  local _, arena = arena_lib.get_arena_by_name(mod, arena_name)
  local min_players = arena.min_players +1

  if not arena_lib.change_players_amount(user:get_player_name(), mod, arena_name, nil, min_players, true) then return end

  -- aggiorno la quantità se il cambio è andato a buon fine
  local item = ItemStack("arena_lib:players_max")

  item:get_meta():set_string("count_meta", min_players)
  user:set_wielded_item(item)
end
