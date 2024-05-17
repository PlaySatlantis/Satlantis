local S = minetest.get_translator("arena_lib")

local function get_rejoin_formspec() end

local crashed_players = {}          -- KEY: p_name; VALUE: matchID



minetest.register_on_joinplayer(function(player)
  local p_name = player:get_player_name()

  arena_lib.HUD_add(player)
  arena_lib.restore_inventory(p_name)

  local p_meta = player:get_meta()
  local p_inv  = player:get_inventory()

  -- nel caso qualcuno si fosse disconnesso da dentro all'editor o fosse crashato il server con qualcuno nell'editor
  if p_inv:contains_item("main", "arena_lib:editor_quit") then

    p_meta:set_string("arena_lib_editor.mod", "")
    p_meta:set_string("arena_lib_editor.arena", "")
    p_meta:set_int("arena_lib_editor.players_number", 0)
    p_meta:set_int("arena_lib_editor.team_ID", 0)

    if minetest.get_modpath("hub_core") then return end          -- se c'è Hub, ci pensa quest'ultimo allo svuotamento dell'inventario

    p_inv:set_list("main", {})
    p_inv:set_list("craft", {})

  -- se invece era in spettatore
  elseif p_inv:get_list("hand") and p_inv:contains_item("hand", "arena_lib:spectate_hand") then
    p_inv:set_stack("hand", 1, nil)
    p_inv:set_size("hand", 0)
  end

  if crashed_players[p_name] and arena_lib.get_arena_by_matchID(crashed_players[p_name]) then
    minetest.show_formspec(p_name, "arena_lib:rejoin", get_rejoin_formspec())
  end

  p_meta:set_string("arenalib_infobox_mod", "")
  p_meta:set_int("arenalib_infobox_arenaID", 0)
end)



minetest.register_on_leaveplayer(function(player, timed_out)
    local p_name = player:get_player_name()

    if arena_lib.is_player_in_arena(p_name) then
      if timed_out and arena_lib.SHOW_REJOIN_DIALOG then
        local mod = arena_lib.get_mod_by_player(p_name)
        local mod_ref = arena_lib.mods[mod]

        if not arena_lib.is_player_spectating(p_name) and mod_ref.join_while_in_progress then
          crashed_players[p_name] = arena_lib.get_arena_by_player(p_name).matchID
        end
      end

      arena_lib.remove_player_from_arena(p_name, 0)

    elseif arena_lib.is_player_in_queue(p_name) then
      arena_lib.remove_player_from_queue(p_name, true)
    elseif arena_lib.is_player_in_edit_mode(p_name) then
      arena_lib.quit_editor(player)
    elseif arena_lib.is_player_in_settings(p_name) then
      arena_lib.quit_minigame_settings(p_name)
    end

    arena_lib.HUD_remove(p_name)
end)



minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
  -- le entità possono far male a prescindere
  if not hitter:is_player() then return end

  local t_name = player:get_player_name()
  local p_name = hitter:get_player_name()
  local t_arena = arena_lib.get_arena_by_player(t_name)
  local p_arena = arena_lib.get_arena_by_player(p_name)

  -- se nessunə dei due è perlomeno in coda, lascio spazio agli altri eventuali on_punchplayer
  if not p_arena and not t_arena then
    return
  end

  local is_p_queuing = arena_lib.is_player_in_queue(p_name)
  local is_t_queuing = arena_lib.is_player_in_queue(t_name)
  local is_p_playing = arena_lib.is_player_in_arena(p_name)
  local is_t_playing = arena_lib.is_player_in_arena(t_name)

  -- se nessunə dei due è in partita, ma solo al massimo in coda, lascio spazio agli altri eventuali on_punchplayer
  if (is_p_queuing and not is_t_playing) or
      (is_t_queuing and not is_p_playing) then
    return
  end

  -- se unə è in partita e l'altro no, annullo
  if (is_p_playing and not is_t_playing) or
      (is_t_playing and not is_p_playing) then
    return true
  end

  -- se sono nella stessa partita e l'arena è o in caricamento o in celebrazione, annullo
  if p_arena.in_loading or p_arena.in_celebration then
    return true
  end

  local mod_ref = arena_lib.mods[arena_lib.get_mod_by_player(p_name)]

  -- idem se sono nella stessa squadra, annullo
  if p_arena.teams_enabled and not mod_ref.friendly_fire and arena_lib.is_player_in_same_team(p_arena, p_name, t_name) then
    return true
  end
end)



