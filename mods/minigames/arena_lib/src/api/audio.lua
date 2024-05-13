function arena_lib.sound_play_all(arena, sound, override_params, skip_spectators)
  override_params = override_params or {}

  local targets = skip_spectators and arena.players or arena.players_and_spectators

  for t_name, _ in pairs(targets) do
    override_params.to_player = t_name
    audio_lib.play_sound(sound, override_params)
  end
end



function arena_lib.sound_play_team(arena, teamID, sound, override_params, skip_spectators)
  for pl_name, pl_data in pairs(arena.players) do
    if pl_data.teamID == teamID then
      arena_lib.sound_play(pl_name, sound, override_params, skip_spectators)
    end
  end
end



function arena_lib.sound_play(p_name, sound, override_params, skip_spectators)
  if not arena_lib.is_player_in_arena(p_name) then return end

  override_params = override_params or {}
  override_params.to_player = p_name

  audio_lib.play_sound(sound, override_params)

  if skip_spectators then return end

  if arena_lib.is_player_playing(p_name) then
    for sp_name, _ in pairs(arena_lib.get_player_spectators(p_name)) do
      override_params.to_player = sp_name
      audio_lib.play_sound(sound, override_params)
    end
  end
end