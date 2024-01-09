local LEAFDECAY_RADIUS = 3

satlantis.register_block("flora:spruce_log", {
    description = "Spruce Log",
    tiles = {"spruce_log_top.png", "spruce_log_top.png", "spruce_log_side.png"},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
    on_place = minetest.rotate_node,
    after_destruct = function(pos)
        satlantis.flora.leaves_after_destruct(pos, LEAFDECAY_RADIUS, "flora:spruce_leaves")
    end,
})

satlantis.register_block("flora:spruce_leaves", {
    description = "Spruce Needles",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"spruce_leaves.png"},
    -- special_tiles = {name .. "_leaves_simple.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
    drop = {
        max_items = 1,
        items = {
            {
                items = {"flora:spruce_sapling"},
                rarity = 20,
            },
            {
                items = {"item:stick"},
                rarity = 15,
            },
            {
                items = {"flora:spruce_leaves"},
            }
        }
    },
    on_timer = function(pos)
        satlantis.flora.leaves_on_timer(pos, LEAFDECAY_RADIUS, "flora:spruce_leaves", "flora:spruce_log")
    end,
    after_place_node = satlantis.flora.leaves_after_place,
})

satlantis.register_block("flora:spruce_planks", {
    description = "Spruce Planks",
    paramtype2 = "facedir",
    place_param2 = 0,
    tiles = {"spruce_planks.png"},
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.register_block("flora:spruce_sapling", {
    description = "Spruce Sapling",
    drawtype = "plantlike",
    tiles = {"spruce_sapling.png"},
    inventory_image = "spruce_sapling.png",
    wield_image = "spruce_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_timer = satlantis.flora.sapling_on_timer("flora:spruce_sapling", "soil", 13),
    grow = function(pos)
	    local snowy = minetest.find_node_near(pos, 1, {"group:snowy"})
        local name = "tree_spruce"

        if math.random() > 0.5 then
            name = name .. "_small"
        end

        if snowy then
            name = name .. "_snowy"
        end

        minetest.place_schematic(
            vector.add(pos, vector.new(-2, -1, -2)),
            satlantis.flora.MODPATH .. "/schematics/trees/" .. name .. ".mts",
            snowy and "random" or "0", nil, false
        )
    end,
    selection_box = {
        type = "fixed",
        fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    on_construct = satlantis.flora.sapling_on_construct,
})

satlantis.doors.register_door("spruce_door", {
    description = "Spruce Door",
    tiles = {"spruce_door.png"},
    sounds = {
        open = "doors_door_open",
        close = "doors_door_close",
    },
    inventory_image = "spruce_door_inv.png",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.walls.register_fence("oak_fence", {
	description = "Spruce Fence",
	tiles = {"spruce_fence.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
})
