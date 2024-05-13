local S = minetest.get_translator("arena_lib")

local function get_edit_warning_formspec() end
local function get_deletion_warning_formspec() end

local map_tools = {
  "arena_lib:map_region",
  "",
  "arena_lib:map_save",
  "arena_lib:map_hard_reset",
  "",
  "",
  "",
  "",
  "arena_lib:editor_return",
  "arena_lib:editor_quit",
}



minetest.register_tool("arena_lib:map_region", {

  description = S("Arena region (LMB pos1, RMB pos2, Q removes)"),
  inventory_image = "arenalib_tool_map_region.png",
  groups = {not_in_creative_inventory = 1},

  on_drop = function(itemstack, dropper, pos)
    minetest.show_formspec(dropper:get_player_name(), "arena_lib:settings_region", get_deletion_warning_formspec())
  end,

  on_use = function(itemstack, user, pointed_thing)
    local mod         = user:get_meta():get_string("arena_lib_editor.mod")
    local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
    local id, arena   = arena_lib.get_arena_by_name(mod, arena_name)
    local p_name      = user:get_player_name()
    local p_pos       = user:get_pos()
    local pos2        = arena.pos2 or p_pos

    local schem_path = minetest.get_worldpath() .. ("/arena_lib/Schematics/%s_%d.mts"):format(mod, id)
    local schem = io.open(schem_path, "r")

    if schem then
      schem:close()
      minetest.show_formspec(p_name, "arena_lib:region_edit_warning", get_edit_warning_formspec(1))
    else
      -- copio perché arena.pos2 non è creato da vector.*, fallendo vector.check() in arena_lib.set_region()
      arena_lib.set_region(p_name, mod, arena_name, p_pos, vector.copy(pos2), true)
    end
  end,

  on_secondary_use = function(itemstack, user, pointed_thing)
    local mod         = user:get_meta():get_string("arena_lib_editor.mod")
    local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
    local id, arena   = arena_lib.get_arena_by_name(mod, arena_name)
    local p_name      = user:get_player_name()
    local p_pos       = user:get_pos()
    local pos1        = arena.pos1 or p_pos

    local schem_path = minetest.get_worldpath() .. ("/arena_lib/Schematics/%s_%d.mts"):format(mod, id)
    local schem = io.open(schem_path, "r")

    if schem then
      schem:close()
      minetest.show_formspec(p_name, "arena_lib:region_edit_warning", get_edit_warning_formspec(2))
    else
      arena_lib.set_region(p_name, mod, arena_name, vector.copy(pos1), p_pos, true)
    end
  end,

  on_place = function(itemstack, placer, pointed_thing)
    local mod         = placer:get_meta():get_string("arena_lib_editor.mod")
    local arena_name  = placer:get_meta():get_string("arena_lib_editor.arena")
    local id, arena   = arena_lib.get_arena_by_name(mod, arena_name)
    local p_name      = placer:get_player_name()
    local p_pos       = placer:get_pos()
    local pos1        = arena.pos1 or p_pos

    local schem_path = minetest.get_worldpath() .. ("/arena_lib/Schematics/%s_%d.mts"):format(mod, id)
    local schem = io.open(schem_path, "r")

    if schem then
      schem:close()
      minetest.show_formspec(p_name, "arena_lib:region_edit_warning", get_edit_warning_formspec(2))
    else
      arena_lib.set_region(p_name, mod, arena_name, vector.copy(pos1), p_pos, true)
    end
  end
})



minetest.register_tool("arena_lib:map_save", {
  description = S("Save a schematic of the map"),
  inventory_image = "arenalib_tool_map_save.png",
	groups = {not_in_creative_inventory = 1},
  on_drop = function() end,

  on_use = function (itemstack, player)
    local mod = player:get_meta():get_string("arena_lib_editor.mod")
    local arena_name = player:get_meta():get_string("arena_lib_editor.arena")

    arena_lib.save_map_schematic(player:get_player_name(), mod, arena_name, true)
  end
})



minetest.register_tool("arena_lib:map_hard_reset", {
  description = S("Load and paste the map schematic"),
  inventory_image = "arenalib_tool_map_load.png",
  groups = {not_in_creative_inventory = 1},
  on_drop = function() end,

  on_use = function (itemstack, player)
    local mod = player:get_meta():get_string("arena_lib_editor.mod")
    local arena_name = player:get_meta():get_string("arena_lib_editor.arena")
    local p_name = player:get_player_name()

    arena_lib.hard_reset_map(player:get_player_name(), mod, arena_name)
  end
})



function arena_lib.give_map_tools(inv)
  inv:set_list("main", map_tools)
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_edit_warning_formspec(pos_n)
  local formspec = {
    "size[5,2]",
    "style[region_edit_confirm;bgcolor=red]",
    "hypertext[0.25,-0.1;5,1.7;delete_msg;<global halign=center>" .. S("Are you sure you want to edit the region? The associated schematic will be deleted") .. "]",
    "button[3,1.5;1.5,0.5;region_edit_confirm;" .. S("Yes") .. "]",
    "button[0.5,1.5;1.5,0.5;region_edit_cancel;" .. S("Cancel") .. "]",
    "field[0,0;0,0;pos_n;;" .. pos_n .. "]",
    "field_close_on_enter[;false]"
  }

  return table.concat(formspec, "")
end



function get_deletion_warning_formspec()
  local formspec = {
    "size[5,2]",
    "style[region_delete_confirm;bgcolor=red]",
    "hypertext[0.25,-0.1;5,1.7;delete_msg;<global halign=center>" .. S("Are you sure you want to delete the region of the arena? It'll also delete the associated schematic, if any") .. "]",
    "button[3,1.5;1.5,0.5;region_delete_confirm;" .. S("Yes") .. "]",
    "button[0.5,1.5;1.5,0.5;region_delete_cancel;" .. S("Cancel") .. "]",
    "field_close_on_enter[;false]"
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "arena_lib:settings_region" and formname ~= "arena_lib:region_edit_warning" then return end

  local p_name      = player:get_player_name()
  local mod         = player:get_meta():get_string("arena_lib_editor.mod")
  local arena_name  = player:get_meta():get_string("arena_lib_editor.arena")

  -- deletion formspec
  if fields.region_delete_confirm then
    arena_lib.set_region(p_name, mod, arena_name, nil, nil, true)
    minetest.close_formspec(p_name, formname)

  -- edit formspec
  elseif fields.region_edit_confirm then
    local _, arena  = arena_lib.get_arena_by_name(mod, arena_name)
    local pos_n = tonumber(fields.pos_n)
    local pos1, pos2

    if pos_n == 1 then
      pos1 = player:get_pos()
      pos2 = arena.pos2 or pos1
    else
      pos2 = player:get_pos()
      pos1 = arena.pos1 or pos2
    end

    -- arena.pos non sono fatti da vector.*
    arena_lib.set_region(p_name, mod, arena_name, vector.copy(pos1), vector.copy(pos2), true)
    minetest.close_formspec(p_name, formname)

  elseif fields.region_delete_cancel or fields.region_edit_cancel then
    minetest.close_formspec(p_name, formname)
  end
end)
