minetest.register_on_joinplayer(function(player)
    player:set_pos(satlantis.map.config.spawn)
    player:set_physics_override({
        gravity = 0,
    })
end)
