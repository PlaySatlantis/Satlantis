local S = minetest.get_translator("arena_lib")

local function operations_before_entering_arena() end
local function operations_before_playing_arena() end
local function operations_before_leaving_arena() end
local function prejoin_checks_passed() end
local function on_join_callbacks() end
local function remove_attachments() end
local function restore_attachments() end
local function eliminate_player() end
local function handle_leaving_callbacks() end
local function victory_particles() end
local function show_victory_particles() end
local function time_loop() end

local matches = {}                    -- KEY: matchID, VALUE:   {(string) minigame, (int) arenaID}
local players_in_game = {}            -- KEY: p_name, VALUE:    {(string) minigame, (int) arenaID}
local players_kicked = {}             -- KEY: p_name, VALUE:    (float) timestamp
local players_temp_storage = {}       -- KEY: p_name, VALUE:    {(int) hotbar_slots, (string) hotbar_background_image, (string) hotbar_selected_image,
                                      --                        (table) player_aspect, (int) fov, (table) camera_offset, (table) armor_groups, (string) inventory_fs,
                                      --                        (table) attachments, (table) nametag, (table) celvault_sky, (table) celvault_sun, (table) celvault_moon,
                                      --                        (table) celvault_stars, (table) celvault_clouds, (int) weather_ID}


function arena_lib.load_arena(mod, arena_ID)
  local mod_ref = arena_lib.mods[mod]
  local arena = mod_ref.arenas[arena_ID]

  arena.in_game = true
  arena.in_loading = true
  arena.matchID = math.random(100000000, 999999999)
  arena_lib.entrances[arena.entrance_type].update(mod, arena)
  matches[arena.matchID] = {minigame = mod, arenaID = arena_ID}

  local shuffled_spawners = table.copy(arena.spawn_points)
  local count

  -- mescolo i punti e inizializzo il contatore per la rotazione
  if not arena.teams_enabled then
    table.shuffle(shuffled_spawners)
    count = 1
  else
    count = {}
    for i = 1, #arena.teams do
      table.shuffle(shuffled_spawners[i])
      count[i] = 1
    end
  end

  -- per ogni giocatorə...
  for pl_name, pl_data in pairs(arena.players) do
    operations_before_entering_arena(mod_ref, mod, arena, arena_ID, pl_name)

    -- teletrasporto
    if not arena.teams_enabled then
      minetest.get_player_by_name(pl_name):set_pos(shuffled_spawners[count])
      count = count == #shuffled_spawners and 1 or count + 1
    else
      local team_ID = pl_data.teamID
      minetest.get_player_by_name(pl_name):set_pos(shuffled_spawners[team_ID][count[team_ID]])
      count[team_ID] = count[team_ID] == #shuffled_spawners[team_ID] and 1 or count[team_ID] + 1
    end
  end

  -- se supporta la spettatore, inizializzo le varie tabelle
  if mod_ref.spectate_mode then
    arena.spectate_entities_amount = 0
    arena.spectate_areas_amount = 0
    arena_lib.init_spectate_containers(mod, arena.name)
  end

  -- aggiungo eventuali proprietà temporanee
  for temp_property, v in pairs(mod_ref.temp_properties) do
    if type(v) == "table" then
      arena[temp_property] = table.copy(v)
    else
      arena[temp_property] = v
    end
  end

  -- e aggiungo eventuali proprietà per ogni squadra
  if arena.teams_enabled then
    for i = 1, #arena.teams do
      for k, v in pairs(mod_ref.team_properties) do
        arena.teams[i][k] = v
      end
    end
  end

  -- eventuale codice aggiuntivo
  if mod_ref.on_load then
    mod_ref.on_load(arena)
  end

  for _, callback in ipairs(arena_lib.registered_on_load) do
    callback(mod, arena)
  end

  -- avvio la partita dopo tot secondi, se non è già stata avviata manualmente
  minetest.after(mod_ref.load_time, function()
    if not arena.in_loading then return end
    arena_lib.start_arena(mod, arena)
  end)
end



function arena_lib.start_arena(mod, arena)
  -- nel caso sia terminata durante la fase di caricamento
  if arena.in_celebration or not arena.in_game then return end

  -- se era già in corso
  if not arena.in_loading then
    minetest.log("error", debug.traceback("[" .. arena.name .. "] There has been an attempt to call the fighting phase whilst already in it. This shall not be done, aborting..."))
    return end

  arena.in_loading = false
  arena_lib.entrances[arena.entrance_type].update(mod, arena)

  local mod_ref = arena_lib.mods[mod]

  -- parte l'eventuale tempo
  if mod_ref.time_mode ~= "none" then
    arena.current_time = arena.initial_time

    minetest.after(1, function()
      time_loop(mod_ref, arena)
    end)
  end

  -- eventuale codice aggiuntivo
  if mod_ref.on_start then
    mod_ref.on_start(arena)
  end

  for _, callback in ipairs(arena_lib.registered_on_start) do
    callback(mod, arena)
  end
end



