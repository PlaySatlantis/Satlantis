satlantis.register_item("flora:melon_seeds", {
    description = "Melon Seeds",
    inventory_image = "melon_seeds.png",
    crop = {
        next_stage = "flora:melon_stage1",
    },
    on_place = satlantis.crops.seed_on_place,
})

satlantis.register_item("flora:melon_slice", {
    description = "Melon Slice",
    inventory_image = "melon_slice.png",
})

satlantis.register_block("flora:melon", {
    description = "Melon",
    tiles = {"melon_top.png", "melon_bottom.png", "melon_side.png"},
    paramtype2 = "facedir",
    groups = {choppy = 2, oddly_breakable_by_hand = 1, plant = 1},
})

local rotations = {
    [4] = {vector.new(0, 0, -1), math.floor(45 / 1.5)},
    [16] = {vector.new(1, 0, 0), math.floor(135 / 1.5)},
    [8] = {vector.new(0, 0, 1), math.floor(225 / 1.5)},
    [12] = {vector.new(-1, 0, 0), math.floor(315 / 1.5)},
}

local crop_def = {
    desired_light = 11,
    growth_rate = 180,
    variance = 60,
    can_grow = function(pos)
        for _, offset in pairs(rotations) do
            local adjacent = pos + offset[1]
            local support = adjacent + vector.new(0, -1, 0)
            if minetest.get_node(adjacent).name == "air" then
                if minetest.registered_nodes[minetest.get_node(support).name].walkable then
                    return true
                end
            end
        end
    end,
    on_grow = function(pos)
        for melon_param2, offset in pairs(rotations) do
            local adjacent = pos + offset[1]
            local support = adjacent + vector.new(0, -1, 0)
            if minetest.get_node(adjacent).name == "air" then
                if minetest.registered_nodes[minetest.get_node(support).name].walkable then
                    minetest.set_node(adjacent, {name = "flora:melon", param2 = melon_param2})
                    minetest.set_node(pos, {name = "flora:melon_stage8", param2 = offset[2]})

                    return true
                end
            end
        end
    end,
}

local stages = 8
for i = 1, stages do
    local crop = {}

    if i ~= stages then
        crop.next_stage = "flora:melon_stage" .. i + 1
        crop.min_light = crop_def.min_light
        crop.variance = crop_def.variance
        crop.growth_rate = crop_def.growth_rate
        crop.on_grow = function(pos, node)
            minetest.set_node(pos, {
                name = "flora:melon_stage" .. i + 1,
                param2 = (node.param2 + math.random(-10, 10)) % 240
            })

            satlantis.crops.start_timer(pos)

            return true
        end
    end

    if i == stages - 1 then
        crop.can_grow = crop_def.can_grow
        crop.on_grow = crop_def.on_grow
    end

    satlantis.register_block("flora:melon_stage" .. i, {
        drawtype = "plantlike",
        waving = 1,
        tiles = {"melon_stage" .. i .. ".png"},
        paramtype = "light",
        paramtype2 = "degrotate",
        random_param2 = i == 1 and {0, 240},
        walkable = false,
        buildable_to = true,
        drop = "",
        selection_box = {
            type = "fixed",
            fixed = {-0.5, -0.5, -0.5, 0.5, -5 / 16, 0.5},
        },
        groups = {snappy = 3, flammable = 2, plant = 1, not_in_creative_inventory = 1, attached_node = 1, growing = i < stages and 1 or 0, oddly_breakable_by_hand = 1},
        crop = crop,
        on_timer = satlantis.crops.on_timer,
    })
end
