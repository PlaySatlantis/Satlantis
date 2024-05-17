local S = minetest.get_translator("arena_lib")
local FS = minetest.formspec_escape

local function get_rename_author_thumbnail_formspec() end
local function get_properties_formspec() end
local function get_timer_formspec() end
local function get_delete_formspec() end

local settings_tools = {
  "arena_lib:settings_returnpoint",
  "arena_lib:settings_rename_author",
  "arena_lib:settings_properties",
  "",                                       -- timer_off/_on
  "",
  "",
  "arena_lib:settings_delete",
  "",
  "arena_lib:editor_return",
  "arena_lib:editor_quit",
}

local sel_property_attr = {}     --KEY: p_name; VALUE: {id = idx, name = property_name}



minetest.register_tool("arena_lib:settings_returnpoint", {
  description = S("Custom return point (LMB sets, RMB removes)"),
  inventory_image = "arenalib_tool_settings_returnpoint.png",
  groups = {not_in_creative_inventory = 1},
  on_drop = function() end,

  on_use = function(itemstack, user, pointed_thing)
    local p_name      = user:get_player_name()
    local mod         = user:get_meta():get_string("arena_lib_editor.mod")
    local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")

    arena_lib.set_custom_return_point(p_name, mod, arena_name, vector.round(user:get_pos()), true)
  end,

  on_secondary_use = function(itemstack, user, pointed_thing)
    local p_name      = user:get_player_name()
    local mod         = user:get_meta():get_string("arena_lib_editor.mod")
    local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")

    arena_lib.set_custom_return_point(p_name, mod, arena_name, nil, true)
  end,

  on_place = function(itemstack, placer, pointed_thing)
    local p_name      = placer:get_player_name()
    local mod         = placer:get_meta():get_string("arena_lib_editor.mod")
    local arena_name  = placer:get_meta():get_string("arena_lib_editor.arena")

    arena_lib.set_custom_return_point(p_name, mod, arena_name, nil, true)
  end
})



minetest.register_tool("arena_lib:settings_rename_author", {

    description = S("Arena name, author and thumbnail"),
    inventory_image = "arenalib_tool_settings_nameauthorthumb.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena   = arena_lib.get_arena_by_name(mod, arena_name)

      minetest.show_formspec(user:get_player_name(), "arena_lib:settings_rename_author_thumbnail", get_rename_author_thumbnail_formspec(arena))
    end
})



minetest.register_tool("arena_lib:settings_properties", {

    description = S("Arena properties"),
    inventory_image = "arenalib_tool_settings_properties.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local p_name      = user:get_player_name()
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)

      minetest.show_formspec(p_name, "arena_lib:settings_properties", get_properties_formspec(p_name, mod, arena, 1))
    end
})



minetest.register_craftitem("arena_lib:timer", {

    description = S("Timer: on"),
    inventory_image = "arenalib_tool_settings_timer.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
      local time       = arena.initial_time

      minetest.show_formspec(user:get_player_name(), "arena_lib:settings_timer", get_timer_formspec(time))
    end
})



minetest.register_tool("arena_lib:settings_delete", {

    description = S("Delete arena"),
    inventory_image = "arenalib_tool_settings_delete.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)
      local p_name      = user:get_player_name()
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")

      minetest.show_formspec(p_name, "arena_lib:settings_delete", get_delete_formspec(p_name, arena_name))
    end
})



function arena_lib.give_settings_tools(user)
  user:get_inventory():set_list("main", settings_tools)

  local inv = user:get_inventory()
  local mod = user:get_meta():get_string("arena_lib_editor.mod")
  local arena_name = user:get_meta():get_string("arena_lib_editor.arena")
  local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

  local mod_ref = arena_lib.mods[mod]

  if mod_ref.time_mode == "decremental" then
    inv:set_stack("main", 4, "arena_lib:timer")
  end
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_rename_author_thumbnail_formspec(arena)
  local formspec = {
    "formspec_version[4]",
    "size[6.2,3]",
    "no_prepend[]",
    "bgcolor[;neither]",
    "field[0,0.1;3.7,0.7;rename;;" .. arena.name .. "]",
    "button[3.8,0.1;2.4,0.7;rename_confirm;" .. S("Rename arena") .. "]",
    "field[0,1;3.7,0.7;author;;" .. arena.author .. "]",
    "button[3.8,1;2.4,0.7;author_confirm;" .. S("Set author") .. "]",
    "field[0,1.9;3.7,0.7;thumbnail;;" .. arena.thumbnail .. "]",
    "button[3.8,1.9;2.4,0.7;thumbnail_confirm;" .. S("Set thumbnail") .. "]",
    "field_close_on_enter[rename;false]",
    "field_close_on_enter[author;false]",
    "field_close_on_enter[thumbnail;false]"
  }

  return table.concat(formspec, "")
end



