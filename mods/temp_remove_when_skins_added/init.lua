-- set players' skins to character.png when they join
minetest.register_on_joinplayer(function(player)
    player_api.set_texture(player, 1, "character.png")
    local textures = player:get_properties().textures
    textures[1] = "character.png"
    player:set_properties({ textures = textures })
    armor:update_player_visuals(player)
end)