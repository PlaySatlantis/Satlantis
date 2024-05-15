local barrier = minetest.get_content_id("satlantis_mcl_nodes:mcl_core__barrier")
local bedrock = minetest.get_content_id("satlantis_mcl_nodes:mcl_core__bedrock")
local stone = minetest.get_content_id("default:stone")
local lava = minetest.get_content_id("default:lava_source")
local obsidian = minetest.get_content_id("default:obsidian")
local air = minetest.get_content_id("air")


-- creates a terrain noise
luamap.register_noise("bedrock",{
    type = "2d",
    np_vals = {
        offset = 0,
        scale = 1,
        spread = {x=384, y=256, z=384},
        seed = 5900033,
        octaves = 5,
        persist = 0.63,
        lacunarity = 2.0,
        flags = ""
    },
    y_min = -1500,
    y_max = -900
})




-- creates a terrain noise
luamap.register_noise("gape",{
    type = "2d",
    np_vals = {
        offset = 0,
        scale = 1,
        spread = {x=100, y=100, z=100},
        seed = 25432,
        octaves = 5,
        persist = 0.63,
        lacunarity = 2.0,
        flags = ""
    },
    y_min = -1500,
    y_max = -900
})






local lava_level = -1000

local old_logic = luamap.logic

function luamap.logic(noise_vals,x,y,z,seed,original_content)

    -- get any terrain defined in another mod
    local content = old_logic(noise_vals,x,y,z,seed,original_content)

    if y > -1500 and y < -900 then
        if y < (lava_level + 20 - (noise_vals.gape * 40)) then
            content = air
        end
        if y < lava_level then
            content = lava
        end
        if y < (lava_level - 10 - (noise_vals.bedrock * 20))  and y > (lava_level - 30 - (noise_vals.bedrock * 20)) then
            content = bedrock
        end
    end

    if y > 8000 and y < 8010 then
        content = barrier
    end

    return content
end


-- handle players' skybox 
local underground_players = {}
minetest.register_globalstep(function(dtime)
    local players = minetest.get_connected_players()
    for _, player in pairs(players) do
        local pos = player:get_pos()
        if pos.y < -100 then
            -- player is underground, set all to black
            -- underground_players[player:get_player_name()] = true
            -- set sky
            player:set_sky({
                sky_color = {
                    day_sky = {"#000000"},
                    day_horizon = {"#000000"},
                    dawn_sky = {"#000000"},
                    dawn_horizon = {"#000000"},
                    night_sky = {"#000000"},
                    night_horizon = {"#000000"},
                    fog_sun_tint = {"#000000"},
                    fog_moon_tint = {"#000000"},
                    fog_tint_type = "default"
                },
                clouds = false,
                -- TODO; implement fog for 5.9 clients/server
            })
            player:set_sun({visible = false})
            player:set_moon({visible = false})
            player:set_stars({visible = false})
        elseif pos.y > -100 and pos.y < 8000 then
            -- restore sky
            player:set_sky()
            player:set_sun()
            player:set_moon()
            player:set_stars()
            
        end
    end
end)