function arena_lib.join_arena(mod, p_name, arena_ID, as_spectator)
  local mod_ref = arena_lib.mods[mod]
  local arena = mod_ref.arenas[arena_ID]

  -- se non è in corso
  if not arena.in_game then
    arena_lib.print_error(p_name, S("No ongoing game!"))
    return end

  local players_join_data = {}  -- KEY: p_name; VALUE: {(bool) was_spectator}

  -- se prova a entrare come spettante
  if as_spectator then
    -- se non supporta la spettatore
    if not arena_lib.mods[mod].spectate_mode then
      arena_lib.print_error(p_name, S("Spectate mode not supported!"))
      return end

    -- se l'arena non è abilitata
    if not arena.enabled then
      arena_lib.print_error(p_name, S("The arena is not enabled!"))
      return end

    -- se si è attaccatɜ a qualcosa
    if minetest.get_player_by_name(p_name):get_attach() then
      arena_lib.print_error(p_name, S("You must detach yourself from the entity you're attached to before entering!"))
      return end

    -- se non c'è niente da seguire
    if arena.players_amount == 0 and not next(arena_lib.get_spectatable_entities(mod, arena.name)) and not next(arena_lib.get_spectatable_areas(mod, arena.name)) then
      arena_lib.print_error(p_name, S("There is nothing to spectate!"))
      return end

    -- controlli aggiuntivi e, se in coda, se può togliersi da questa
    if not prejoin_checks_passed(mod, mod_ref, arena, p_name, as_spectator) then return end

    players_join_data[p_name] = {}

    operations_before_entering_arena(mod_ref, mod, arena, arena_ID, p_name, true)
    on_join_callbacks(mod_ref, mod, arena, players_join_data, as_spectator)
    arena_lib.enter_spectate_mode(p_name, arena)
    arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#cfc6b8", ">>> " .. p_name .. " (" .. S("spectator") .. ")"))

  -- se entra come giocante
  else
    if not ARENA_LIB_JOIN_CHECKS_PASSED(mod, arena, p_name) then return end

    -- se sta caricando o sta finendo
    if arena.in_loading or arena.in_celebration then
      arena_lib.print_error(p_name, S("The arena is loading, try again in a few seconds!"))
      return end

    -- se è in corso e non permette l'entrata
    if not mod_ref.join_while_in_progress then
      arena_lib.print_error(p_name, S("This minigame doesn't allow to join while in progress!"))
      return end

    -- controlli aggiuntivi e, se in coda, se può togliersi da questa
    if not prejoin_checks_passed(mod, mod_ref, arena, p_name, as_spectator) then return end

    if mod_ref.sounds.join then
      for pl_name, _ in pairs(arena.players) do
        audio_lib.play_sound(mod_ref.sounds.join, {to_player = pl_name})
      end
    end

    local players = arena_lib.get_and_add_joining_players(arena, p_name) -- potrebbe essere un gruppo

    for _, pl_name in ipairs(players) do
      players_join_data[pl_name] = {}

      -- se stava in spettatore..
      if arena_lib.is_player_spectating(pl_name) then
        local pl_arena = arena_lib.get_arena_by_player(pl_name)
        local pl_mg = arena_lib.get_mod_by_player(pl_name)

        -- ..controllo se stava seguendo la stessa arena in cui si sta entrando (in caso di gruppo sparso in più parti)
        if pl_arena.name == arena.name and pl_mg == mod then
          players_join_data[pl_name].was_spectator = true
          arena_lib.leave_spectate_mode(pl_name)
          minetest.get_player_by_name(pl_name):get_inventory():set_list("main", {}) -- rimuovo gli oggetti della spettatore
          operations_before_playing_arena(mod_ref, arena, pl_name, true)
        else
          arena_lib.remove_player_from_arena(pl_name, 3)
          operations_before_entering_arena(mod_ref, mod, arena, arena_ID, pl_name)
        end

      -- sennò entra normalmente
      else
        operations_before_entering_arena(mod_ref, mod, arena, arena_ID, pl_name)
      end

      -- notifico e teletrasporto
      arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#c6f154", " >>> " .. pl_name))

      local teamID = arena.players[pl_name].teamID
      local random_spawner = arena_lib.get_random_spawner(arena, teamID)
      local player = minetest.get_player_by_name(pl_name)

      player:set_pos(random_spawner)

      -- TEMP: waiting for https://github.com/minetest/minetest/issues/12092 to be
      -- fixed. Forcing the teleport twice on two different steps. Necessary for
      -- whom was spectating
      minetest.after(0.1, function()
        player:set_pos(random_spawner)
      end)
    end

    -- richiami a parte perché, se ho gruppi, devo prima aspettare che tutti i membri
    -- vengano aggiunti ("for" precedente) onde evitare che, al richiamare un on_join,
    -- non esploda (es. accedendo alle proprietà di tuttɜ lɜ giocanti, quando è
    -- statə caricatə solo lə primə)
    on_join_callbacks(mod_ref, mod, arena, players_join_data, as_spectator)
  end

  arena_lib.entrances[arena.entrance_type].update(mod, arena)
end



-- a partita finita
-- `winners` può essere stringa (giocatore singolo), intero (squadra) o tabella di uno di questi (più giocatori o squadre)
function arena_lib.load_celebration(mod, arena, winners)

  -- se era già in celebrazione
  if arena.in_celebration then
    minetest.log("error", debug.traceback("[" .. mod .. "] There has been an attempt to call the celebration phase whilst already in it. This shall not be done, aborting..."))
    return end

  local mod_ref = arena_lib.mods[mod]

  if mod_ref.endless then
    minetest.log("error", debug.traceback("[" .. mod .. "] There has been an attempt to call the celebration phase for an endless minigame, aborting..."))
    return end

  arena.in_celebration = true
  arena_lib.entrances[arena.entrance_type].update(mod, arena)

  -- ripristino HP e visibilità nome di ogni giocatore
  for pl_name, stats in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    player:set_nametag_attributes({text = pl_name, color = {a = 255, r = 255, g = 255, b = 255}})
  end

  local winners_type = type(winners)
  local winning_message = ""

  -- determino il messaggio da inviare
  -- se è una tabella con più voci, può essere o più giocatori singoli, o più squadre
  if winners_type == "table" and #winners > 1 then
    if type(winners[1]) == "string" then
      for _, pl_name in pairs(winners) do
        winning_message = winning_message .. pl_name .. ", "
      end
      local mod_S = mod_ref.custom_messages.celebration_more_players and minetest.get_translator(mod) or S
      winning_message = mod_S(mod_ref.messages.celebration_more_players, winning_message:sub(1, -3))

    else
      for _, team_ID in pairs(winners) do
        winning_message = winning_message .. arena.teams[team_ID].name .. ", "
      end
      local mod_S = mod_ref.custom_messages.celebration_more_teams and minetest.get_translator(mod) or S
      winning_message = mod_S(mod_ref.messages.celebration_more_teams, winning_message:sub(1, -3))
    end

  -- nessunə
  elseif winners == nil or (winners_type == "table" and not next(winners)) then
    local mod_S = mod_ref.custom_messages.celebration_nobody and minetest.get_translator(mod) or S
    winning_message = mod_S(mod_ref.messages.celebration_nobody)

  -- giocatorə singolə
  elseif winners_type == "string" or (winners_type == "table" and type(winners[1]) == "string") then
    local mod_S = mod_ref.custom_messages.celebration_one_player and minetest.get_translator(mod) or S
    local winners_str = winners_type == "string" and winners or winners[1]
    winning_message = mod_S(mod_ref.messages.celebration_one_player, winners_str)

  -- squadra
  elseif winners_type == "number" or (winners_type == "table" and type(winners[1]) == "number") then
    local mod_S = mod_ref.custom_messages.celebration_one_team and minetest.get_translator(mod) or S
    local winners_int = winners_type == "number" and winners or winners[1]
    winning_message = mod_S(mod_ref.messages.celebration_one_team, arena.teams[winners_int].name)
  end

  arena_lib.HUD_send_msg_all("title", arena, winning_message, mod_ref.celebration_time)
  arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#cfc6b8", "> " .. S("Players and spectators can now interact with each other")))

  -- eventuale codice aggiuntivo
  if mod_ref.on_celebration then
    mod_ref.on_celebration(arena, winners)
  end

  for _, callback in ipairs(arena_lib.registered_on_celebration) do
    callback(mod, arena, winners)
  end

  -- l'arena finisce dopo tot secondi, a meno che non sia stata terminata forzatamente nel mentre
  minetest.after(mod_ref.celebration_time, function()
    if not arena.in_game then return end
    arena_lib.end_arena(mod_ref, mod, arena, winners)
  end)
