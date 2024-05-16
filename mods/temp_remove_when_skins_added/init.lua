-- set players' skins to character.png when they join
minetest.register_on_joinplayer(function(player)
    player_api.set_textures(player, {"character.png"})
    armor:update_player_visuals(player)
end)