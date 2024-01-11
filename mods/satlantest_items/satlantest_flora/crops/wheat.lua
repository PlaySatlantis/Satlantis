satlantis.register_item("flora:wheat_seeds", {
    description = "Wheat Seeds",
    inventory_image = "wheat_seeds.png",
    crop = {
        next_stage = "flora:wheat_crop_stage1",
    },
    on_place = satlantis.crops.seed_on_place,
})

satlantis.register_item("flora:wheat", {
    description = "Wheat",
    inventory_image = "wheat.png",
})

local crop_def = {
    desired_light = 13, -- ideal light level of 13
    growth_rate = 240, -- every 240 seconds
}

local stages = 8
for i = 1, stages do
    local drop = ""
    local crop = nil
    local scale = 1

    if i >= stages * 0.75 then
        drop = {
            items = {
                {
                    items = {"flora:wheat"},
                    rarity = (stages - i) + 1,
                },
                {
                    items = {"flora:wheat"},
                    rarity = (stages - i) * 2,
                },
                {
                    items = {"flora:wheat"},
                    rarity = (stages - i) + 3,
                },
            }
        }
    end

    if i ~= stages then
        crop = {
            next_stage = "flora:wheat_crop_stage" .. i + 1,
            min_light = crop_def.min_light,
            variance = (stages - i) * 8, -- more consistent as it grows
            growth_rate = crop_def.growth_rate
        }
    end

    if i > 5 then
        scale = 2
    end

    satlantis.register_block("flora:wheat_crop_stage" .. i, {
        drawtype = "plantlike",
        waving = 1,
        visual_scale = scale,
        tiles = {"wheat_crop_stage" .. i .. ".png"},
        paramtype = "light",
        paramtype2 = "meshoptions",
        place_param2 = 3,
        walkable = false,
        buildable_to = true,
        drop = drop,
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -5 / 16, 0.5},
        },
        groups = {snappy = 3, flammable = 2, plant = 1, not_in_creative_inventory = 1, attached_node = 1, growing = i < stages and 1 or 0, oddly_breakable_by_hand = 1},
        crop = crop,
        on_timer = satlantis.crops.on_timer,
    })
end