minetest.register_on_player_hpchange(function(player, hp_change, reason)
    local p_name = player:get_player_name()
    if not arena_lib.is_player_in_arena(p_name) then return hp_change end

    -- se è spettatore, annullo a meno che non abbia cambiato giocatore seguito
    -- o che il giocatore seguito non abbia subito un danno (che usano set_hp).
    -- Questo lo rende vulnerabile anche a cose come /kill, ma l'uccisione dello
    -- spettatore viene comunque gestita senza problemi da arena_lib, giusto in
    -- caso qualche amministratore sia particolarmente simpatico o un minigioco
    -- si sia scordato di filtrare (per esempio) gli spettatori dal danno di una
    -- abilità ad area. Quando torna in vita, gli hp gli vengono impostati da
    -- find_and_spectate_player (questo spiega perché venga curato anche se
    -- ignora il tipo "respawn")
    if arena_lib.is_player_spectating(p_name) then
      return reason.type == "set_hp" and hp_change or 0
    end

    local mod = arena_lib.get_mod_by_player(p_name)

    -- se un tipo di danno è disabilitato, annullo
    for _, disabled_damage in pairs(arena_lib.mods[mod].disabled_damage_types) do
      if reason.type == disabled_damage then
        return 0
      end
    end

    -- aggiorna la vita di ogni spettatore che seguiva quel giocatore..
    if arena_lib.is_player_spectated(p_name) then
      for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
        local spectator = minetest.get_player_by_name(sp_name)
        -- ..se lo spettatore non è stato ucciso per chissà quale arcano motivo
        if spectator:get_hp() > 0 then
          if player:get_hp() > 0 then
            spectator:set_hp(math.max(player:get_hp() + hp_change, 1))
          else
            if reason.type == "respawn" then
              spectator:set_hp(minetest.PLAYER_MAX_HP_DEFAULT)
            else
              spectator:set_hp(1)
            end
          end
        end
      end
    end

    return hp_change

end, true)



minetest.register_on_dieplayer(function(player, reason)
  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name) or arena_lib.is_player_spectating(p_name) then return end

  local mod_ref = arena_lib.mods[arena_lib.get_mod_by_player(p_name)]
  local arena = arena_lib.get_arena_by_player(p_name)
  local p_stats = arena.players[p_name]
  p_stats.deaths = p_stats.deaths +1

  if mod_ref.on_death then
    mod_ref.on_death(arena, p_name, reason)
  end

  if mod_ref.eliminate_on_death then
    local xc_name = reason.object and reason.object:get_player_name()
    arena_lib.remove_player_from_arena(p_name, 1, xc_name)
  end
end)



minetest.register_on_respawnplayer(function(player)
  local p_name = player:get_player_name()

  if not arena_lib.is_player_in_arena(p_name) then return end

  if arena_lib.is_player_spectating(p_name) then -- lɜ spettatorɜ non dovrebbero proprio morire, ma in caso...
    arena_lib.find_and_spectate_player(p_name)

  else
    local mod_ref = arena_lib.mods[arena_lib.get_mod_by_player(p_name)]
    local arena = arena_lib.get_arena_by_player(p_name)

    player:set_pos(arena_lib.get_random_spawner(arena, arena.players[p_name].teamID))

    if mod_ref.on_respawn then
      mod_ref.on_respawn(arena, p_name)
    end
  end

  return true
end)





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function get_rejoin_formspec()
  local formspec = {
    "formspec_version[4]",
    "size[6,2.5]",
    "style[cancel;bgcolor=red]",
    "style[confirm;bgcolor=green]",
    "hypertext[0.5,0.1;5,1.2;msg;<global halign=center valign=middle>" .. S("The game you were in is still in progress: do you want to rejoin?") .. "]",
    "button[3.25,1.5;1.75,0.7;confirm;" .. S("Yes") .. "]",
    "button[1,1.5;1.75,0.7;cancel;" .. S("Cancel") .. "]",
    "field_close_on_enter[;false]"
  }

  return table.concat(formspec, "")
end





----------------------------------------------
---------------GESTIONE CAMPI-----------------
----------------------------------------------

minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "arena_lib:rejoin" then return end

  local p_name = player:get_player_name()

  -- se rifiuta
  if fields.quit or fields.cancel then
    crashed_players[p_name] = nil
    minetest.close_formspec(p_name, "arena_lib:rejoin")

  -- se accetta
  elseif fields.confirm then
    local matchID = crashed_players[p_name]

    if not matchID then
      arena_lib.print_error(p_name, S("The match has ended whilst you were deciding :c"))
      return end

    local mod = arena_lib.get_mod_by_matchID(matchID)
    local id = arena_lib.get_arena_by_matchID(matchID)

    arena_lib.join_arena(mod, p_name, id)
    crashed_players[p_name] = nil
  end
end)