end



function arena_lib.end_arena(mod_ref, mod, arena, winners, is_forced)
  -- copia da passare ai richiami
  local arena_copy = table.copy(arena)

  -- rimozione spettatori
  for sp_name, sp_stats in pairs(arena.spectators) do
    arena_lib.leave_spectate_mode(sp_name)
    players_in_game[sp_name] = nil

    operations_before_leaving_arena(mod_ref, arena, sp_name)
  end

  -- rimozione giocatori
  for pl_name, stats in pairs(arena.players) do
    arena.players[pl_name] = nil
    players_in_game[pl_name] = nil

    operations_before_leaving_arena(mod_ref, arena, pl_name)
  end

  -- dealloca eventuale modalità spettatore
  if mod_ref.spectate_mode then
    arena.spectate_entities_amount = nil
    arena.spectate_areas_amount = nil
    arena_lib.unload_spectate_containers(mod, arena.name)
  end

  -- azzerramento giocatori e spettatori
  arena.past_present_players = {}
  arena.players_and_spectators = {}
  arena.past_present_players_inside = {}

  arena.players_amount = 0
  if arena.teams_enabled then
    for i = 1, #arena.teams do
      arena.players_amount_per_team[i] = 0
      if mod_ref.spectate_mode then
        arena.spectators_amount_per_team[i] = 0
      end
    end
  end

  -- azzero il timer
  arena.current_time = nil

  victory_particles(arena, arena_copy.players, winners)

  -- rimuovo eventuali proprietà temporanee
  for temp_property, v in pairs(mod_ref.temp_properties) do
    arena[temp_property] = nil
  end

  -- e quelle eventuali di squadra
  if arena.teams_enabled then
    for i = 1, #arena.teams do
      for t_property, _ in pairs(mod_ref.team_properties) do
        arena.teams[i][t_property] = nil
      end
    end
  end

  arena_lib.reset_map(mod, arena)

  matches[arena.matchID] = nil
  arena.matchID = nil
  arena.in_loading = false                                                      -- nel caso venga forzata mentre sta caricando, sennò rimane a caricare all'infinito
  arena.in_celebration = false
  arena.in_game = false

  arena_lib.entrances[arena.entrance_type].update(mod, arena)

  -- eventuale codice aggiuntivo
  if mod_ref.on_end then
    mod_ref.on_end(arena_copy, winners, is_forced)
  end

  for _, callback in ipairs(arena_lib.registered_on_end) do
    callback(mod, arena_copy, winners, is_forced)
  end
end





----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

-- mod è opzionale
function arena_lib.is_player_in_arena(p_name, mod)
  if not players_in_game[p_name] then
    return false
  else
    -- se il campo mod è specificato, controllo che sia lo stesso
    if mod ~= nil then
      if players_in_game[p_name].minigame == mod then return true
      else return false
      end
    end

    return true
  end
end



function arena_lib.is_player_playing(p_name, mod)
  return arena_lib.is_player_in_arena(p_name, mod) and not arena_lib.is_player_spectating(p_name)
end



function arena_lib.has_player_been_kicked(p_name)
  local kicked = players_kicked[p_name] ~= nil
  local time_left = kicked and os.difftime(players_kicked[p_name] + 120, os.time())

  return players_kicked[p_name] ~= nil, time_left
end



