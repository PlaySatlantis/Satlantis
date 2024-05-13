controls.register_on_press(function(player, key)
    if key == "sneak" then
    player:set_properties({
        visual_size = {x = 1, y = 0.9},
        collisionbox = {-0.3, 0.0, -0.3, 0.5, 1.7, 0.3},
        stepheight = 0.5,
        eye_height = 1.3,
    })
end
end)

controls.register_on_release(function(player, key)
    if key == "sneak" then
        player:set_properties({
            visual_size = {x = 1, y = 1},
            collisionbox = {-0.3, 0.0, -0.3, 0.5, 1.7, 0.3},
            stepheight = 0.6,
			eye_height = 1.47,
        })
    end
end)