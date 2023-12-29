minetest.register_on_joinplayer(function(player)
    player:set_pos(satlantis.map.config.spawn)
    player:set_physics_override({
        gravity = 0,
    })
    player:hud_set_flags({
        basic_debug = false,
    })
    player:set_minimap_modes({{type = "off", label = " "}}, 0)
end)