function arena_lib.remove_player_from_arena(p_name, reason, xc_name, elim_msg)
  -- reason 0 = has disconnected
  -- reason 1 = has been eliminated
  -- reason 2 = has been kicked
  -- reason 3 = has quit the arena
  assert(reason, "[ARENA_LIB] 'remove_player_from_arena': A reason must be specified!")

  -- se lə giocatorə non è in partita, annullo
  if not arena_lib.is_player_in_arena(p_name) then return end

  local mod = arena_lib.get_mod_by_player(p_name)
  local mod_ref = arena_lib.mods[mod]
  local arena = arena_lib.get_arena_by_player(p_name)
  local p_properties -- copia da passare ai richiami

  -- se lə giocatorə era in spettatore
  if mod_ref.spectate_mode and arena_lib.is_player_spectating(p_name) then
    p_properties = table.copy(arena.spectators[p_name])
    arena_lib.leave_spectate_mode(p_name)
    operations_before_leaving_arena(mod_ref, arena, p_name, reason)
    arena.players_and_spectators[p_name] = nil
    arena.past_present_players_inside[p_name] = nil
    players_in_game[p_name] = nil

    handle_leaving_callbacks(mod, arena, p_name, p_properties, reason, xc_name, elim_msg, true)

  -- sennò...
  else
    -- non eliminare se si è in celebrazione
    if arena.in_celebration and reason == 1 then return end

    p_properties = table.copy(arena.players[p_name])

    -- rimuovo
    arena.players_amount = arena.players_amount - 1
    if arena.teams_enabled then
      local p_team_ID = arena.players[p_name].teamID
      arena.players_amount_per_team[p_team_ID] = arena.players_amount_per_team[p_team_ID] - 1
    end
    arena.players[p_name] = nil

    -- se ha abbandonato mentre aveva degli spettatori, li riassegno
    if arena_lib.is_player_spectated(p_name) then
      for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
        if reason == 1 and xc_name and minetest.get_player_by_name(xc_name) and sp_name ~= xc_name then -- sp_name ~= xc_name in caso si uccidano più o meno nello stesso istante
          arena_lib.spectate_target(mod, arena, sp_name, "player", xc_name)
        else
          arena_lib.find_and_spectate_player(sp_name)
        end
      end
    end

    -- se è stato eliminato e c'è la spettatore, non va rimosso, bensì solo spostato in spettatore
    if reason == 1 and mod_ref.spectate_mode and arena.players_amount > 0 then
      eliminate_player(mod, arena, p_name, xc_name, p_properties, elim_msg)
      arena_lib.enter_spectate_mode(p_name, arena, xc_name)

    -- sennò procedo a rimuoverlo normalmente
    else
      operations_before_leaving_arena(mod_ref, arena, p_name, reason)
      arena.players_and_spectators[p_name] = nil
      arena.past_present_players_inside[p_name] = nil
      players_in_game[p_name] = nil

      handle_leaving_callbacks(mod, arena, p_name, p_properties, reason, xc_name, elim_msg)
    end

    -- se è un minigioco infinito o l'arena è già in celebrazione, basta solo aggiornare il cartello
    if not mod_ref.endless and not arena.in_celebration then
      -- se l'ultimə rimastə abbandona, vai in celebrazione
      if arena.players_amount == 0 then
        arena_lib.load_celebration(mod, arena)

      elseif mod_ref.end_when_too_few then
        -- se l'arena è a squadre e sono rimasti solo lɜ giocatorɜ di una squadra, la loro squadra vince
        if arena.teams_enabled and #arena_lib.get_active_teams(arena) == 1 then
          local winning_team_id = arena_lib.get_active_teams(arena)[1]
          local mod_S = mod_ref.custom_messages.last_standing_team and minetest.get_translator(mod) or S

          arena_lib.send_message_in_arena(arena, "players", mod_ref.prefix .. mod_S(mod_ref.messages.last_standing_team))
          arena_lib.load_celebration(mod, arena, winning_team_id)

        -- se invece erano rimastɜ solo 2 giocatorɜ in partita, l'altrə vince
        elseif arena.players_amount == 1 then
          local mod_S = mod_ref.custom_messages.last_standing and minetest.get_translator(mod) or S
          arena_lib.send_message_in_arena(arena, "players", mod_ref.prefix .. S(mod_ref.messages.last_standing))

          for pl_name, stats in pairs(arena.players) do
            arena_lib.load_celebration(mod, arena, pl_name)
          end
        end
      end
    end
  end

  arena_lib.entrances[arena.entrance_type].update(mod, arena)
end



function arena_lib.force_start(sender, mod, arena)
  local mod_ref = arena_lib.mods[mod]

  -- se il minigioco non esiste
  if not mod_ref then
    arena_lib.print_error(sender, S("This minigame doesn't exist!"))
    return end

  -- se l'arena non esiste
  if not arena then
    arena_lib.print_error(sender, S("This arena doesn't exist!"))
    return end

  -- se non è né in coda né in partita
  if not arena.in_queue and not arena.in_game then
    arena_lib.print_error(sender, S("Can't force a game to start if the arena is not even in queue!"))
    return end

  -- se la partita è già in corso
  if arena.in_game and not arena.in_loading then
    arena_lib.print_error(sender, S("You can't perform this action during an ongoing game!"))
    return end

  if arena.in_queue then
    arena_lib.queue_to_arena(mod, arena)
  else
    arena_lib.start_arena(mod, arena)
  end

  arena_lib.print_info(sender, S("Game start in arena @1 successfully forced", arena.name))
end



function arena_lib.force_end(sender, mod, arena)
  local mod_ref = arena_lib.mods[mod]

  -- se il minigioco non esiste
  if not mod_ref then
    arena_lib.print_error(sender, S("This minigame doesn't exist!"))
    return end

  -- se l'arena non esiste
  if not arena then
    arena_lib.print_error(sender, S("This arena doesn't exist!"))
    return end

  -- se l'arena non è in partita
  if not arena.in_game then
    arena_lib.print_error(sender, S("No ongoing game!"))
    return end

  arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#d69298", S("The arena has been forcibly terminated by @1", sender)))
  arena_lib.end_arena(mod_ref, mod, arena, nil, true)

  arena_lib.print_info(sender, S("Game in arena @1 successfully terminated", arena.name))

  -- se è in modalità infinita, disabilito. Se qualche controllo personalizzato
  -- dovesse ritornare `false`, impedendone la disabilitazione, rifaccio andare l'arena
  if mod_ref.endless then
    local can_disable = arena_lib.disable_arena(sender, mod, arena.name)

    if not can_disable then
      local id = arena_lib.get_arena_by_name(mod, arena.name)
      arena_lib.load_arena(mod, id)
    end
  end
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function arena_lib.get_mod_by_player(p_name)
  if arena_lib.is_player_in_arena(p_name) then
    return players_in_game[p_name].minigame
  elseif arena_lib.is_player_in_queue(p_name) then
    return arena_lib.get_mod_by_queuing_player(p_name)
  end
end



function arena_lib.get_arena_by_player(p_name)
  if arena_lib.is_player_in_arena(p_name) then      -- è in partita
    local mod = players_in_game[p_name].minigame
    local arenaID = players_in_game[p_name].arenaID

    return arena_lib.mods[mod].arenas[arenaID]
  elseif arena_lib.is_player_in_queue(p_name) then   -- è in coda
    return arena_lib.get_arena_by_queuing_player(p_name)
  end
end



