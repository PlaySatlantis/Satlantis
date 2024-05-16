minetest.register_on_joinplayer(function(player)
  collectible_skins.load_player_data(player)
end)
