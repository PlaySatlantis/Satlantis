local light_level = satlantis.config:get("light_level") or 0.8

local setup_player = function(player)
    player:hud_set_flags({
        -- basic_debug = false,
    })
    player:set_minimap_modes({{type = "off", label = " "}}, 0)

    player:set_physics_override({
        gravity = 5,
        jump = 1.1,
    })

    player:set_sky({
        type = "skybox",
        textures = {
            "skybox_top.png",
            "skybox_bot.png",
            "skybox_front.png",
            "skybox_back.png",
            "skybox_right.png",
            "skybox_left.png",
        },
        clouds = false,
        base_color = "#0c495e",
    })

    player:set_stars({
        day_opacity = 1,
        count = 3000,
        scale = 0.3,
    })

    player:set_sun({
        visible = false,
        sunrise_visible = false,
    })

    player:set_moon({
        visible = false,
    })

    player:override_day_night_ratio(light_level)
end

minetest.register_on_joinplayer(function(player)
    player:set_pos(satlantis.map.config.spawn)
    setup_player(player)
end)