function arena_lib.get_arenaID_by_player(p_name)
  if players_in_game[p_name] then                   -- è in partita
    return players_in_game[p_name].arenaID

  elseif arena_lib.is_player_in_queue(p_name) then   -- è in coda
    return arena_lib.get_arenaID_by_queuing_player(p_name)
  end
end



function arena_lib.get_mod_by_matchID(matchID)
  if not matches[matchID] then return end

  return matches[matchID].minigame
end



function arena_lib.get_arena_by_matchID(matchID)
  if not matches[matchID] then return end

  local match = matches[matchID]
  local id = match.arenaID

  return id, arena_lib.mods[match.minigame].arenas[id]
end



function arena_lib.get_players_in_game()
  local players = {}

  for pl_name, _ in pairs(players_in_game) do
    table.insert(players, pl_name)
  end

  return players
end



function arena_lib.get_players_in_minigame(mod, to_player)
  local players_in_minigame = {}

  if to_player then
    for pl_name, info in pairs(players_in_game) do
      if mod == info.minigame then
        table.insert(players_in_minigame, minetest.get_player_by_name(pl_name))
      end
    end
  else
    for pl_name, info in pairs(players_in_game) do
      if mod == info.minigame then
        table.insert(players_in_minigame, pl_name)
      end
    end
  end

  return players_in_minigame
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function operations_before_entering_arena(mod_ref, mod, arena, arena_ID, p_name, as_spectator)
  players_temp_storage[p_name] = {}

  -- applico eventuale musica di sottofondo
  if arena.bgm then
    audio_lib.play_bgm(p_name, arena.bgm.track)
  end

  local player = minetest.get_player_by_name(p_name)

  -- cambio eventuale illuminazione
  if arena.lighting then
    local lighting = arena.lighting

    players_temp_storage[p_name].lighting = {
      light   = player:get_day_night_ratio(),
      shaders = player:get_lighting()
    }

    if lighting.light then
      player:override_day_night_ratio(lighting.light)
    end

    if lighting.shaders then
      player:set_lighting(lighting.shaders)
    end
  end

  -- cambio eventuale volta celeste
  if arena.celestial_vault then
    local celvault = arena.celestial_vault

    if celvault.sky then
      players_temp_storage[p_name].celvault_sky = player:get_sky(true)
      player:set_sky(celvault.sky)
    end

    if celvault.sun then
      players_temp_storage[p_name].celvault_sun = player:get_sun()
      player:set_sun(celvault.sun)
    end

    if celvault.moon then
      players_temp_storage[p_name].celvault_moon = player:get_moon()
      player:set_moon(celvault.moon)
    end

    if celvault.stars then
      players_temp_storage[p_name].celvault_stars = player:get_stars()
      player:set_stars(celvault.stars)
    end

    if celvault.clouds then
      players_temp_storage[p_name].celvault_clouds = player:get_clouds()
      player:set_clouds(celvault.clouds)
    end
  end

  -- cambio eventuale effetto
  if arena.weather then
    local particles = table.copy(arena.weather)

    particles.playername = p_name
    particles.attached = player
    players_temp_storage[p_name].weather_ID = minetest.add_particlespawner(particles)
  end

  -- salvo la targhetta ed eventualmente la nascondo
  players_temp_storage[p_name].nametag = player:get_nametag_attributes()

  if not mod_ref.show_nametags then
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
  end

  -- disattivo eventualmente certe interfacce
  if next(mod_ref.hud_flags) then
    players_temp_storage[p_name].hud_flags = player:hud_get_flags()
    player:hud_set_flags(mod_ref.hud_flags)
  end

  -- chiudo eventuali formspec
  minetest.close_formspec(p_name, "")

  -- svuoto eventualmente l'inventario, decidendo se e come salvarlo
  if not mod_ref.keep_inventory then
    arena_lib.store_inventory(player)
  end

  -- salvo la hotbar se c'è la spettatore o la hotbar personalizzata
  if mod_ref.spectate_mode or mod_ref.hotbar then
    players_temp_storage[p_name].hotbar_slots = player:hud_get_hotbar_itemcount()
    players_temp_storage[p_name].hotbar_background_image = player:hud_get_hotbar_image()
    players_temp_storage[p_name].hotbar_selected_image = player:hud_get_hotbar_selected_image()
  end

  -- sgancio eventuali giocatorɜ figlɜ
  for _, child in pairs(player:get_children()) do
    if child:is_player() then
      child:set_detach()
    end
  end

  -- sgancio/mantengo eventuali entità figlie
  if not mod_ref.keep_attachments and next(player:get_children()) then
    players_temp_storage[p_name].attachments = {}
    remove_attachments(p_name, player)
  end

  if not as_spectator then
    operations_before_playing_arena(mod_ref, arena, p_name)
  end

  -- registro giocatori nella tabella apposita
  players_in_game[p_name] = {minigame = mod, arenaID = arena_ID}
end



