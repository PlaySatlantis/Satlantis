satlantis.register_item("flora:corn_seeds", {
    description = "Corn Seeds",
    inventory_image = "corn_seeds.png",
    crop = {
        next_stage = "flora:corn_crop_stage1",
    },
    on_place = satlantis.crops.seed_on_place,
})

satlantis.register_item("flora:corn", {
    description = "Corn",
    inventory_image = "corn.png",
})

local crop_def = {
    desired_light = 13,
    growth_rate = 160,
    variance = 30,
}

local stages = 8
for i = 1, stages do
    local drop = ""
    local crop = nil
    local scale = 1

    if i == 7 then
        drop = {
            items = {
                {
                    items = {"flora:corn"},
                    rarity = 4,
                },
                {
                    items = {"flora:corn"},
                    rarity = 6,
                },
            }
        }
    elseif i == 8 then
        drop = {
            items = {
                {
                    items = {"flora:corn 4"},
                    rarity = 1,
                },
                {
                    items = {"flora:corn 2"},
                    rarity = 2,
                },
                {
                    items = {"flora:corn"},
                    rarity = 4,
                },
                {
                    items = {"flora:corn"},
                    rarity = 4,
                },
            }
        }
    end

    if i ~= stages then
        crop = {
            next_stage = "flora:corn_crop_stage" .. i + 1,
            min_light = crop_def.min_light,
            growth_rate = crop_def.growth_rate
        }
    end

    if i > 3 then
        scale = 2
    end

    satlantis.register_block("flora:corn_crop_stage" .. i, {
        drawtype = "plantlike",
        waving = 1,
        visual_scale = scale,
        tiles = {"corn_crop_stage" .. i .. ".png"},
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