function get_properties_formspec(p_name, mod, arena, sel_idx)
  local mod_ref = arena_lib.mods[mod]
  local properties = ""
  local properties_by_idx = {}
  local sel_property = ""
  local sel_property_value = ""
  local i = 1

  -- ottengo una stringa con tutte le proprietà
  for property, v in pairs(mod_ref.properties) do
    properties = properties .. property .. " = " .. FS(AL_property_to_string(arena[property])) .. ","
    properties_by_idx[i] = property
    i = i + 1
  end

  -- ottengo il nome della proprietà selezionata
  if not sel_idx then
    sel_property = properties_by_idx[1]
  else
    sel_property = properties_by_idx[sel_idx]
  end

  -- e assegno il valore
  sel_property_attr[p_name] = {id = sel_idx, name = sel_property}
  sel_property_value = FS(AL_property_to_string(arena[sel_property]))

  properties = properties:sub(1,-2)

  local formspec = {
    "size[6.25,3.7]",
    "hypertext[0,0;6.25,1;properties_title;<global halign=center>" .. S("Arena properties") .. "]",
    "textlist[0,0.5;6,2.5;arena_properties;" .. properties .. ";" .. sel_idx .. ";false]",
    "field[0.3,3.3;4.7,1;sel_property_value;;" .. sel_property_value .. "]",
    "button[4.72,2.983;1.5,1;property_overwrite;" .. S("Overwrite") .. "]",
    "field_close_on_enter[sel_property_value;false]"
  }

  return table.concat(formspec, "")
end



function get_timer_formspec(time)
  local formspec = {
    "size[5.2,0.4]",
    "no_prepend[]",
    "bgcolor[;neither]",
    "field[0.2,0.25;4,1;set_timer;;" .. time .."]",
    "button[3.8,-0.05;1.7,1;timer_confirm;" .. S("Set timer") .. "]",
    "field_close_on_enter[set_timer;false]"
  }

  return table.concat(formspec, "")
end



function get_delete_formspec(p_name, arena_name)
  local formspec = {
    "size[5,1]",
    "style[delete_confirm;bgcolor=red]",
    "hypertext[0.25,-0.1;5,1;delete_msg;<global halign=center>" .. S("Are you sure you want to delete arena @1?", arena_name) .. "]",
    "button[3,0.5;1.5,0.5;delete_confirm;" .. S("Yes") .. "]",
    "button[0.5,0.5;1.5,0.5;delete_cancel;" .. S("Cancel") .. "]",
    "field_close_on_enter[;false]"
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)

  if formname ~= "arena_lib:settings_timer" and formname ~= "arena_lib:settings_rename_author_thumbnail"
  and formname ~= "arena_lib:settings_properties" and formname ~= "arena_lib:settings_delete" then
  return end

  local p_name      =   player:get_player_name()
  local mod         =   player:get_meta():get_string("arena_lib_editor.mod")
  local arena_name  =   player:get_meta():get_string("arena_lib_editor.arena")

  -- GUI per rinominare arena e cambiare autore e miniatura
  if formname == "arena_lib:settings_rename_author_thumbnail" then
    if fields.key_enter then
      if fields.key_enter_field == "rename" then
        if not arena_lib.rename_arena(p_name, mod, arena_name, fields.rename, true) then return end

        local p_meta = player:get_meta()

        arena_lib.update_arena_in_edit_mode_name(p_meta:get_string("arena_lib_editor.arena"), fields.rename)
        p_meta:set_string("arena_lib_editor.arena", fields.rename)

      elseif fields.key_enter_field == "author" then
        arena_lib.set_author(p_name, mod, arena_name, fields.author, true)

      elseif fields.key_enter_field == "thumbnail" then
        arena_lib.set_thumbnail(p_name, mod, arena_name, fields.thumbnail, true)
      end

    elseif fields.rename_confirm then
      if not arena_lib.rename_arena(p_name, mod, arena_name, fields.rename, true) then return end

      local p_meta = player:get_meta()

      arena_lib.update_arena_in_edit_mode_name(p_meta:get_string("arena_lib_editor.arena"), fields.rename)
      p_meta:set_string("arena_lib_editor.arena", fields.rename)

    elseif fields.author_confirm then
      arena_lib.set_author(p_name, mod, arena_name, fields.author, true)

    elseif fields.thumbnail_confirm then
      arena_lib.set_thumbnail(p_name, mod, arena_name, fields.thumbnail, true)
    end

  -- GUI per modificare proprietà
  elseif formname == "arena_lib:settings_properties" then
    local id, arena = arena_lib.get_arena_by_name(mod, arena_name)

    -- se clicco sulla lista
    if fields.arena_properties then

      local expl = minetest.explode_textlist_event(fields.arena_properties)

      if expl.type == "DCL" or expl.type == "CHG" then
        minetest.show_formspec(p_name, "arena_lib:settings_properties", get_properties_formspec(p_name, mod, arena, expl.index))
      end

    -- se premo per sovrascrivere
    elseif fields.property_overwrite or fields.key_enter then
      arena_lib.change_arena_property(p_name, mod, arena_name, sel_property_attr[p_name].name, fields.sel_property_value, true)
      minetest.show_formspec(p_name, "arena_lib:settings_properties", get_properties_formspec(p_name, mod, arena, sel_property_attr[p_name].id))
    end

  -- GUI per timer
  elseif formname == "arena_lib:settings_timer" then
    if fields.timer_confirm or fields.key_enter then

      local timer = tonumber(fields.set_timer)

      if timer == nil or timer < 1 then
        arena_lib.print_error(p_name, S("Parameters don't seem right!"))
        return end

      arena_lib.set_timer(p_name, mod, arena_name, timer, true)
      minetest.close_formspec(p_name, formname)
    end

  -- GUI per cancellare arena
  else
    if fields.delete_confirm then
      arena_lib.quit_editor(player)
      minetest.close_formspec(p_name, formname)

      arena_lib.remove_arena(p_name, mod, arena_name, true)
    elseif fields.delete_cancel then
      minetest.close_formspec(p_name, formname)
    end

  end
end)