function operations_before_playing_arena(mod_ref, arena, p_name)
  arena.past_present_players[p_name] = true
  arena.past_present_players_inside[p_name] = true

  -- aggiungo eventuale contenitore mod spettatore
  if mod_ref.spectate_mode then
    arena_lib.add_spectate_p_container(p_name)
  end

  local player = minetest.get_player_by_name(p_name)

  -- applico eventuale fov
  if mod_ref.fov then
    players_temp_storage[p_name].fov = player:get_fov()
    player:set_fov(mod_ref.fov)
  end

  -- applico eventuale scostamento camera
  if mod_ref.camera_offset then
    players_temp_storage[p_name].camera_offset = {player:get_eye_offset()}
    player:set_eye_offset(mod_ref.camera_offset[1], mod_ref.camera_offset[2])
  end

  -- cambio eventuale aspetto
  if mod_ref.player_aspect then
    local p_prps = player:get_properties()
    local aspect = mod_ref.player_aspect
    players_temp_storage[p_name].player_aspect = {
      visual = p_prps.visual, mesh = p_prps.mesh, textures = p_prps.textures, visual_size = p_prps.visual_size, collisionbox = p_prps.collisionbox, selectionbox = p_prps.selectionbox
    }
    player:set_properties({
      visual = aspect.visual, mesh = aspect.mesh, textures = aspect.textures, visual_size = aspect.visual_size, collisionbox = aspect.collisionbox, selectionbox = aspect.selectionbox
    })
  end

  -- cambio eventuale colore texture (richiede le squadre)
  if arena.teams_enabled and mod_ref.teams_color_overlay then
    if not players_temp_storage[p_name].player_aspect then -- salvo texture in player_aspect per non creare un ulteriore parametro
      players_temp_storage[p_name].player_aspect = {}
    end

    local textures = player:get_properties().textures
    local team_col = mod_ref.teams_color_overlay[arena.players[p_name].teamID]

    for k, v in ipairs(textures) do
      textures[k] = v .. "^[colorize:" .. team_col .. ":85"
    end

    players_temp_storage[p_name].player_aspect.textures = player:get_properties().textures
    player:set_properties({ textures = textures })
  end

  -- disabilito eventualmente l'inventario
  if mod_ref.disable_inventory then
    players_temp_storage[p_name].inventory_fs = player:get_inventory_formspec()
    player:set_inventory_formspec("")
  end

  -- cambio l'eventuale hotbar
  if mod_ref.hotbar then
    local hotbar = mod_ref.hotbar

    if hotbar.slots then
      player:hud_set_hotbar_itemcount(hotbar.slots)
    end

    if hotbar.background_image then
      player:hud_set_hotbar_image(hotbar.background_image)
    end

    if hotbar.selected_image then
      player:hud_set_hotbar_selected_image(hotbar.selected_image)
    end
  end

  -- imposto eventuale fisica personalizzata
  if mod_ref.in_game_physics then
    player:set_physics_override(mod_ref.in_game_physics)
  end

  -- li sgancio da eventuali entità (non lo faccio agli spettatori perché sono già
  -- agganciati al giocatore, sennò cadono nel vuoto)
  player:set_detach()

  -- eventuali modificatori di danno
  if next(mod_ref.damage_modifiers) then
    players_temp_storage[p_name].armor_groups = player:get_armor_groups()

    local armor_groups = player:get_armor_groups()

    for k, v in pairs(mod_ref.damage_modifiers) do
      armor_groups[k] = v
    end

    player:set_armor_groups(armor_groups)
  end

  -- se il danno da caduta è disabilitato, disattivo il flash all'impatto
  if table.indexof(mod_ref.disabled_damage_types, "fall") > 0 then
    -- potrebber esser stato creato con damage_modifiers
    if not players_temp_storage[p_name].armor_groups then
      players_temp_storage[p_name].armor_groups = player:get_armor_groups()
    end

    local armor_groups = player:get_armor_groups()

    armor_groups.fall_damage_add_percent = -100
    player:set_armor_groups(armor_groups)
  end

  -- li curo
  player:set_hp(minetest.PLAYER_MAX_HP_DEFAULT)

  -- assegno eventuali proprietà giocatori
  for k, v in pairs(mod_ref.player_properties) do
    if type(v) == "table" then
      arena.players[p_name][k] = table.copy(v)
    else
      arena.players[p_name][k] = v
    end
  end
end



-- `reason` parametro opzionale che passo solo quando potrebbe essersi disconnesso
function operations_before_leaving_arena(mod_ref, arena, p_name, reason)
  -- disattivo eventuale musica di sottofondo
  if arena.bgm then
    audio_lib.stop_bgm(p_name)
  end

  local player = minetest.get_player_by_name(p_name)

  -- reimposto eventuale illuminazione
  if arena.lighting then
    player:override_day_night_ratio(players_temp_storage[p_name].lighting.light)
    player:set_lighting(players_temp_storage[p_name].lighting.shaders)
  end

  -- reimposto eventuale volta celeste
  if arena.celestial_vault then
    local celvault = arena.celestial_vault

    if celvault.sky then
      player:set_sky(players_temp_storage[p_name].celvault_sky)
    end
    if celvault.sun then
      player:set_sun(players_temp_storage[p_name].celvault_sun)
    end
    if celvault.moon then
      player:set_moon(players_temp_storage[p_name].celvault_moon)
    end
    if celvault.stars then
      player:set_stars(players_temp_storage[p_name].celvault_stars)
    end
    if celvault.clouds then
      player:set_clouds(players_temp_storage[p_name].celvault_clouds)
    end
  end

  -- rimuovo eventuale effetto meteo
  if arena.weather then
    minetest.delete_particlespawner(players_temp_storage[p_name].weather_ID)
  end

  -- svuoto eventualmente l'inventario e ripristino gli oggetti
  if not mod_ref.keep_inventory then
    player:get_inventory():set_list("main", {})
    player:get_inventory():set_list("craft",{})

    arena_lib.restore_inventory(p_name)
  end

  local armor_groups = players_temp_storage[p_name].armor_groups

  -- riassegno eventuali gruppi armatura (per modificatori danno e flash da impatto caduta)
  if armor_groups then
    player:set_armor_groups(armor_groups)
  end

  -- sgancio da eventuali entità
  player:set_detach()

  -- ripristino eventuali entità figlie
  if not mod_ref.keep_attachments then
    local attachments = players_temp_storage[p_name].attachments or {}
    for i, data in pairs(attachments) do
      restore_attachments(p_name, player, i)
    end
  end

  -- ripristino gli HP
  player:set_hp(minetest.PLAYER_MAX_HP_DEFAULT)

  -- teletrasporto con un po' di rumore
  local clean_pos = arena.custom_return_point or mod_ref.settings.return_point
  local noise_x = math.random(-1.5, 1.5)
  local noise_z = math.random(-1.5, 1.5)
  local noise_pos = {x = clean_pos.x + noise_x, y = clean_pos.y, z = clean_pos.z + noise_z}
  player:set_pos(noise_pos)
  -- TEMP: waiting for https://github.com/minetest/minetest/issues/12092 to be fixed. Forcing the teleport twice on two different steps
  minetest.after(0.1, function()
    if not minetest.get_player_by_name(p_name) then return end
    player:set_pos(noise_pos)
  end)

  -- se si è disconnesso, salta il resto
  if reason == 0 then
    players_temp_storage[p_name] = nil
    return
  end

  -- se ha partecipato come giocatore
  if arena.past_present_players_inside[p_name] then

    -- rimuovo eventuale contenitore mod spettatore
    if mod_ref.spectate_mode then
      arena_lib.remove_spectate_p_container(p_name)
    end

    -- ripristino eventuali texture
    if arena.teams_enabled and mod_ref.teams_color_overlay then
      player:set_properties({
        textures = players_temp_storage[p_name].player_aspect.textures
      })
    end

    -- riprsitino eventuale aspetto
    if mod_ref.player_aspect then
      local aspect = players_temp_storage[p_name].player_aspect
      player:set_properties({
        visual = aspect.visual, mesh = aspect.mesh, textures = aspect.textures, visual_size = aspect.visual_size, collisionbox = aspect.collisionbox, selectionbox = aspect.selectionbox
      })
    end

    -- ripristino eventuale fov
    if mod_ref.fov then
      player:set_fov(players_temp_storage[p_name].fov)
    end

    -- riabilito eventualmente l'inventario
    if mod_ref.disable_inventory then
      player:set_inventory_formspec(players_temp_storage[p_name].inventory_fs)
    end

    -- ripristino eventuale camera
    if mod_ref.camera_offset then
      player:set_eye_offset(players_temp_storage[p_name].camera_offset[1], players_temp_storage[p_name].camera_offset[2])
    end
  end

  -- se c'è la spettatore o l'hotbar personalizzata, la ripristino
  if mod_ref.spectate_mode or mod_ref.hotbar then
    player:hud_set_hotbar_itemcount(players_temp_storage[p_name].hotbar_slots)
    player:hud_set_hotbar_image(players_temp_storage[p_name].hotbar_background_image)
    player:hud_set_hotbar_selected_image(players_temp_storage[p_name].hotbar_selected_image)
  end

  -- se ho Hub, restituisco gli oggetti e imposto fisica della lobby
  if minetest.get_modpath("hub_core") then
    hub.set_items(player)
    hub.set_hub_physics(player)
  else
    player:set_physics_override(arena_lib.SERVER_PHYSICS)
  end

  -- riattivo le interfacce eventualmente disattivate
  if next(mod_ref.hud_flags) then
    player:hud_set_flags(players_temp_storage[p_name].hud_flags)
  end

  -- ripristino nomi
  player:set_nametag_attributes(players_temp_storage[p_name].nametag)

  -- faccio saprire eventuali HUD
  arena_lib.HUD_hide("all", p_name)

  -- svuoto lo spazio d'archiviazione temporaneo
  players_temp_storage[p_name] = nil
