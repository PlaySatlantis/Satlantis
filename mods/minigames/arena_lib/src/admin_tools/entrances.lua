local S = minetest.get_translator("arena_lib")

local function load_entrances() end
local function get_formspec() end

local entrances = {}                    -- KEY: def_name; VALUE: id
local entrances_tr_name = {}            -- KEY: translated_name; VALUE: def_name. Lo uso per convertire il nome tradotto nel nome usato per registrare l'entrata (per mostrare le traduzioni nel fs)
local entrances_str = ""
local players_in_entrance_fs = {}       -- KEY: p_name; VALUE: mod name

minetest.after(0.1, function()
  load_entrances()
end)



function arena_lib.enter_entrance_settings(p_name, mod)

  if arena_lib.is_player_in_arena(p_name) then
    arena_lib.print_error(p_name, S("You can't perform this action while in game!"))
    return end

  if not arena_lib.mods[mod] then
    arena_lib.print_error(p_name, S("This minigame doesn't exist!"))
    return end

  players_in_entrance_fs[p_name] = mod
  minetest.show_formspec(p_name, "arena_lib:entrance_settings", get_formspec(p_name, mod))
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function load_entrances()
  local i = 1
  for def_name, data in pairs (arena_lib.entrances) do
    entrances[def_name] = i
    entrances_tr_name[data.name] = def_name
    i = i + 1
    entrances_str = entrances_str .. data.name .. ","
  end

  entrances_str = entrances_str:sub(1, -2)
end



function get_formspec(sender, mod, all_value)

  local mod_ref = arena_lib.mods[mod]
  local arenas_amnt = 0

  for _, arena in pairs(mod_ref.arenas) do
    arenas_amnt = arenas_amnt + 1
  end

  local row_height = 0.8
  local size_y = 2.8 + (row_height * arenas_amnt)
  all_value = all_value or entrances[arena_lib.DEFAULT_ENTRANCE]

  local formspec = {
    "formspec_version[4]",
    "size[8.5," .. size_y .. "]",
    "hypertext[0,0.2;8.5,0.65;title;<global size=20 halign=center><b>" .. S("Entrance type - @1", mod_ref.name) .. "</b>]",
    "hypertext[0,0.65;8.5,0.5;title;<global halign=center>" .. S("Pressing 'overwrite' will try to disable the arena first") .. "]",
    "container[0.6,1.2]",
    "label[0,0.3;" ..S("OVERWRITE ALL") .. "]",
    "dropdown[3,0;2.1,0.6;all_arenas;" .. entrances_str .. ";" .. all_value .. "]",
    "button[5.5,0;2,0.6;overwriteALL;" .. S("Overwrite") .. "]",
    "container_end[]"
  }

  local y = 1.4
  for _, arena in pairs(mod_ref.arenas) do
    table.insert(formspec, #formspec, "label[0," .. y + 0.3 .. ";" .. arena.name
      .. "]dropdown[3,".. y .. ";2.1,0.6;arena_" .. arena.name .. ";" .. entrances_str .. ";" .. entrances[arena.entrance_type]
      .. "]button[5.5," .. y .. ";2,0.6;overwrite_" .. arena.name .. ";" .. S("Overwrite") .. "]")
    y = y + row_height
  end

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)

  if formname ~= "arena_lib:entrance_settings" then return end

  local p_name = player:get_player_name()
  local mod = players_in_entrance_fs[p_name]

  -- sovrascrivo tutte le arene in un colpo...
  if fields.overwriteALL then
    for _, arena in pairs(arena_lib.mods[mod].arenas) do
      local entrance_type = entrances_tr_name[fields["all_arenas"]]
      if arena.entrance_type == entrance_type then
        minetest.chat_send_player(p_name, S("@1 - nothing to overwrite", arena.name))
      elseif not arena.enabled or arena_lib.disable_arena(p_name, mod, arena.name) then
        arena_lib.set_entrance_type(p_name, mod, arena.name, entrance_type)
      end
    end

    local entrance_type_id = entrances[entrances_tr_name[fields["all_arenas"]]]
    minetest.show_formspec(p_name, "arena_lib:entrance_settings", get_formspec(p_name, mod, entrance_type_id))

  -- ..sennò solo quella del tasto premuto
  else
    for _, arena in pairs(arena_lib.mods[mod].arenas) do
      if fields["overwrite_" .. arena.name] then
        local entrance_type = entrances_tr_name[fields["arena_" .. arena.name]]
        if arena.entrance_type == entrance_type then
          minetest.chat_send_player(p_name, S("@1 - nothing to overwrite", arena.name))
        elseif not arena.enabled or arena_lib.disable_arena(p_name, mod, arena.name) then
          arena_lib.set_entrance_type(p_name, mod, arena.name, entrance_type)
        end
        break
      end
    end
  end

end)
