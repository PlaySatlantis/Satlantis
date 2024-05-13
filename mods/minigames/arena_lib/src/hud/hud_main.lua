local player_huds = {}    -- KEY: p_name, INDEX: {HUD_BG_ID, HUD_TXT_ID}



function arena_lib.HUD_add(player)
  local HUD_TITLE_IMG = player:hud_add({
    hud_elem_type = "image",
    position  = { x = 0.5, y = 0.25},
    offset    = { x = 0,   y = 50},
    text      = "",
    scale    = { x = 4, y = 1.5 },
    number    = 0xFFFFFF,
    z_index   = 1100
  })

  local HUD_TITLE_TXT = player:hud_add({
    hud_elem_type = "text",
    position  = { x = 0.5, y = 0.25},
    offset    = { x = 0,   y = 50},
    text      = "",
    size      = { x = 2},
    number    = 0xFFFFFF,
    z_index   = 1100
  })

  local HUD_BROADCAST_IMG = player:hud_add({
    hud_elem_type = "image",
    position  = { x = 0.5, y = 0.25},
    text      = "",
    scale     = { x = 25, y = 2},
    number    = 0xFFFFFF,
    z_index   = 1100
  })

  local HUD_BROADCAST_TXT = player:hud_add({
    hud_elem_type = "text",
    position  = { x = 0.5, y = 0.25},
    text      = "",
    number    = 0xFFFFFF,
    z_index   = 1100
  })

  local HUD_HOTBAR_IMG = player:hud_add({
    hud_elem_type = "image",
    position  = { x = 0.5, y = 1},
    offset    = {x = 0, y = -105},
    text      = "",
    scale     = { x = 25, y = 1.5},
    number    = 0xFFFFFF,
    z_index   = 1100
  })

  local HUD_HOTBAR_TXT = player:hud_add({
    hud_elem_type = "text",
    position  = { x = 0.5, y = 1},
    offset    = {x = 0, y = -105},
    text      = "",
    size      = { x = 1, y = 1},
    number    = 0xFFFFFF,
    z_index   = 1100
  })

  player_huds[player:get_player_name()] = {HUD_TITLE_IMG, HUD_TITLE_TXT, HUD_BROADCAST_IMG, HUD_BROADCAST_TXT, HUD_HOTBAR_IMG, HUD_HOTBAR_TXT}
end



function arena_lib.HUD_send_msg(HUD_type, p_name, msg, duration, sound, color)
  local player = minetest.get_player_by_name(p_name)
  local p_HUD = player_huds[p_name]
  color = color or "0xFFFFFF"

  if not player then
    minetest.log("warning", debug.traceback("Player not found, can't send any arena_lib's HUD"))
    return end

  -- controllo il tipo di HUD
  if HUD_type == "title" then
    player:hud_change(p_HUD[1], "text", "arenalib_hud_bg2.png^[opacity:90")
    player:hud_change(p_HUD[2], "text", msg)
    player:hud_change(p_HUD[2], "number", color)
  elseif HUD_type == "broadcast" then
    player:hud_change(p_HUD[3], "text", "arenalib_hud_bg.png^[opacity:127")
    player:hud_change(p_HUD[4], "text", msg)
    player:hud_change(p_HUD[4], "number", color)
  elseif HUD_type == "hotbar" then
    player:hud_change(p_HUD[5], "text", "arenalib_hud_bg.png^[opacity:85")
    player:hud_change(p_HUD[6], "text", msg)
    player:hud_change(p_HUD[6], "number", color)
  end

  -- riproduco eventuale suono
  if sound then
    if type(sound) == "string" then
      if audio_lib.is_sound_registered(sound) then
        audio_lib.play_sound(sound, {to_player = p_name})
      else
        minetest.sound_play(sound, {to_player = p_name})
        minetest.log("action", "[ARENA_LIB] consider using audio_lib system for `" .. sound .. "` for a major user flexibility")
      end
    else
      if audio_lib.is_sound_registered(sound.name) then
        sound.params.to_player = p_name
        audio_lib.play_sound(sound.name, sound.params)
      else
        minetest.sound_play(sound, {to_player = p_name})
        minetest.log("action", "[ARENA_LIB] consider using audio_lib system for `" .. sound.name .. "` for a major user flexibility")
      end
    end
  end

  -- se duration non è specificata, permane all'infinito
  if duration then
    minetest.after(duration, function()
      if minetest.get_player_by_name(p_name) == nil then return end
      -- se è stato aggiornato il messaggio, interrompo questo timer e lascio il controllo a quello nuovo
      if HUD_type == "title"     and player:hud_get(p_HUD[2]).text ~= msg or
         HUD_type == "broadcast" and player:hud_get(p_HUD[4]).text ~= msg or
         HUD_type == "hotbar"    and player:hud_get(p_HUD[6]).text ~= msg then
        return end

      arena_lib.HUD_hide(HUD_type, p_name)
    end)
  end
