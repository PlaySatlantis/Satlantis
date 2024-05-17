-- add in some vein ores for the regular ores
local default_noise_params = {
    offset  = 0,
    scale   = 3,
    spread  = {x = 125, y = 125, z = 125},
    seed    = 5390,
    octaves = 4,
    persistence = 0.5,
    lacunarity = 2.0,
    flags = "eased",
}

-- make this closer to 2 to make the veins thinner, make it closer to 0 to make the veins thicker (1.85 is a good middle ground)
local default_noise_threshold = 1.85
local higher_threshold = 1.9

local count = 1

local function register_vein_ore(ore_name, y_min, y_max, spread, wherein, noise_params, noise_threshold)
    wherein = wherein or "default:stone"
    noise_params = noise_params or default_noise_params
    noise_params.spread = noise_params.spread or spread
    noise_params.seed = noise_params.seed + count
    count = count + 2000
    minetest.register_ore({
        ore_type       = "vein",
        ore            = ore_name,
        wherein        = wherein,
        y_min          = y_min,
        y_max          = y_max,
        noise_params   = noise_params or default_noise_params,
        noise_threshold = noise_threshold or default_noise_threshold,
    })
end


-- deep ores 

register_vein_ore("default:stone_with_coal", -1000, -750, 125, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_tin", -1000, -750, 145, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_copper", -1000, -750, 145, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_iron", -1000, -750, 150, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_gold", -1000, -750, 175, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_diamond", -1000, -750, 200, nil, nil, higher_threshold)


-- medium ores 

register_vein_ore("default:stone_with_coal", -750, -500, 125, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_tin", -750, -500, 160, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_copper", -750, -500, 160, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_iron", -750, -500, 180, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_gold", -750, -500, 200, nil, nil, higher_threshold)
register_vein_ore("default:stone_with_diamond", -750, -500, 300, nil, nil, higher_threshold)

-- high ores

register_vein_ore("default:stone_with_coal", -500, 10, 125)
register_vein_ore("default:stone_with_tin", -500, 10, 170)
register_vein_ore("default:stone_with_copper", -500, 10, 170)
register_vein_ore("default:stone_with_iron", -500, 10, 200)


-- gold and coal in mountains

register_vein_ore("default:stone_with_gold", 10, 100, 200)
register_vein_ore("default:stone_with_coal", 10, 100, 125)




