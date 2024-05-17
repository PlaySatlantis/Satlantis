local S = minetest.get_translator("arena_lib")

local function table_to_string() end



function arena_lib.print_minigames(sender)
  local mgs = {}
  local str = "-------------------------\n"

  for mod, _ in pairs(arena_lib.mods) do
    table.insert(mgs, mod)
  end
  table.sort(mgs, function(a, b) return a < b end)

  for id, mod in pairs(mgs) do
    str = str .. id .. ". " .. mod .. "\n"
  end

  str = str .. "-------------------------"
  minetest.chat_send_player(sender, str)
end



function arena_lib.print_arenas(sender, mod)
  local mod_ref = arena_lib.mods[mod]

  if not mod_ref then
    arena_lib.print_error(sender, S("This minigame doesn't exist!"))
    return end

  local n = 0
  for id, arena in pairs(arena_lib.mods[mod].arenas) do
    n = n+1
    minetest.chat_send_player(sender, S("ID: @1, name: @2", id, arena.name))
  end

  minetest.chat_send_player(sender, S("Total arenas: @1", n))
end



function arena_lib.print_arena_info(sender, mod, arena_name)
  local arena_ID, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not arena then
    arena_lib.print_error(sender, S("This arena doesn't exist!"))
    return end

  local thumbnail = arena.thumbnail == "" and "---" or arena.thumbnail

  -- calcolo eventuale musica sottofondo
  local arena_bgm = "---"
  if arena.bgm then
    local bgm = arena.bgm
    arena_bgm = ("%s | %s (♪ %.2f, ♭ %.2f)"):format(bgm.track, bgm.description or "---", bgm.gain or 1, bgm.pitch or 1)
  end

  local mod_ref = arena_lib.mods[mod]
  local arena_min_players = arena.min_players * #arena.teams
  local arena_max_players = arena.max_players == -1 and -1 or arena.max_players * #arena.teams
  local teams = ""
  local min_players_per_team = ""
  local max_players_per_team = ""
  local players_inside_per_team = ""
  local spectators_inside_per_team = ""

  -- calcolo eventuali squadre
  if arena.teams_enabled then
    min_players_per_team = minetest.colorize("#eea160", S("Players required per team: @1", minetest.colorize("#cfc6b8", arena.min_players))) .. "\n"
    max_players_per_team = minetest.colorize("#eea160", S("Players supported per team: @1", minetest.colorize("#cfc6b8", arena.max_players))) .. "\n"

    if mod_ref.variable_teams_amount then
      teams = "(" .. #arena.teams .. ") "
    end

    for i = 1, #arena.teams do
      teams = teams .. "'" .. arena.teams[i].name .. "' "
      players_inside_per_team = players_inside_per_team .. "'" .. arena.teams[i].name .. "' : " .. arena.players_amount_per_team[i] .. " "
      if mod_ref.spectate_mode then
        spectators_inside_per_team = spectators_inside_per_team .. "'" .. arena.teams[i].name .. "' : " .. arena.spectators_amount_per_team[i] .. " "
      end
    end

    players_inside_per_team = minetest.colorize("#eea160", S("Players inside per team: @1", minetest.colorize("#cfc6b8", players_inside_per_team))) .. "\n"
    if mod_ref.spectate_mode then
      spectators_inside_per_team = minetest.colorize("#eea160", S("Spectators inside per team: @1", minetest.colorize("#cfc6b8", spectators_inside_per_team))) .. "\n"
    end
  else
    teams = "---"
  end

  -- calcolo nomi giocatori
  local p_names = ""
  for pl, stats in pairs(arena.players) do
    p_names = p_names .. " " .. pl
  end

  -- calcolo nomi spettatori
  local sp_names = ""
  for sp_name, stats in pairs(arena.spectators) do
    sp_names = sp_names .. " " .. sp_name
  end

  -- calcolo giocatori e spettatori (per verificare che campo sia giusto)
  local psp_names = ""
  local psp_amount = 0
  for psp_name, _ in pairs(arena.players_and_spectators) do
    psp_names = psp_names .. " " .. psp_name
    psp_amount = psp_amount + 1
  end

  -- calcolo giocatori presenti e passati
  local ppp_names = ""
  local ppp_names_amount = 0
  for ppp_name, _ in pairs(arena.past_present_players) do
    ppp_names = ppp_names .. " " .. ppp_name
    ppp_names_amount = ppp_names_amount + 1
  end

  -- calcolo giocatori presenti e passati
  local ppp_names_inside = ""
  local ppp_names_inside_amount = 0
  for ppp_name_inside, _ in pairs(arena.past_present_players_inside) do
    ppp_names_inside = ppp_names_inside .. " " .. ppp_name_inside
    ppp_names_inside_amount = ppp_names_inside_amount + 1
  end

  -- calcolo eventuali entità/aree seguibili
  local spectatable_entities = ""
  local spectatable_areas = ""
  if mod_ref.spectate_mode then
    local entities = ""
    local areas = ""
    if arena.in_game then
      for en_name, _ in pairs(arena_lib.get_spectatable_entities(mod, arena_name)) do
        entities = entities .. en_name .. ", "
      end
      for ar_name, _ in pairs(arena_lib.get_spectatable_areas(mod, arena_name)) do
        areas = areas .. ar_name .. ", "
      end
      entities = entities:sub(1, -3)
      areas = areas:sub(1, -3)
    else
      entities = "---"
      areas = "---"
    end

    spectatable_entities = minetest.colorize("#eea160", S("Current spectatable entities: @1", minetest.colorize("#cfc6b8", entities))) .. "\n"
    spectatable_areas = minetest.colorize("#eea160", S("Current spectatable areas: @1", minetest.colorize("#cfc6b8", areas))) .. "\n\n"
  end

  -- calcolo stato arena
  local status
  if arena.in_queue then
    status = S("in queue")
  elseif arena.in_loading then
    status = S("loading")
  elseif arena.in_game then
    status = S("in game")
  elseif arena.in_celebration then
    status = S("celebrating")
  else
    status = S("waiting")
  end

  local is_resetting = ""
  if arena.is_resetting ~= nil then
    is_resetting = minetest.colorize("#eea160", S("Is resetting: @1", minetest.colorize("#cfc6b8", tostring(arena.is_resetting)))) .. "\n"
  end

  -- calcolo eventuale entrata
  local entrance = "---"
  if arena.entrance ~= nil then
    entrance = arena_lib.entrances[arena.entrance_type].print(arena.entrance)
  end

  -- calcolo eventuale regione
  local region = "---"
  if arena.pos1 then
    region = "Pos1 " .. minetest.pos_to_string(arena.pos1) .. " Pos2 " .. minetest.pos_to_string(arena.pos2) .. ""
  end

  -- calcolo eventuale punto di ritorno personalizzato
  local custom_return_point = not arena.custom_return_point and "---" or minetest.pos_to_string(arena.custom_return_point)

  -- calcolo coordinate punti rinascita
  local spawners_pos = ""
  if arena.teams_enabled then

    for team_ID = 1, #arena.teams do
      spawners_pos = spawners_pos .. arena.teams[team_ID].name .. ": "
      for _, pos in pairs(arena.spawn_points[team_ID])  do
        spawners_pos = spawners_pos .. " " .. minetest.pos_to_string(pos) .. " "
      end
      spawners_pos = spawners_pos .. "; "
    end

  else
    for _, pos in pairs(arena.spawn_points) do
      spawners_pos = spawners_pos .. " " .. minetest.pos_to_string(pos) .. " "
    end
  end

  -- calcolo eventuale tempo
  local time = ""
  if mod_ref.time_mode ~= "none" then
    local current_time = not arena.current_time and "---" or arena.current_time
    time = minetest.colorize("#eea160", S("Initial time: @1", minetest.colorize("#cfc6b8", arena.initial_time .. " (" .. S("current: @1", current_time) .. ")"))) .. "\n"
  end

  -- calcolo eventuale volta celeste personalizzata
  local celvault = ""
  if arena.celestial_vault then
    for elem, params in pairs(arena.celestial_vault) do
      if next(params) then
        celvault = celvault .. string.upper(elem) .. ": " .. table_to_string(params) .. "\n"
      end
    end
    celvault = celvault:sub(1,-2)
  else
    celvault = "---"
  end

  -- calcolo eventuale effetto meteo
  local weather = ""
  if arena.weather then
    local wt_type, strength
    local particles = arena.weather
    local texture = particles.texture.name
    if texture == "arenalib_particle_rain.png" then
      wt_type = S("rain")
    elseif texture == "arenalib_particle_snow.png" then
      wt_type = S("snow")
    elseif string.match(texture, "arenalib_particle_dust.png") then
      wt_type = S("dust")
    else
      wt_type = S("custom")
    end

    if wt_type ~= S("custom") then
      strength = ", " .. string.lower(S("Strength")) .. ": " .. particles.amount / 500  -- ogni quantità è amount * 5 (editor) * 100 (API)
    end

    weather = wt_type .. strength
  else
    weather = "---"
  end


  -- calcolo eventuale illuminazione personalizzata
  local lighting = "---"
  if arena.lighting then
    lighting = table_to_string(arena.lighting)
  end

  --calcolo proprietà
  local properties = ""
  if next(mod_ref.properties) then
    for property, _ in pairs(mod_ref.properties) do
      local value = AL_property_to_string(arena[property])
      properties = properties .. property .. " = " .. value .. "; "
    end
  else
    properties = "---"
  end

  --calcolo proprietà temporanee
  local temp_properties = ""
  if next(mod_ref.temp_properties) then
    if arena.in_game then
      for temp_property, _ in pairs(mod_ref.temp_properties) do
        local value = AL_property_to_string(arena[temp_property])
        temp_properties = temp_properties .. temp_property .. " = " .. value .. "; "
      end
    else
      for temp_property, _ in pairs(mod_ref.temp_properties) do
        temp_properties = temp_properties .. temp_property .. "; "
      end
    end
  else
    temp_properties = "---"
  end

  local p_properties = ""
  if next(mod_ref.player_properties) then
    if arena.in_game then
      for pl_name, pl_stats in pairs(arena.players) do
        p_properties = p_properties .. pl_name .. ": "
        for pl_property, _ in pairs(mod_ref.player_properties) do
          local value = AL_property_to_string(pl_stats[pl_property])
          p_properties = p_properties .. pl_property .. " = " .. value .. "; "
        end
        p_properties = p_properties .. "| "
      end
    else
      for pl_property, _ in pairs(mod_ref.player_properties) do
        p_properties = p_properties .. pl_property .. "; "
      end
    end
  else
    p_properties = "---"
  end

  local sp_properties = ""
  if mod_ref.spectate_mode then
    if arena.in_game then
      for sp_name, sp_stats in pairs(arena.spectators) do
        sp_properties = sp_properties .. sp_name .. ": "
        for sp_property, _ in pairs(mod_ref.spectator_properties) do
          local value = AL_property_to_string(sp_stats[sp_property])
          sp_properties = sp_properties .. sp_property .. " = " .. value .. "; "
        end
        sp_properties = sp_properties .. "| "
      end
    else
      for sp_property, _ in pairs(mod_ref.spectator_properties) do
        sp_properties = sp_properties .. sp_property .. "; "
      end
    end
    sp_properties = minetest.colorize("#eea160", S("Spectator properties: @1", minetest.colorize("#cfc6b8", sp_properties))) .. "\n"
  end

  local team_properties = ""
  if arena.teams_enabled then
    if next(mod_ref.team_properties) then
      if arena.in_game then
        for i = 1, #arena.teams do
          team_properties = team_properties .. arena.teams[i].name .. ": "
          for team_property, _ in pairs(mod_ref.team_properties) do
            local value = AL_property_to_string(arena.teams[i][team_property])
            team_properties = team_properties .. " " .. team_property .. " = " .. value .. ";"
          end
          team_properties = team_properties .. "|"
        end
      else
        for team_property, _ in pairs(mod_ref.team_properties) do
          team_properties = team_properties .. team_property .. "; "
        end
      end
    else
      team_properties = "---"
    end
    team_properties = minetest.colorize("#eea160", S("Team properties: @1", minetest.colorize("#cfc6b8", team_properties)))
  end

  minetest.chat_send_player(sender,
    minetest.colorize("#cfc6b8", "====================================") .. "\n" ..
    minetest.colorize("#eea160", S("Name: @1", minetest.colorize("#cfc6b8", arena_name ))) .. "\n" ..
    minetest.colorize("#eea160", S("ID: @1", minetest.colorize("#cfc6b8", arena_ID))) .. "\n" ..
    minetest.colorize("#eea160", S("Match ID: @1", minetest.colorize("#cfc6b8", arena.matchID or "---"))) .. "\n\n" ..

    minetest.colorize("#eea160", S("Author: @1", minetest.colorize("#cfc6b8", arena.author))) .. "\n" ..
    minetest.colorize("#eea160", S("Thumbnail: @1", minetest.colorize("#cfc6b8", thumbnail))) .. "\n" ..
    minetest.colorize("#eea160", S("BGM: @1", minetest.colorize("#cfc6b8", arena_bgm))) .. "\n\n" ..

    minetest.colorize("#eea160", S("Teams: @1", minetest.colorize("#cfc6b8", teams))) .. "\n" ..
    min_players_per_team ..
    max_players_per_team ..
    minetest.colorize("#eea160", S("Players required: @1", minetest.colorize("#cfc6b8", arena_min_players))) .. "\n" ..
    minetest.colorize("#eea160", S("Players supported: @1", minetest.colorize("#cfc6b8", arena_max_players))) .. "\n" ..
    minetest.colorize("#eea160", S("Players inside: @1", minetest.colorize("#cfc6b8", arena.players_amount .. " ( ".. p_names .. " )"))) .. "\n" ..
    players_inside_per_team ..
    minetest.colorize("#eea160", S("Spectators inside: @1", minetest.colorize("#cfc6b8", arena.spectators_amount .. " ( ".. sp_names .. " )"))) .. "\n" ..
    spectators_inside_per_team ..
    minetest.colorize("#eea160", S("Players and spectators inside: @1", minetest.colorize("#cfc6b8", psp_amount .. " ( ".. psp_names .. " )"))) .. "\n" ..
    minetest.colorize("#eea160", S("Past and present players: @1", minetest.colorize("#cfc6b8", ppp_names_amount .. " ( " .. ppp_names .. " )"))) .."\n" ..
    minetest.colorize("#eea160", S("Past and present players inside: @1", minetest.colorize("#cfc6b8", ppp_names_inside_amount .. " ( " .. ppp_names_inside .. " )"))) .."\n\n" ..

    spectatable_entities ..
    spectatable_areas ..

    minetest.colorize("#eea160", S("Enabled: @1", minetest.colorize("#cfc6b8", tostring(arena.enabled)))) .. "\n" ..
    minetest.colorize("#eea160", S("Status: @1", minetest.colorize("#cfc6b8", status))) .. "\n" ..
    is_resetting ..
    minetest.colorize("#eea160", S("Entrance: @1", minetest.colorize("#cfc6b8", "(" .. arena.entrance_type .. ") " .. entrance))) .. "\n" ..
    minetest.colorize("#eea160", S("Region: @1", minetest.colorize("#cfc6b8", region))) .. "\n" ..
    minetest.colorize("#eea160", S("Custom return point: @1", minetest.colorize("#cfc6b8", custom_return_point))) .. "\n" ..
    minetest.colorize("#eea160", S("Spawn points: @1", minetest.colorize("#cfc6b8", arena_lib.get_arena_spawners_count(arena) .. " ( " .. spawners_pos .. ")"))) .. "\n\n" ..

    time ..
    minetest.colorize("#eea160", S("Custom sky: @1", minetest.colorize("#cfc6b8", celvault))) .. "\n" ..
    minetest.colorize("#eea160", S("Weather: @1", minetest.colorize("#cfc6b8", weather))) .. "\n" ..
    minetest.colorize("#eea160", S("Custom lighting: @1", minetest.colorize("#cfc6b8", lighting))) .. "\n\n" ..

    minetest.colorize("#eea160", S("Properties: @1", minetest.colorize("#cfc6b8", properties))) .. "\n" ..
    minetest.colorize("#eea160", S("Temp properties: @1", minetest.colorize("#cfc6b8", temp_properties))) .. "\n" ..
    minetest.colorize("#eea160", S("Player properties: @1", minetest.colorize("#cfc6b8", p_properties))) .. "\n" ..
    sp_properties,
    team_properties
  )
