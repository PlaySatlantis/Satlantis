satlantis.register_block("geo:dirt_loose", {
    description = "Loose Soil",
    tiles = {"dirt_loose.png", "dirt.png"},
    groups = {crumbly = 3, soil = 2, farmland = 1, oddly_breakable_by_hand = 1},
    drop = "geo:dirt",
})

satlantis.register_block("geo:dirt_loose_wet", {
    description = "Wet Loose Soil",
    tiles = {"dirt_loose_wet.png", "dirt.png"},
    groups = {crumbly = 3, not_in_creative_inventory = 1, soil = 3, wet = 1, farmland = 1, oddly_breakable_by_hand = 1},
    drop = "geo:dirt",
})

local WATER_SATURATION_RADIUS = 3

-- Very naive farmland
minetest.register_abm({
    label = "wet dirt",
    nodenames = {"group:farmland"},
    interval = 15,
    chance = 3,
    action = function(pos, node)
        if minetest.find_node_near(pos, WATER_SATURATION_RADIUS, {"group:water"}) then
            if minetest.get_item_group(node.name, "wet") == 0 then
                minetest.set_node(pos, {name = "geo:dirt_loose_wet"})
            end
        else
            if not minetest.find_node_near(pos, WATER_SATURATION_RADIUS, {"ignore"}) then
                if minetest.get_item_group(node.name, "wet") ~= 0 then
                    minetest.set_node(pos, {name = "geo:dirt_loose"})
                end
            end
        end
    end,
})

satlantis.crops.calculate_growth_rate = function(pos, name)
    local def = minetest.registered_nodes[name] or {}
    local crop_def = def.crop

    if not crop_def then return end
    if not crop_def.next_stage then return end

    local rate = crop_def.growth_rate -- base growth rate

    local min_light = (crop_def.desired_light or 13) + 1 -- desired light level
    local min_soil = (crop_def.desired_soil or 3) + 1 -- desired soil quality

    local natural_light = minetest.get_natural_light(pos)
    local artificial_light = minetest.get_node_light(pos)

    -- Natural light is slightly better, but any light will do
    local light_level = math.max(natural_light * 1.1, artificial_light) + 1
    local light_quality = light_level / min_light

    local soil_node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})
    local soil_quality = (minetest.get_item_group(soil_node.name, "soil") + 1) / min_soil

    rate = rate * (1 / soil_quality)
    rate = rate * (1 / light_quality)

    minetest.chat_send_all(table.concat({
        "br" .. crop_def.growth_rate,
        "ml" .. min_light,
        "ll" .. light_level,
        "lq" .. light_quality,
        "ms" .. min_soil,
        "sq" .. soil_quality,
        "ar" .. rate,
    }, ", "))

    return rate, crop_def.variance or 0
end

satlantis.crops.start_timer = function(pos)
    local rate, variance = satlantis.crops.calculate_growth_rate(pos, minetest.get_node(pos).name)
    if rate then
        minetest.get_node_timer(pos):start(rate + (math.random() - 0.5) * variance)
    end
end

satlantis.crops.on_timer = function(pos)
    local node = minetest.get_node(pos)
    local crop_def = minetest.registered_nodes[node.name].crop or {}

    if crop_def.next_stage then
        local next_stage = minetest.registered_nodes[crop_def.next_stage]

        if next_stage then
            minetest.swap_node(pos, {name = crop_def.next_stage, param2 = next_stage.place_param2})

            if next_stage.crop then
                satlantis.crops.start_timer(pos)
            end
        end
    end

    return
end

satlantis.crops.seed_on_place = function(stack, placer, pointed)
    if pointed.type ~= "node" then return end

    local def = minetest.registered_items[stack:get_name()]
    if not def.crop then return end
    local next_stage = minetest.registered_nodes[def.crop.next_stage]

    local node = minetest.get_node(pointed.under)
    local above = minetest.get_node(pointed.above)

    if not next_stage then return end
    if not minetest.registered_nodes[above.name].buildable_to then return end
    if minetest.get_node_group(node.name, "soil") == 0 then return end -- must be soil
    if pointed.above.y ~= pointed.under.y + 1 then return end -- must be top of node

    minetest.set_node(pointed.above, {name = def.crop.next_stage, param2 = next_stage.place_param2})
    satlantis.crops.start_timer(pointed.above)

    if not minetest.is_creative_enabled(placer:get_player_name()) then
        stack:take_item()
    end

    return stack
end

minetest.register_lbm({
    name = ":flora:start_crop_timers",
    nodenames = {"group:growing", "flora:wheat_stage1"},
    run_at_every_load = true,
    action = function(pos)
        satlantis.crops.start_timer(pos)
    end,
})
