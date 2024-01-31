minetest.register_alias("default:aspen_tree", "flora:aspen_log")
minetest.register_alias("default:aspen_leaves", "flora:aspen_leaves")

local LEAFDECAY_RADIUS = 3

satlantis.flora.tree_schematics.aspen = satlantis.flora.MODPATH .. "/schematics/trees/tree_aspen.mts"

satlantis.register_block("flora:aspen_log", {
    description = "Aspen Log",
    tiles = {"aspen_log_top.png", "aspen_log_top.png", "aspen_log_side.png"},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
    on_place = minetest.rotate_node,
    after_destruct = function(pos)
        satlantis.flora.leaves_after_destruct(pos, LEAFDECAY_RADIUS, "flora:aspen_leaves")
    end,
})

satlantis.register_block("flora:aspen_leaves", {
    description = "Aspen Leaves",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"aspen_leaves.png"},
    -- special_tiles = {name .. "_leaves_simple.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
    drop = {
        max_items = 1,
        items = {
            {
                items = {"flora:aspen_sapling"},
                rarity = 20,
            },
            {
                items = {"item:stick"},
                rarity = 15,
            },
            {
                items = {"flora:aspen_leaves"},
            }
        }
    },
    on_timer = function(pos)
        satlantis.flora.leaves_on_timer(pos, LEAFDECAY_RADIUS, "flora:aspen_leaves", "flora:aspen_log")
    end,
    after_place_node = satlantis.flora.leaves_after_place,
})

satlantis.register_block("flora:aspen_planks", {
    description = "Aspen Planks",
    paramtype2 = "facedir",
    place_param2 = 0,
    tiles = {"aspen_planks.png"},
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.register_block("flora:aspen_sapling", {
    description = "Aspen Sapling",
    drawtype = "plantlike",
    tiles = {"aspen_sapling.png"},
    inventory_image = "aspen_sapling.png",
    wield_image = "aspen_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_timer = satlantis.flora.sapling_on_timer("flora:aspen_sapling", "soil", 13),
    grow = function(pos)
        minetest.place_schematic(
            vector.add(pos, vector.new(-2, -1, -2)),
            satlantis.flora.tree_schematics.aspen,
            "0", nil, false
        )
    end,
    selection_box = {
        type = "fixed",
        fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    on_construct = satlantis.flora.sapling_on_construct,
})

satlantis.doors.register_door("aspen_door", {
    description = "Aspen Door",
    tiles = {"aspen_door.png"},
    sounds = {
        open = "doors_door_open",
        close = "doors_door_close",
    },
    inventory_image = "aspen_door_inv.png",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.walls.register_fence("aspen_fence", {
	description = "Aspen Fence",
	tiles = {"aspen_fence.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
})
