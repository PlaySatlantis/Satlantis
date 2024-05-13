local S = minetest.get_translator("arena_lib")

local function assign_team() end



-- INTERNAL USE ONLY --- v
function arena_lib.print_info(p_name, msg)
  if not p_name or not minetest.get_player_by_name(p_name) then
    -- se ci sono stringhe tradotte, le ripulisco
    if msg:find("\27%(T@[%w_-]+%)") then
      msg = msg:gsub("\27%(T@[%w_-]+%)", "")  -- removing \27(T@mod_name)
      msg = msg:gsub("\27F", "")
      msg = msg:gsub("\27E", "")
    end

    minetest.log("action", "[ARENA_LIB] " .. msg)
  else
    minetest.chat_send_player(p_name, msg)
  end
end
-- ^ ------------------- ^



function arena_lib.print_error(p_name, msg)
  if not p_name or not minetest.get_player_by_name(p_name) then
    -- se ci sono stringhe tradotte, le ripulisco
    if msg:find("\27%(T@[%w_-]+%)") then
      msg = msg:gsub("\27%(T@[%w_-]+%)", "")  -- removing \27(T@mod_name)
      msg = msg:gsub("\27F", "")
      msg = msg:gsub("\27E", "")
    end

    minetest.log("error", "[ARENA_LIB] [!] " .. msg)
  else
    minetest.chat_send_player(p_name, minetest.colorize("#e6482e", S("[!] @1", msg)))
  end
end



function arena_lib.get_and_add_joining_players(arena, p_name)
  local p_team_ID

  -- se non in partita, le squadre vengono riempite in anticipo solo da chi è in gruppo
  if arena.teams_enabled and (arena.in_game or (minetest.get_modpath("parties") and parties.is_player_in_party(p_name))) then
    p_team_ID = assign_team(arena, p_name)
  end

  local players_to_add = {}

  -- potrei avere o un giocatore o un intero gruppo da aggiungere. Quindi per evitare
  -- mille if, metto a prescindere il/i giocatore/i in una tabella per iterare in
  -- alcune operazioni successive
  if minetest.get_modpath("parties") and parties.is_player_in_party(p_name) then
    players_to_add = table.copy(parties.get_party_members(p_name, true))
  else
    table.insert(players_to_add, p_name)
  end

  -- aggiungo lə giocante
  for _, pl_name in ipairs(players_to_add) do
    arena.players[pl_name] = {deaths = 0, teamID = p_team_ID}
    arena.players_and_spectators[pl_name] = true
  end

  -- aumento il conteggio di giocanti in partita
  arena.players_amount = arena.players_amount + #players_to_add
  if arena.teams_enabled and p_team_ID then
    arena.players_amount_per_team[p_team_ID] = arena.players_amount_per_team[p_team_ID] + #players_to_add
  end

  return players_to_add
end



function arena_lib.get_palette_col_and_sorted_table()
  -- inverto chiavi con valori
  local inverted = {}
  for k in pairs(arena_lib.PALETTE) do
    table.insert(inverted, k)
  end

  table.sort(inverted, function(a, b) return a:lower() < b:lower() end)

  local palette = ""
  local palette_table = {}
  local i = 1

  for _, col in pairs(inverted) do
    palette = palette .. col .. ","
    palette_table[arena_lib.PALETTE[col]] = i
    i = i+1
  end

  return palette:sub(1, -2), palette_table
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------

function assign_team(arena, p_name)
  -- se ha assegnazione on_join personalizzata
  if arena.in_game then
    local mod = arena_lib.get_mod_by_matchID(arena.matchID)
    local mod_ref = arena_lib.mods[mod]

    if mod_ref.on_assign_team then
      return mod_ref.on_assign_team(arena, p_name)
    end
  end

  -- sennò normale
  local sorted_teams = {} -- {ID, amount}

  for teamID, amount in pairs(arena.players_amount_per_team) do
    sorted_teams[teamID] = {ID = teamID, amount = amount}
  end

  -- le ordino per capire quale ha meno giocanti (usando ID per tener traccia di che squadra si tratta)
  table.sort(sorted_teams, function(a, b)
      if a.amount ~= b.amount then
        return a.amount < b.amount
      else
        return a.ID < b.ID
      end
    end)

  -- se non è in partita, è un gruppo e ci stanno già gruppi in tutte le squadre,
  -- li distribuisco il più equamente possibile: se la 2° squadra ha meno gente
  -- della squadra entrante, somma 1° con 2° e metti la entrante come 1°
  -- (es. 2, 3, 5 | 4 => 4, 2 + 3, 3)
  if not arena.in_game and sorted_teams[1].amount > 0 then
    if sorted_teams[2].amount < #parties.get_party_members(p_name, true) then
      for pl_name, pl_data in pairs(arena.players) do
        if pl_data.teamID == sorted_teams[1].ID then
          pl_data.teamID = pl_data.teamID + 1
        end
      end
    end
  end

  return sorted_teams[1].ID
end
