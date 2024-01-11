satlantis.register_item("flora:potato", {
    description = "Potato",
    inventory_image = "potato.png",
    crop = {
        next_stage = "flora:potatoes_stage1",
    },
    on_place = satlantis.crops.seed_on_place,
})

local crop_def = {
    desired_light = 11,
    growth_rate = 140,
    variance = 10,
}

local stages = 7
for i = 1, stages do
    local drop = ""
    local crop = nil

    if i == 7 then
        drop = {
            items = {
                {
                    items = {"flora:potato 3"},
                    rarity = 1,
                },
                {
                    items = {"flora:potato"},
                    rarity = 2,
                },
                {
                    items = {"flora:potato"},
                    rarity = 2,
                },
                {
                    items = {"flora:potato"},
                    rarity = 5,
                },
            }
        }
    end

    if i ~= stages then
        crop = {
            next_stage = "flora:potatoes_stage" .. i + 1,
            min_light = crop_def.min_light,
            growth_rate = crop_def.growth_rate
        }
    end

    satlantis.register_block("flora:potatoes_stage" .. i, {
        drawtype = "plantlike",
        waving = 1,
        tiles = {"potatoes_stage" .. math.ceil(i * 0.5) .. ".png"},
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
