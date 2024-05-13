local S = minetest.get_translator("arena_lib")

local function fill_templight() end
local function get_lighting_formspec() end

local temp_light_settings = {}          -- KEY = p_name; VALUE = {light, saturation}



minetest.register_tool("arena_lib:customise_lighting", {

    description = S("Lighting"),
    inventory_image = "arenalib_customise_lighting.png",
    groups = {not_in_creative_inventory = 1},
    on_place = function() end,
    on_drop = function() end,

    on_use = function(itemstack, user, pointed_thing)

      local mod         = user:get_meta():get_string("arena_lib_editor.mod")
      local arena_name  = user:get_meta():get_string("arena_lib_editor.arena")
      local _, arena   = arena_lib.get_arena_by_name(mod, arena_name)
      local p_name      = user:get_player_name()

      fill_templight(p_name, arena)

      minetest.show_formspec(p_name, "arena_lib:lighting", get_lighting_formspec(p_name))
    end
})





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function fill_templight(p_name, arena)
  temp_light_settings[p_name] = not arena.lighting and {} or table.copy(arena.lighting)

  if not temp_light_settings[p_name].shaders then
    temp_light_settings[p_name].shaders = {}
  end
end



function get_lighting_formspec(p_name)

  local light = (temp_light_settings[p_name].light or 1) * 100
  local saturation = (temp_light_settings[p_name].shaders.saturation or 1) * 100

  local formspec = {
    "formspec_version[4]",
    "size[7,3.5]",
    "bgcolor[;neither]",
    -- parametri vari
    "container[0.5,0.5]",
    "label[0,0;" .. S("Global light") .. "]",
    "label[0,0.41;0]",
    "label[5.8,0.41;1]",
    "scrollbaroptions[max=100;smallstep=1;largestep=10;arrows=hide]",
    "scrollbar[0.4,0.3;5.2,0.2;;light;" .. light .. "]",
    "label[0,1;" .. S("Saturation") .. "]",
    "label[0,1.41;0]",
    "label[5.8,1.41;1]",
    "scrollbar[0.4,1.3;5.2,0.2;;saturation;" .. saturation .. "]",
    "container_end[]",
    "button[1.95,2.7;1.5,0.5;reset;" .. S("Reset") .."]",
    "button[3.55,2.7;1.5,0.5;apply;" .. S("Apply") .."]"
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)

  if formname ~= "arena_lib:lighting" then return end

  local p_name = player:get_player_name()
  local mod         = player:get_meta():get_string("arena_lib_editor.mod")
  local arena_name  = player:get_meta():get_string("arena_lib_editor.arena")
  local _, arena    = arena_lib.get_arena_by_name(mod, arena_name)
  local temp_light  = temp_light_settings[p_name]
  local arena_light = arena.lighting

  -- se abbandona...
  if fields.quit then
    if arena_light then
      if arena_light.light      then player:override_day_night_ratio(arena_light.light) end
      if arena_light.shaders    then player:set_lighting(arena_light.shaders) end
    else
      player:override_day_night_ratio(nil)
      player:set_lighting({saturation = 1})
    end

    temp_light_settings[p_name] = nil
    return

  -- ...o se ripristina, non c'è bisogno di andare oltre
  elseif fields.reset then
    -- se la tabella non esiste, vuol dire che non c'è nulla da ripristinare (ed evito
    -- che invii il messaggio di proprietà sovrascritte)
    if arena_light then
      arena_lib.set_lighting(p_name, mod, arena_name, nil, true)
    end

    player:override_day_night_ratio(nil)
    player:set_lighting({saturation = 1})
    minetest.show_formspec(p_name, "arena_lib:lighting", get_lighting_formspec(p_name))
    return
  end

  --
  -- aggiorna i vari parametri
  --

  if fields.light then
    temp_light.light = minetest.explode_scrollbar_event(fields.light).value / 100
  end

  if fields.saturation then
    temp_light.shaders.saturation = minetest.explode_scrollbar_event(fields.saturation).value / 100
  end


  -- applica
  if fields.apply then
    arena_lib.set_lighting(p_name, mod, arena_name, temp_light, true)
  end

  player:override_day_night_ratio(temp_light.light)
  player:set_lighting(temp_light.shaders)
end)