end



function prejoin_checks_passed(mod, mod_ref, arena, p_name, as_spectator)
  -- controlli aggiuntivi
  if mod_ref.on_prejoin then
    if not mod_ref.on_prejoin(arena, p_name, as_spectator) then return end
  end

  for _, callback in ipairs(arena_lib.registered_on_prejoin) do
    if not callback(mod, arena, p_name, as_spectator) then return end
  end

  -- se si era in coda
  if arena_lib.is_player_in_queue(p_name) then
    if not arena_lib.remove_player_from_queue(p_name) then return end
  end

  return true
end



function on_join_callbacks(mod_ref, mod, arena, p_names, as_spectator)
  for pl_name, pl_data in pairs(p_names) do
    local was_spectator = pl_data.was_spectator

    if mod_ref.on_join then
      mod_ref.on_join(pl_name, arena, as_spectator, was_spectator)
    end

    for _, callback in ipairs(arena_lib.registered_on_join) do
      callback(mod, arena, pl_name, as_spectator, was_spectator)
    end
  end
end



function remove_attachments(p_name, entity, parent_idx)
  for i, child in pairs(entity:get_children()) do
    -- `get_luaentity` ritorna solo i parametri extra, che salvo in `params`
    -- per mantenerli invariati a ricreare l'entità
    local luaentity = child:get_luaentity()
    local params = {}

    -- TEMP: entities aren't always removed, creating some sort of empty shell that
    -- can't even be deleted with `:remove()`. This is a MT issue, so the only thing
    -- I can do is skip these hollow entities (they only answer to `get_hp` and `is_player`).
    -- Probably due to https://github.com/minetest/minetest/issues/12092
    if luaentity then

      -- salvo l'entità solo se è fatta per essere salvata staticamente, sennò
      -- la rimuovo e basta
      if luaentity.initial_properties.static_save then
        for param, v in pairs(luaentity) do
          if param ~= "object" then
            params[param] = v
          end
        end

        -- uso `children_amount` per capire quante volte ciclare in `restore_attachments`
        -- la generazione successiva, in quanto questa verrà salvata subito dopo
        -- l'ID dell'entità genitrice (p -> e1 -> ee1 -> ee2 -> e2 -> e3)
        local children_amount = 0
        for j, grandchild in pairs(child:get_children()) do
          if not grandchild:is_player() then
            children_amount = children_amount + 1
          end
        end

        local staticdata = luaentity.get_staticdata and luaentity:get_staticdata() or nil
        local _, bone, position, rotation, forced_visible = child:get_attach()
        local attachment_info = {
          entity = {name = luaentity.name, staticdata = staticdata, children_amount = children_amount, params = params},
          properties = {bone = bone, position = position, rotation = rotation, forced_visible = forced_visible}
        }

        table.insert(players_temp_storage[p_name].attachments, attachment_info)

        -- in caso l'entità avesse a sua volta entità attaccate, rimuovo anche queste
        remove_attachments(p_name, child, i)
      end

      child:remove()
    end
  end
end



function restore_attachments(p_name, parent, i)
  local data = players_temp_storage[p_name].attachments[i]
  local child = minetest.add_entity(parent:get_pos(), data.entity.name, data.entity.staticdata)

  if child then
    local entity = child:get_luaentity()
    local properties = data.properties

    for k, v in pairs(data.entity.params) do
      entity.k = v
    end

    child:set_attach(parent, properties.bone, properties.position, properties.rotation, properties.forced_visible)

    for j = 1, data.entity.children_amount do
      if players_temp_storage[p_name].attachments[j+i] then
        restore_attachments(p_name, child, j + i)
      end
    end
  end

  -- evita di iterare le entità dalla 2° generazione in poi nel for di keep_attachments
  players_temp_storage[p_name].attachments[i] = nil
