local S = minetest.get_translator("arena_lib")

local function override_hotbar() end
local function set_spectator() end

local players_in_spectate_mode = {}         -- KEY: player name, VALUE: {(string) minigame, (int) arenaID, (string) type, (string) spectating}
local spectate_temp_storage = {}            -- KEY: player_name, VALUE: {(table) camera_offset, (string) inventory_fs, (ItemStack) hand}
local players_spectated = {}                -- KEY: player name, VALUE: {(string) spectator(s) = true}
local entities_spectated = {}               -- KEY: [mod][arena_name][entity name], VALUE: {(string) spectator(s) = true}
local areas_spectated = {}                  -- KEY: [mod][arena_name][area_name], VALUE: {(string) spectator(s) = true}
local entities_storage = {}                 -- KEY: [mod][arena_name][entity_name], VALUE: entity
local areas_storage = {}                    -- KEY: [mod][arena_name][area_name], VALUE: dummy entity



----------------------------------------------
--------------INTERNAL USE ONLY---------------
----------------------------------------------

-- init e unload servono esclusivamente per le eventuali entità e aree, e vengon
-- chiamate rispettivamente quando l'arena si avvia e termina. I contenitori dei
-- giocatori invece vengono creati/distrutti singolarmente ogni volta che un giocatore
-- entra/esce, venendo lanciati in operations_before_playing/leaving_arena

function arena_lib.init_spectate_containers(mod, arena_name)
  if not entities_spectated[mod] then
    entities_spectated[mod] = {}
  end
  if not areas_spectated[mod] then
    areas_spectated[mod] = {}
  end
  if not entities_storage[mod] then
    entities_storage[mod] = {}
  end
  if not areas_storage[mod] then
    areas_storage[mod] = {}
  end

  entities_spectated[mod][arena_name] = {}
  areas_spectated[mod][arena_name] = {}
  entities_storage[mod][arena_name] = {}
  areas_storage[mod][arena_name] = {}
end



function arena_lib.unload_spectate_containers(mod, arena_name)
  -- rimuovo tutte le entità fantoccio delle aree
  for _, dummy_entity in pairs(arena_lib.get_spectatable_areas(mod, arena_name)) do
    dummy_entity:remove()
  end

  -- non c'è bisogno di cancellare X[mod], al massimo rimangono vuote
  entities_spectated[mod][arena_name] = nil
  areas_spectated[mod][arena_name] = nil
  entities_storage[mod][arena_name] = nil
  areas_storage[mod][arena_name] = nil
end



function arena_lib.add_spectate_p_container(p_name)
  players_spectated[p_name] = {}
end



function arena_lib.remove_spectate_p_container(p_name)
  players_spectated[p_name] = {}
end


----------------------------
-- entering / leaving
----------------------------

