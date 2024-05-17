local S = minetest.get_translator("arena_lib")
local FS = minetest.formspec_escape

local function get_settings_formspec() end

local players_in_settings = {}        -- KEY: p_name; VALUE: mod name
local sel_setting_attr = {}           -- KEY: p_name; VALUE: {id = idx, name = setting_name}





function arena_lib.enter_minigame_settings(sender, mod)

  -- se è in coda o in gioco
  if arena_lib.is_player_in_queue(sender) then
    arena_lib.print_error(sender, S("You can't perform this action while in queue!"))
    return end

  if arena_lib.is_player_in_arena(sender) then
    arena_lib.print_error(sender, S("You can't perform this action while in game!"))
    return end

  -- se la mod non esiste
  if not arena_lib.mods[mod] then
    arena_lib.print_error(sender, S("This minigame doesn't exist!"))
    return end

  players_in_settings[sender] = mod
  minetest.show_formspec(sender, "arena_lib:minigame_settings", get_settings_formspec(sender, 1))
end



function arena_lib.quit_minigame_settings(p_name)
  players_in_settings[p_name] = nil
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function arena_lib.is_player_in_settings(p_name)
  return players_in_settings[p_name] ~= nil
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_settings_formspec(p_name, sel_idx)

  local mod_ref = arena_lib.mods[players_in_settings[p_name]]
  local settings = ""
  local settings_by_idx = {}
  local sel_setting = ""
  local sel_setting_value = ""
  local i = 1

  -- ottengo una stringa con tutte le impostazioni
  for setting, v in pairs(mod_ref.settings) do
    settings = settings .. setting .. " = " .. FS(AL_property_to_string(mod_ref.settings[setting])) .. ","
    settings_by_idx[i] = setting
    i = i + 1
  end

  -- ottengo il nome della proprietà selezionata
  if not sel_idx then
    sel_setting = settings_by_idx[1]
  else
    sel_setting = settings_by_idx[sel_idx]
  end

  -- e assegno il valore
  sel_setting_attr[p_name] = {id = sel_idx, name = sel_setting}
  sel_setting_value = FS(AL_property_to_string(mod_ref.settings[sel_setting]))

  settings = settings:sub(1,-2)

  local formspec = {
    "size[6.25,3.7]",
    "hypertext[0,0;6.25,1;settings_title;<global halign=center>" .. S("Minigame settings") .. "]",
    "textlist[0,0.5;6,2.5;minigame_settings;" .. settings .. ";" .. sel_idx .. ";false]",
    "field[0.3,3.3;4.7,1;sel_setting_value;;" .. sel_setting_value .. "]",
    "button[4.72,2.983;1.5,1;setting_overwrite;" .. S("Overwrite") .. "]",
    "field_close_on_enter[sel_setting_value;false]"
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)

  if formname ~= "arena_lib:minigame_settings" then return end

  local p_name = player:get_player_name()

  -- se clicco sulla lista
  if fields.minigame_settings then

    local expl = minetest.explode_textlist_event(fields.minigame_settings)

    if expl.type == "DCL" or expl.type == "CHG" then
      minetest.show_formspec(p_name, "arena_lib:minigame_settings", get_settings_formspec(p_name, expl.index))
    end

  -- se premo per sovrascrivere
  elseif fields.setting_overwrite or fields.key_enter then

    local mod = players_in_settings[p_name]

    arena_lib.change_mod_settings(p_name, mod, sel_setting_attr[p_name].name, fields.sel_setting_value, true)
    minetest.show_formspec(p_name, "arena_lib:minigame_settings", get_settings_formspec(p_name, sel_setting_attr[p_name].id))

  -- se chiudo
  elseif fields.quit then
    arena_lib.quit_minigame_settings(p_name)
  end
end)
