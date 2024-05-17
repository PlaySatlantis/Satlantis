function arena_lib.is_player_in_same_team(arena, p_name, t_name)
  if not arena or not arena.players[p_name] or not arena.players[t_name] then
    return false
  end

  return arena.players[p_name].teamID == arena.players[t_name].teamID
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

-- ritorna tabella di nomi giocatori, o di giocatori se to_players == true
function arena_lib.get_players_in_team(arena, team_ID, to_player)
  local players = {}

  if to_player then
    for pl_name, pl_stats in pairs(arena.players) do
      if pl_stats.teamID == team_ID then
        table.insert(players, minetest.get_player_by_name(pl_name))
      end
    end
  else
    for pl_name, pl_stats in pairs(arena.players) do
      if pl_stats.teamID == team_ID then
        table.insert(players, pl_name)
      end
    end
  end

  return players
end



function arena_lib.get_active_teams(arena)
  if #arena.teams == 1 then
    minetest.log("warning", "Attempt to call get_active_teams in arena " .. arena.name .. " when teams are not enabled. Aborting...")
    return end

  local active_teams = {}

  for ID, _ in pairs(arena.teams) do
    if arena.players_amount_per_team[ID] > 0 then
      active_teams[#active_teams + 1] = ID
    end
  end

  return active_teams
end
