local SPACE_Y = 20000

local SPACE_SKY = {
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
}

local SPACE_STARS = {
    day_opacity = 1,
    count = 3000,
    scale = 0.3,
}

local SPACE_PHYSICS = {
    gravity = 0.5,
    acceleration_air = 0.33,
}

local DEFAULT_PHYSICS = {
    gravity = 1,
    acceleration_air = 1,
}

local SPACE_LIGHT = 0.8

local function set_player_location_space(player)
    player:set_physics_override(SPACE_PHYSICS)
    player:set_sky(SPACE_SKY)
    player:set_stars(SPACE_STARS)

    player:set_sun({
        visible = false,
        sunrise_visible = false,
    })

    player:set_moon({
        visible = false,
    })

    player:override_day_night_ratio(SPACE_LIGHT)
end

local function set_player_location_default(player)
    player:set_physics_override(DEFAULT_PHYSICS)
    player:set_sky()
    player:set_stars()

    player:set_sun()
    player:set_moon()

    player:override_day_night_ratio()
end

space = {}
space.in_space = {}

function space.set_player_space(name, in_space)
    local player = minetest.get_player_by_name(name)
    if not player then return false end

    if in_space then
        set_player_location_space(player)
        space.in_space[name] = true
    else
        set_player_location_default(player)
        space.in_space[name] = nil
    end

    return true
end

local interval = 0.2
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= interval then
        while timer > interval do
            timer = timer - interval
        end

        for _, player in pairs(minetest.get_connected_players()) do
            local name = player:get_player_name()
            local in_space = space.in_space[name]

            if player:get_pos().y >= SPACE_Y then
                if not in_space then
                    space.set_player_space(name, true)
                end
            else
                if in_space then
                    space.set_player_space(name, false)
                end
            end
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    -- Handle 3d_armor
    player:get_meta():set_int("player_physics_locked", 1)

    if player:get_pos().y >= SPACE_Y then
        set_player_location_space(player)
        space.in_space[player:get_player_name()] = true
    end
end)