end



function arena_lib.flush_arena(mod, arena_name, sender)
  local _, arena = arena_lib.get_arena_by_name(mod, arena_name)

  if not ARENA_LIB_EDIT_PRECHECKS_PASSED(sender, arena) then return end

  if arena.in_queue or arena.in_game then
    arena_lib.print_error(sender, S("You can't perform this action during an ongoing game!"))
    return end

  arena.players = {}
  arena.spectators = {}
  arena.players_and_spectators = {}
  arena.past_present_players = {}
  arena.past_present_players_inside = {}
  arena.players_amount = 0

  if arena.teams_enabled then
    local mod_ref = arena_lib.mods[mod]
    for i = 1, #arena.teams do
      arena.players_amount_per_team[i] = 0
      if mod_ref.spectate_mode then
        arena.spectators_amount_per_team[i] = 0
      end
    end
  end

  arena.current_time = nil
  minetest.chat_send_player(sender, "Sluuush!")
end



function arena_lib.check_for_unused_resources(sender)
  local resources = {}
  local wrld_path = minetest.get_worldpath() .. "/arena_lib"

  for _, f_name in pairs(minetest.get_dir_list(wrld_path .. "/BGM", false)) do
    if f_name:find(".ogg") then
      resources[f_name] = true
    end
  end

  for _, f_name in pairs(minetest.get_dir_list(wrld_path .. "/Thumbnails")) do
    if f_name:find(".png") or f_name:find(".jpg") or f_name:find(".bmp") then
      resources[f_name] = true
    end
  end

  for _, mod_def in pairs(arena_lib.mods) do
    for _, arena in pairs(mod_def.arenas) do
      resources[arena.thumbnail] = nil

      if arena.bgm then
        local bgm = arena.bgm.track .. ".ogg"
        resources[bgm] = nil
      end
    end
  end

  minetest.chat_send_player(sender, minetest.colorize("#cfc6b8", "===================================="))
  minetest.chat_send_player(sender, minetest.colorize("#eea160", S("Unused arena_lib resources:")))

  if next(resources) then
    for name, _ in pairs(resources) do
      minetest.chat_send_player(sender, name)
    end
  else
    minetest.chat_send_player(sender, "---")
  end
  minetest.chat_send_player(sender, minetest.colorize("#cfc6b8", "===================================="))
end





----------------------------------------------
---------------FUNZIONI LOCALI----------------
----------------------------------------------



function table_to_string(table)
  local str = ""
  for k, v in pairs(table) do
    local val = ""

    if type(v) == "table" then
      if next(v) then
        val = "{ " .. table_to_string(v) .. "}"
      end
    else
      val = tostring(v)
    end

    if val ~= "" then
      str = str .. k .. " = " .. val .. "; "
    end
  end

  return str
end