end



function arena_lib.HUD_send_msg_all(HUD_type, arena, msg, duration, sound, color)
  for pl_name, _ in pairs(arena.players_and_spectators) do
    arena_lib.HUD_send_msg(HUD_type, pl_name, msg, duration, sound, color)
  end
end



function arena_lib.HUD_send_msg_team(HUD_type, arena, teamID, msg, duration, sound, color)
  for pl_name, pl_data in pairs(arena.players) do
    if pl_data.teamID == teamID then
      arena_lib.HUD_send_msg(HUD_type, pl_name, msg, duration, sound, color)

      for sp_name, _ in pairs(arena_lib.get_player_spectators(pl_name)) do
        arena_lib.HUD_send_msg(HUD_type, sp_name, msg, duration, sound, color)
      end
    end
  end
end



function arena_lib.HUD_hide(HUD_type, player_or_arena)
  -- la funzione può prendere sia un giocatore che una tabella di giocatori.
  -- Controllo quale dei due è stato usato
  if type(player_or_arena) == "string" then
    local player = minetest.get_player_by_name(player_or_arena)
    local p_HUD = player_huds[player_or_arena]

    if not player then return end

    if HUD_type == "title" then
      player:hud_change(p_HUD[1], "text", "")
      player:hud_change(p_HUD[2], "text", "")
    elseif HUD_type == "broadcast" then
      player:hud_change(p_HUD[3], "text", "")
      player:hud_change(p_HUD[4], "text", "")
    elseif HUD_type == "hotbar" then
      player:hud_change(p_HUD[5], "text", "")
      player:hud_change(p_HUD[6], "text", "")
    elseif HUD_type == "all" then
      player:hud_change(p_HUD[1], "text", "")
      player:hud_change(p_HUD[2], "text", "")
      player:hud_change(p_HUD[3], "text", "")
      player:hud_change(p_HUD[4], "text", "")
      player:hud_change(p_HUD[5], "text", "")
      player:hud_change(p_HUD[6], "text", "")
    end

  elseif type(player_or_arena) == "table" then
    for pl_name, _ in pairs(player_or_arena.players_and_spectators) do
      local pl = minetest.get_player_by_name(pl_name)
      local pl_HUD = player_huds[pl_name]

      if HUD_type == "title" then
        pl:hud_change(pl_HUD[1], "text", "")
        pl:hud_change(pl_HUD[2], "text", "")
      elseif HUD_type == "broadcast" then
        pl:hud_change(pl_HUD[3], "text", "")
        pl:hud_change(pl_HUD[4], "text", "")
      elseif HUD_type == "hotbar" then
        pl:hud_change(pl_HUD[5], "text", "")
        pl:hud_change(pl_HUD[6], "text", "")
      elseif HUD_type == "all" then
        pl:hud_change(pl_HUD[1], "text", "")
        pl:hud_change(pl_HUD[2], "text", "")
        pl:hud_change(pl_HUD[3], "text", "")
        pl:hud_change(pl_HUD[4], "text", "")
        pl:hud_change(pl_HUD[5], "text", "")
        pl:hud_change(pl_HUD[6], "text", "")
      end
    end
  end
end



function arena_lib.HUD_remove(p_name)
  player_huds[p_name] = nil
end
