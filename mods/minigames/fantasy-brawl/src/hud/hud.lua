dofile(minetest.get_modpath("fantasy_brawl") .. "/src/hud/scoreboard.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/hud/timer_hud.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/hud/stats_hud.lua")
dofile(minetest.get_modpath("fantasy_brawl") .. "/src/hud/controls_hud.lua")

fbrawl.saved_huds = {} -- pl_name = {hud_name = id}


function fbrawl.init_HUD(arena, pl_name, as_spectator)
  if fbrawl.saved_huds[pl_name] then return end
  fbrawl.saved_huds[pl_name] = {}

  local player = minetest.get_player_by_name(pl_name)

  fbrawl.generate_scoreboard(pl_name)
  fbrawl.generate_timer_HUD(pl_name)
  if not as_spectator then
    fbrawl.generate_stats(player, pl_name)
    fbrawl.generate_controls_hud(arena, pl_name)
  end

  local waypoint = player:hud_add({
    name = "waypoint",
    hud_elem_type = "image_waypoint",
    text = "fbrawl_smash_item.png",
    scale = {x=0, y=0},
    size = {x=1, y=1},
  })
  fbrawl.saved_huds[pl_name].waypoint = waypoint
end



function fbrawl.update_hud(pl_name, field, new_value)
  if fbrawl.saved_huds[pl_name] and fbrawl.saved_huds[pl_name][field] then
    local player = minetest.get_player_by_name(pl_name)
    player:hud_change(fbrawl.saved_huds[pl_name][field], "text", new_value)
  end
end



function fbrawl.remove_huds(pl_name)
  minetest.after(1, function()
    local player = minetest.get_player_by_name(pl_name)

    if not player or not fbrawl.saved_huds[pl_name] then
      fbrawl.saved_huds[pl_name] = nil
      return
    end

    for name, id in pairs(fbrawl.saved_huds[pl_name]) do
      player:hud_remove(id)
    end

    if panel_lib.has_panel(pl_name, "fbrawl:podium") then
      panel_lib.get_panel(pl_name, "fbrawl:podium"):remove()
    end

    fbrawl.saved_huds[pl_name] = nil
  end)
end



function fbrawl.add_temp_hud(pl_name, hud, time)
  local player = minetest.get_player_by_name(pl_name)

  hud = player:hud_add(hud)
  fbrawl.saved_huds[pl_name] = fbrawl.saved_huds[pl_name] or {}
  fbrawl.saved_huds[pl_name][tostring(hud)] = hud

  minetest.after(time, function()
    -- Removing the hud if the player still has it.
    if fbrawl.saved_huds[pl_name] and fbrawl.saved_huds[pl_name][tostring(hud)] then
      player:hud_remove(hud)
      fbrawl.saved_huds[pl_name][tostring(hud)] = nil
    end
  end)

  return hud
end



function fbrawl.add_hud(pl_name, name, def)
  local player = minetest.get_player_by_name(pl_name)

  if not player then return end

  local hud = player:hud_add(def)
  fbrawl.saved_huds[pl_name] = fbrawl.saved_huds[pl_name] or {}
  fbrawl.saved_huds[pl_name][name] = hud

  return hud
end



function fbrawl.remove_hud(pl_name, name)
  local player = minetest.get_player_by_name(pl_name)

  if not player or not fbrawl.saved_huds[pl_name] or not fbrawl.saved_huds[pl_name][name] then return end

  player:hud_remove(fbrawl.saved_huds[pl_name][name])

  fbrawl.saved_huds[pl_name][name] = nil
end



function fbrawl.get_hud(pl_name, name)
  local player = minetest.get_player_by_name(pl_name)

  if not player or not fbrawl.saved_huds[pl_name] or not fbrawl.saved_huds[pl_name][name] then return end

  return fbrawl.saved_huds[pl_name][name]
end
