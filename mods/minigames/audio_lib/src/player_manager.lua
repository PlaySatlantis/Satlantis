minetest.register_on_joinplayer(function(player)
  local p_name = player:get_player_name()

  audio_lib.init_player(p_name)
  audio_lib.HUD_accessibility_create(p_name)
end)



minetest.register_on_leaveplayer(function(player)
  local p_name = player:get_player_name()

  audio_lib.dealloc_player(p_name)
  audio_lib.HUD_accessibility_remove(p_name)
end)