end



function eliminate_player(mod, arena, p_name, xc_name, p_properties, elim_msg)
  local mod_ref = arena_lib.mods[mod]

  if elim_msg then
    arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#f16a54", "<<< " .. elim_msg))
  else
    if xc_name then
      local mod_S = mod_ref.custom_messages.eliminated_by and minetest.get_translator(mod) or S
      arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#f16a54", "<<< " .. mod_S(mod_ref.messages.eliminated_by, p_name, xc_name)))
    else
      local mod_S = mod_ref.custom_messages.eliminated and minetest.get_translator(mod) or S
      arena_lib.send_message_in_arena(arena, "both", minetest.colorize("#f16a54", "<<< " .. mod_S(mod_ref.messages.eliminated, p_name)))
    end
  end

  if mod_ref.sounds.eliminate then
    for pl_name, _ in pairs(arena.players) do
      audio_lib.play_sound(mod_ref.sounds.eliminate, {to_player = pl_name})
    end
  end

  if mod_ref.on_eliminate then
    mod_ref.on_eliminate(arena, p_name, xc_name, p_properties)
  end

  for _, callback in ipairs(arena_lib.registered_on_eliminate) do
    callback(mod, arena, p_name, xc_name, p_properties)
  end
end



function handle_leaving_callbacks(mod, arena, p_name, p_properties, reason, xc_name, elim_msg, is_spectator)
  local msg_color = reason < 3 and "#f16a54" or "#d69298"
  local spect_str = ""

  if is_spectator then
    msg_color = "#cfc6b8"
    spect_str = " (" .. S("spectator") .. ")"
  end

  local mod_ref = arena_lib.mods[mod]

  -- se si è disconnesso
  if reason == 0 then
    arena_lib.send_message_in_arena(arena, "both", minetest.colorize(msg_color, "<<< " .. p_name .. spect_str))

    if not is_spectator and mod_ref.sounds.disconnect then
      for pl_name, _ in pairs(arena.players) do
        audio_lib.play_sound(mod_ref.sounds.disconnect, {to_player = pl_name})
      end
    end

  -- se è stato eliminato (no spettatore, quindi viene rimosso dall'arena)
  elseif reason == 1 then
    eliminate_player(mod, arena, p_name, xc_name, p_properties, elim_msg)

  -- se è stato cacciato
  elseif reason == 2 then
    if xc_name then
      arena_lib.send_message_in_arena(arena, "both", minetest.colorize(msg_color, "<<< " .. S("@1 has been kicked by @2", p_name, xc_name) .. spect_str))
    else
      arena_lib.send_message_in_arena(arena, "both", minetest.colorize(msg_color, "<<< " .. S("@1 has been kicked", p_name) .. spect_str))
    end

    if not is_spectator and mod_ref.sounds.kick then
      for pl_name, _ in pairs(arena.players) do
        audio_lib.play_sound(mod_ref.sounds.kick, {to_player = pl_name})
      end
    end

    players_kicked[p_name] = os.time()
    minetest.after(120, function() players_kicked[p_name] = nil end)

  -- se ha abbandonato
  elseif reason == 3 then
    local mod_S = mod_ref.custom_messages.quit and minetest.get_translator(mod) or S
    arena_lib.send_message_in_arena(arena, "both", minetest.colorize(msg_color, "<<< " .. mod_S(mod_ref.messages.quit, p_name) .. spect_str))

    if not is_spectator and mod_ref.sounds.quit then
      for pl_name, _ in pairs(arena.players) do
        audio_lib.play_sound(mod_ref.sounds.quit, {to_player = pl_name})
      end
    end
  end

  if mod_ref.on_quit then
    mod_ref.on_quit(arena, p_name, is_spectator, reason, p_properties)
  end

  for _, callback in ipairs(arena_lib.registered_on_quit) do
    callback(mod, arena, p_name, is_spectator, reason, p_properties)
  end
end



function victory_particles(arena, players, winners)
  -- singolo giocatore
  if type(winners) == "string" then
    local winner = minetest.get_player_by_name(winners)

    if winner then
      show_victory_particles(winner:get_pos())
    end

  -- singola squadra
  elseif type(winners) == "number" then
    for pl_name, pl_stats in pairs(players) do
      if pl_stats.teamID == winners then
        local winner = minetest.get_player_by_name(pl_name)

        if winner then
          show_victory_particles(winner:get_pos())
        end
      end
    end

  -- più vincitori
  elseif type(winners) == "table" then

    -- singoli giocatori
    if type(winners[1]) == "string" then
      for _, pl_name in pairs(winners) do
        local winner = minetest.get_player_by_name(pl_name)

        if winner then
          show_victory_particles(winner:get_pos())
        end
      end

    -- squadre
    else
      for _, team_ID in pairs(winners) do
        local team = arena.teams[team_ID]
        for pl_name, pl_stats in pairs(players) do
          if pl_stats.teamID == team_ID then
            local winner = minetest.get_player_by_name(pl_name)

            if winner then
              show_victory_particles(winner:get_pos())
            end
          end
        end
      end
    end
  end
end



function show_victory_particles(p_pos)
  minetest.add_particlespawner({
    amount = 50,
    time = 0.6,
    minpos = p_pos,
    maxpos = p_pos,
    minvel = {x=-2, y=-2, z=-2},
    maxvel = {x=2, y=2, z=2},
    minsize = 1,
    maxsize = 3,
    texture = "arenalib_particle_win.png"
  })
end



function time_loop(mod_ref, arena)
  if arena.in_celebration or not arena.in_game then return end

  if mod_ref.time_mode == "incremental" then
    arena.current_time = arena.current_time + 1
  else
    arena.current_time = arena.current_time - 1
  end

  if mod_ref.on_time_tick then
    mod_ref.on_time_tick(arena)
  end

  if arena.current_time <= 0 then
    mod_ref.on_timeout(arena)
    return
  end

  minetest.after(1, function()
    time_loop(mod_ref, arena)
  end)
end
