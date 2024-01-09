local LEAFDECAY_RADIUS = 3

satlantis.register_block("flora:oak_log", {
    description = "Oak Log",
    tiles = {"oak_log_top.png", "oak_log_top.png", "oak_log_side.png"},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
    on_place = minetest.rotate_node,
    after_destruct = function(pos)
        satlantis.flora.leaves_after_destruct(pos, LEAFDECAY_RADIUS, "flora:oak_leaves")
    end,
})

satlantis.register_block("flora:oak_leaves", {
    description = "Oak Leaves",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"oak_leaves.png"},
    -- special_tiles = {name .. "_leaves_simple.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
    drop = {
        max_items = 1,
        items = {
            {
                items = {"flora:oak_sapling"},
                rarity = 20,
            },
            {
                items = {"item:stick"},
                rarity = 15,
            },
            {
                items = {"flora:oak_leaves"},
            }
        }
    },
    on_timer = function(pos)
        satlantis.flora.leaves_on_timer(pos, LEAFDECAY_RADIUS, "flora:oak_leaves", "flora:oak_log")
    end,
    after_place_node = satlantis.flora.leaves_after_place,
})

satlantis.register_block("flora:oak_planks", {
    description = "Oak Planks",
    paramtype2 = "facedir",
    place_param2 = 0,
    tiles = {"oak_planks.png"},
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.register_block("flora:oak_sapling", {
    description = "Oak Sapling",
    drawtype = "plantlike",
    tiles = {"oak_sapling.png"},
    inventory_image = "oak_sapling.png",
    wield_image = "oak_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_timer = satlantis.flora.sapling_on_timer("flora:oak_sapling", "soil", 0),
    grow = function(pos)
        minetest.place_schematic(
            vector.add(pos, vector.new(-3, -1, -3)),
            satlantis.flora.MODPATH .. "/schematics/trees/tree_oak.mts",
            "random", nil, false
        )
    end,
    selection_box = {
        type = "fixed",
        fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    on_construct = satlantis.flora.sapling_on_construct,
})

satlantis.doors.register_door("oak_door", {
    description = "Oak Door",
    tiles = {"oak_door.png"},
    sounds = {
        open = "doors_door_open",
        close = "doors_door_close",
    },
    inventory_image = "oak_door_inv.png",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.walls.register_fence("oak_fence", {
	description = "Oak Fence",
	tiles = {"oak_fence.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
})