function arena_lib.enter_spectate_mode(p_name, arena, xc_name)
  local mod      = arena_lib.get_mod_by_player(p_name)
  local arena_ID = arena_lib.get_arenaID_by_player(p_name)
  local team_ID  = #arena.teams > 1 and 1 or nil
  local player   = minetest.get_player_by_name(p_name)
  local hand     = player:get_inventory():get_list("hand")

  players_in_spectate_mode[p_name] = { minigame = mod, arenaID = arena_ID, teamID = team_ID, hand = hand}
  arena.spectators[p_name] = {}
  arena.players_and_spectators[p_name] = true
  arena.spectators_amount = arena.spectators_amount + 1

  -- eventuali proprietà aggiuntive
  for k, v in pairs(arena_lib.mods[mod].spectator_properties) do
    if type(v) == "table" then
      arena.spectators[p_name][k] = table.copy(v)
    else
      arena.spectators[p_name][k] = v
    end
  end

  -- che siano entrati anche come giocatori o meno, non importa, in quanto operations_before_entering_arena
  -- viene eseguita prima dell'entrata nella spettatore, e quindi questi parametri
  -- sono già stati eventualmente salvati nell'archiviazione di arena_lib
  spectate_temp_storage[p_name] = {}
  spectate_temp_storage[p_name].camera_offset = {player:get_eye_offset()}
  spectate_temp_storage[p_name].inventory_fs = player:get_inventory_formspec()
  spectate_temp_storage[p_name].hand = player:get_inventory():get_stack("hand", 1)

  -- applico mano finta
  player:get_inventory():set_size("hand", 1)
  player:get_inventory():set_stack("hand", 1, "arena_lib:spectate_hand")

  -- applicazione parametri vari
  local current_properties = table.copy(player:get_properties())
  players_in_spectate_mode[p_name].properties = current_properties

  player:set_properties({
    visual_size = {x = 0, y = 0},
    makes_footstep_sound = false,
    collisionbox = {0},
    pointable = false
  })

  player:set_eye_offset({x = 0, y = -2, z = -25}, {x=0, y=0, z=0})
  player:set_nametag_attributes({color = {a = 0}})
  player:set_inventory_formspec("")

  -- assegno un ID al giocatore per ruotare chi/cosa sta seguendo, in quanto gli
  -- elementi seguibili non dispongono di un ID per orientarsi nella loro navigazione
  -- (cosa viene dopo l'elemento X? È il capolinea?). Lo uso essenzialmente come
  -- un i = 1 nei cicli for, per capire dove mi trovo e cosa verrebbe dopo
  -- (assegnarlo a 0 equivale ad azzerarlo, ma l'ho specificato per chiarezza nel codice)
  player:get_meta():set_int("arenalib_watchID", 0)

  local curr_spectators = ""

  -- dì chi sta già seguendo
  for sp_name, _ in pairs(arena.spectators) do
    curr_spectators = curr_spectators .. sp_name .. ", "
  end

  curr_spectators = curr_spectators:sub(1, -3)
  minetest.chat_send_player(p_name, minetest.colorize("#cfc6b8", S("Spectators inside: @1", curr_spectators)))

  -- inizia a seguire
  if xc_name and p_name ~= xc_name and minetest.get_player_by_name(xc_name) then
    arena_lib.spectate_target(mod, arena, p_name, "player", xc_name)
  else
    arena_lib.find_and_spectate_player(p_name)
  end

  override_hotbar(player, mod, arena)
  return true
end



function arena_lib.leave_spectate_mode(p_name)
  local arena = arena_lib.get_arena_by_player(p_name)

  arena.spectators[p_name] = nil
  arena.spectators_amount = arena.spectators_amount -1

  local player = minetest.get_player_by_name(p_name)
  local p_inv = player:get_inventory()

  -- rimuovo mano finta e reimposto eventuale mano precedente
  p_inv:set_list("hand", players_in_spectate_mode[p_name].hand)

  if not players_in_spectate_mode[p_name].hand then
    p_inv:set_size("hand", 0)
  end

  -- che siano entrati anche come giocatori o meno, non importa, in quanto operations_before_leaving_arena
  -- viene eseguita dopo l'uscita dalla spettatore, e quindi questi parametri
  -- verranno eventualmente poi sovrascritti da quelli nell'archiviazione di arena_lib
  player:set_eye_offset(spectate_temp_storage[p_name].camera_offset[1], spectate_temp_storage[p_name].camera_offset[2])
  player:set_inventory_formspec(spectate_temp_storage[p_name].inventory_fs)
  player:get_inventory():set_stack("hand", 1, spectate_temp_storage[p_name].hand)
  spectate_temp_storage[p_name] = nil

  player:set_detach()
  player:set_properties(players_in_spectate_mode[p_name].properties)
  player:get_meta():set_int("arenalib_watchID", 0)

  arena_lib.HUD_hide("hotbar", p_name)

  local target = players_in_spectate_mode[p_name].spectating
  local type = players_in_spectate_mode[p_name].type

  -- rimuovo dal database locale
  if type == "player" then
    players_spectated[target][p_name] = nil
  else

    local mod = arena_lib.get_mod_by_player(p_name)
    local arena_name = arena.name

    if type == "entity" then
      entities_spectated[mod][arena_name][target][p_name] = nil
    elseif type == "area" then
      areas_spectated[mod][arena_name][target][p_name] = nil
    end
  end

  players_in_spectate_mode[p_name] = nil
end



----------------------------
-- find next spectatable target
----------------------------

function arena_lib.find_and_spectate_player(sp_name, change_team, go_counterwise)
  local arena = arena_lib.get_arena_by_player(sp_name)

  -- se l'ultimo rimasto ha abbandonato (es. alt+f4), rispedisco subito fuori senza che cada all'infinito con rischio di crash
  if arena.players_amount == 0 then
    arena_lib.remove_player_from_arena(sp_name, 3)
    return end

  local prev_spectated = players_in_spectate_mode[sp_name].spectating

  -- se c'è rimasto solo un giocatore e già lo si seguiva, annullo
  if arena.players_amount == 1 and prev_spectated and arena.players[prev_spectated] then return end

  local spectator = minetest.get_player_by_name(sp_name)

  if players_in_spectate_mode[sp_name].type ~= "player" then
    spectator:get_meta():set_int("arenalib_watchID", 0)
  end

  local team_ID = players_in_spectate_mode[sp_name].teamID
  local players_amount

  -- calcolo giocatori massimi tra cui ruotare
  -- squadre:
  if #arena.teams > 1 then
    -- se è l'unico rimasto nella squadra e già lo si seguiva, annullo
    if arena.players_amount_per_team[team_ID] == 1 and not change_team and prev_spectated and arena.players[prev_spectated] then return end

    -- se il giocatore seguito era l'ultimo membro della sua squadra, la imposto da cambiare
    if arena.players_amount_per_team[team_ID] == 0 then
      change_team = true
    end

    -- eventuale cambio squadra sul quale eseguire il calcolo
    if change_team then
      arena.spectators_amount_per_team[team_ID] = arena.spectators_amount_per_team[team_ID] - 1

      local active_teams = arena_lib.get_active_teams(arena)

      if team_ID >= active_teams[#active_teams] then
        team_ID = active_teams[1]
      else
        for i = team_ID + 1, #arena.teams do
          if arena.players_amount_per_team[i] ~= 0 then
            team_ID = i
            break
          end
        end
      end
      players_in_spectate_mode[sp_name].teamID = team_ID
      arena.spectators_amount_per_team[team_ID] = arena.spectators_amount_per_team[team_ID] + 1
    end

    players_amount = arena.players_amount_per_team[team_ID]

  -- no squadre:
  else
    players_amount = arena.players_amount
  end

  local mod = arena_lib.get_mod_by_player(sp_name)
  local current_ID = spectator:get_meta():get_int("arenalib_watchID")
  local new_ID

  if go_counterwise then
    new_ID = current_ID == 1 and players_amount or current_ID - 1
  else
    new_ID = players_amount <= current_ID and 1 or current_ID + 1
  end

  -- trovo il giocatore da seguire
  -- squadre:
  if #arena.teams > 1 then
    local players_team = arena_lib.get_players_in_team(arena, team_ID)
    for i = 1, #players_team do

      if i == new_ID then
        set_spectator(mod, arena.name, spectator, "player", players_team[i], i)
        return true
      end
    end

  -- no squadre:
  else
    local i = 1
    for pl_name, _ in pairs(arena.players) do
      if i == new_ID then
        set_spectator(mod, arena.name, spectator, "player", pl_name, i)
        return true
      end

      i = i + 1
    end
  end
end



function arena_lib.find_and_spectate_entity(mod, arena, sp_name, go_counterwise)
  local e_amount = arena.spectate_entities_amount

  -- se non ci sono entità da seguire, segui un giocatore
  if e_amount == 0 then
    arena_lib.find_and_spectate_player(sp_name)
    return end

  local arena_name = arena.name
  local prev_spectated = players_in_spectate_mode[sp_name].spectating

  -- se è l'unica entità rimasta e la si stava già seguendo
  if e_amount == 1 and prev_spectated and next(entities_spectated[mod][arena_name])[sp_name] then
    return end

  local spectator = minetest.get_player_by_name(sp_name)

  if players_in_spectate_mode[sp_name].type ~= "entity" then
    spectator:get_meta():set_int("arenalib_watchID", 0)
  end

  local current_ID = spectator:get_meta():get_int("arenalib_watchID")
  local new_ID

  if go_counterwise then
    new_ID = current_ID == 1 and e_amount or current_ID - 1
  else
    new_ID = e_amount <= current_ID and 1 or current_ID + 1
  end

  local i = 1
  for en_name, _ in pairs(entities_storage[mod][arena_name]) do
    if i == new_ID then
      set_spectator(mod, arena_name, spectator, "entity", en_name, i)
      return true
    end

    i = i +1
  end
end



function arena_lib.find_and_spectate_area(mod, arena, sp_name, go_counterwise)
  local ar_amount = arena.spectate_areas_amount

  -- se non ci sono aree da seguire, segui un giocatore
  if ar_amount == 0 then
    arena_lib.find_and_spectate_player(sp_name)
    return end

  local arena_name = arena.name
  local prev_spectated = players_in_spectate_mode[sp_name].spectating

  -- se è l'unica area rimasta e la si stava già seguendo
  if ar_amount == 1 and prev_spectated and next(areas_spectated[mod][arena_name])[sp_name] then
    return end

  local spectator = minetest.get_player_by_name(sp_name)

  if players_in_spectate_mode[sp_name].type ~= "area" then
    spectator:get_meta():set_int("arenalib_watchID", 0)
  end

  local current_ID = spectator:get_meta():get_int("arenalib_watchID")
  local new_ID

  if go_counterwise then
    new_ID = current_ID == 1 and ar_amount or current_ID - 1
  else
    new_ID = ar_amount <= current_ID and 1 or current_ID + 1
  end

  local i = 1
  for ar_name, _ in pairs(areas_storage[mod][arena_name]) do
    if i == new_ID then
      set_spectator(mod, arena_name, spectator, "area", ar_name, i)
      return true
    end

    i = i +1
  end
end





----------------------------------------------
---------------------CORE---------------------
----------------------------------------------

function arena_lib.add_spectate_entity(mod, arena, e_name, entity)
  if not arena.in_game then return end

  local arena_name = arena.name
  local old_deact = entity.on_deactivate

  -- aggiungo sull'on_deactivate la funzione per rimuoverla dalla spettatore
  entity.on_deactivate = function(...)
    local ret = old_deact and old_deact(...)

    arena_lib.remove_spectate_entity(mod, arena, e_name)
    return ret
  end

  -- la aggiungo
  entities_spectated[mod][arena_name][e_name] = {}
  entities_storage[mod][arena_name][e_name] = entity
  arena.spectate_entities_amount = arena.spectate_entities_amount + 1

  -- se è l'unica entità registrata, aggiungo lo slot per seguire le entità
  if arena.spectate_entities_amount == 1 then
    for sp_name, _ in pairs(arena.spectators) do
      override_hotbar(minetest.get_player_by_name(sp_name), mod, arena)
    end
  end
end



function arena_lib.add_spectate_area(mod, arena, pos_name, pos)
  if not arena.in_game then return end

  minetest.forceload_block(pos, true)

  local dummy_entity = minetest.add_entity(pos, "arena_lib:spectate_dummy")
  local arena_name = arena.name

  areas_spectated[mod][arena_name][pos_name] = {}
  areas_storage[mod][arena_name][pos_name] = dummy_entity
  arena.spectate_areas_amount = arena.spectate_areas_amount + 1

  -- se è l'unica area registrata, aggiungo lo slot per seguire le aree
  if arena.spectate_areas_amount == 1 then
    for sp_name, _ in pairs(arena.spectators) do
      override_hotbar(minetest.get_player_by_name(sp_name), mod, arena)
    end
  end

end



function arena_lib.remove_spectate_entity(mod, arena, e_name)
  if not arena.in_game then return end          -- nel caso il minigioco si sia scordata di cancellarla, all'ucciderla fuori dalla partita non crasha

  local arena_name = arena.name

  entities_storage[mod][arena_name][e_name] = nil
  arena.spectate_entities_amount = arena.spectate_entities_amount - 1

  -- se non ci sono più entità, fai sparire l'icona
  if arena.spectate_entities_amount == 0 then
    for sp_name, _ in pairs(arena.spectators) do
      local spectator = minetest.get_player_by_name(sp_name)
      override_hotbar(spectator, mod, arena)
    end
  end

  for sp_name, _ in pairs(entities_spectated[mod][arena_name][e_name]) do
    arena_lib.find_and_spectate_entity(mod, arena, sp_name)
  end
end



function arena_lib.remove_spectate_area(mod, arena, pos_name)
  local arena_name = arena.name

  areas_storage[mod][arena_name][pos_name]:remove()
  areas_storage[mod][arena_name][pos_name] = nil
  arena.spectate_areas_amount = arena.spectate_areas_amount - 1

  -- se non ci sono più aree, fai sparire l'icona
  if arena.spectate_areas_amount == 0 then
    for sp_name, _ in pairs(arena.spectators) do
      local spectator = minetest.get_player_by_name(sp_name)
      override_hotbar(spectator, mod, arena)
    end
  end

  for sp_name, _ in pairs(areas_spectated[mod][arena_name][pos_name]) do
    arena_lib.find_and_spectate_area(mod, arena, sp_name)
  end
end



function arena_lib.spectate_target(mod, arena, sp_name, type, t_name)
  if type == "player" then
    if arena.players_amount == 0 or not players_spectated[t_name] then return end

    -- se ci son le squadre, assegna l'ID della squadra
    if arena.teams_enabled then
      players_in_spectate_mode[sp_name].teamID = arena.players[t_name].teamID
    end
  elseif type == "entity" then
    if arena.spectate_entities_amount == 0 or not entities_spectated[mod][arena.name][t_name] then return end
  elseif type == "area" then
    if arena.spectate_areas_amount == 0 or not areas_spectated[mod][arena.name][t_name] then return end
  else
    return
  end

  -- sì, potrei richiedere direttamente 'spectator', ma per coesione con il resto dell'API e con il fatto che
  -- arena_lib salva lɜ spettatorɜ indicizzandolɜ per nome, tanto vale una conversione in più qui
  local spectator = minetest.get_player_by_name(sp_name)
  local i = spectator:get_meta():get_int("arenalib_watchID")     -- non c'è bisogno di calcolare l'ID, riapplico quello che già ha
  set_spectator(mod, arena.name, spectator, type, t_name, i, true)
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

function arena_lib.is_player_spectating(sp_name)
  return players_in_spectate_mode[sp_name] ~= nil
end



function arena_lib.is_player_spectated(p_name)
  return players_spectated[p_name] and next(players_spectated[p_name])
end



function arena_lib.is_entity_spectated(mod, arena_name, e_name)
  return entities_spectated[mod][arena_name][e_name] and next(entities_spectated[mod][arena_name][e_name])
end



function arena_lib.is_area_spectated(mod, arena_name, pos_name)
  return areas_spectated[mod][arena_name][pos_name] and next(areas_spectated[mod][arena_name][pos_name])
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function arena_lib.get_player_spectators(p_name)
  return players_spectated[p_name]
end



function arena_lib.get_target_spectators(mod, arena_name, type, t_name)
  if type == "player" then
    return players_spectated[t_name]
  elseif type == "entity" then
    return entities_spectated[mod][arena_name][t_name]
  elseif type == "area" then
    return areas_spectated[mod][arena_name][t_name]
  end
end



function arena_lib.get_spectated_target(sp_name)
  if arena_lib.is_player_spectating(sp_name) then
    local p_data = players_in_spectate_mode[sp_name]
    return {type = p_data.type, name = p_data.spectating}
  end
end



function arena_lib.get_spectatable_entities(mod, arena_name)
  return entities_storage[mod][arena_name]
end



function arena_lib.get_spectatable_areas(mod, arena_name)
  return areas_storage[mod][arena_name]
end



----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function set_spectator(mod, arena_name, spectator, type, name, i, is_forced)
  local sp_name = spectator:get_player_name()
  local prev_spectated = players_in_spectate_mode[sp_name].spectating
  local prev_type = players_in_spectate_mode[sp_name].type

  -- se stava già seguendo qualcuno, lo rimuovo da questo
  if prev_spectated then
    if prev_type == "player" then
      players_spectated[prev_spectated][sp_name] = nil
    elseif prev_type == "entity" then
      entities_spectated[mod][arena_name][prev_spectated][sp_name] = nil
    else
      areas_spectated[mod][arena_name][prev_spectated][sp_name] = nil
    end
  end

  local target = ""

  if type == "player" then
    players_spectated[name][sp_name] = true
    target = minetest.get_player_by_name(name)

    spectator:set_attach(target, "", {x=0, y=-5, z=-20}, {x=0, y=0, z=0})
    spectator:set_hp(target:get_hp() > 0 and target:get_hp() or 1)

  elseif type == "entity" then
    entities_spectated[mod][arena_name][name][sp_name] = true
    target = entities_storage[mod][arena_name][name].object

    spectator:set_attach(target, "", {x=0, y=-5, z=-20}, {x=0, y=0, z=0})
    spectator:set_hp(target:get_hp() > 0 and target:get_hp() or 1)

  elseif type == "area" then
    areas_spectated[mod][arena_name][name][sp_name] = true
    target = areas_storage[mod][arena_name][name]

    spectator:set_attach(target, "", {x=0, y=-5, z=-20}, {x=0, y=0, z=0})
    spectator:set_hp(minetest.PLAYER_MAX_HP_DEFAULT)
  end

  players_in_spectate_mode[sp_name].spectating = name
  players_in_spectate_mode[sp_name].type = type

  spectator:get_meta():set_int("arenalib_watchID", i)
  arena_lib.HUD_send_msg("hotbar", sp_name, S("Currently spectating: @1", name))

  local mod_ref = arena_lib.mods[players_in_spectate_mode[sp_name].minigame]

  -- eventuale codice aggiuntivo
  if mod_ref.on_change_spectated_target then
    local arena = arena_lib.get_arena_by_player(sp_name)
    mod_ref.on_change_spectated_target(arena, sp_name, type, name, prev_type, prev_spectated, is_forced)
  end
end



function override_hotbar(player, mod, arena)
  player:get_inventory():set_list("main", {})
  player:get_inventory():set_list("craft",{})

  local mod_ref = arena_lib.mods[mod]
  local tools = {
    "arena_lib:spectate_changeplayer",      -- TODO: 6.0, with endless arenas I could have a situation where I have entities/areas to spectate but no players. Still hardcoded?
    "arena_lib:spectate_quit"
  }

  if #arena.teams > 1 then
    table.insert(tools, 2, "arena_lib:spectate_changeteam")
  end

  if arena.spectate_entities_amount > 0 then
    table.insert(tools, #tools, "arena_lib:spectate_changeentity")
  end

  if arena.spectate_areas_amount > 0 then
    table.insert(tools, #tools, "arena_lib:spectate_changearea")
  end

  if mod_ref.join_while_in_progress then
    table.insert(tools, #tools, "arena_lib:spectate_join")
  end

  player:hud_set_hotbar_image("arenalib_gui_hotbar" .. #tools .. ".png")
  player:hud_set_hotbar_itemcount(#tools)
  player:get_inventory():set_list("main", tools)
end
