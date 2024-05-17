----------------------------------------------
--------------------UTILS---------------------
----------------------------------------------

-- channel: "players", "spectators", "both"
function arena_lib.send_message_in_arena(arena, channel, msg, teamID, except_teamID)

  if channel == "players" then
    if teamID then
      if except_teamID then
        for pl_name, pl_stats in pairs(arena.players) do
          if pl_stats.teamID ~= teamID then
            minetest.chat_send_player(pl_name, msg)
          end
        end
      else
        for pl_name, pl_stats in pairs(arena.players) do
          if pl_stats.teamID == teamID then
            minetest.chat_send_player(pl_name, msg)
          end
        end
      end
    else
      for pl_name, _ in pairs(arena.players) do
        minetest.chat_send_player(pl_name, msg)
      end
    end

  elseif channel == "spectators" then
    for sp_name, _ in pairs(arena.spectators) do
      minetest.chat_send_player(sp_name, msg)
    end

  elseif channel == "both" then
    for psp_name, _ in pairs(arena.players_and_spectators) do
      minetest.chat_send_player(psp_name, msg)
    end
  end
end





----------------------------------------------
-----------------GETTERS----------------------
----------------------------------------------

function arena_lib.get_arena_by_name(mod, arena_name)
  if not arena_lib.mods[mod] then return end

  for id, arena in pairs(arena_lib.mods[mod].arenas) do
    if arena.name == arena_name then
      return id, arena end
  end
end



function arena_lib.get_arena_spawners_count(arena, team_ID)
  if team_ID and arena.teams_enabled then
    return #arena.spawn_points[team_ID]
  else
    if arena.teams_enabled then
      local count = 0
      for i = 1, #arena.teams do
        count = count + #arena.spawn_points[i]
      end
      return count
    else
      return #arena.spawn_points
    end
  end
end



function arena_lib.get_random_spawner(arena, team_ID)
  if arena.teams_enabled then
    return arena.spawn_points[team_ID][math.random(1, table.maxn(arena.spawn_points[team_ID]))]
  else
    return arena.spawn_points[math.random(1,table.maxn(arena.spawn_points))]
  end
end
