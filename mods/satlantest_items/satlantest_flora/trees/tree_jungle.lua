local LEAFDECAY_RADIUS = 2

satlantis.register_block("flora:jungle_log", {
    description = "Jungle Log",
    tiles = {"jungle_log_top.png", "jungle_log_top.png", "jungle_log_side.png"},
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
    on_place = minetest.rotate_node,
    after_destruct = function(pos)
        satlantis.flora.leaves_after_destruct(pos, LEAFDECAY_RADIUS, "flora:jungle_leaves")
    end,
})

satlantis.register_block("flora:jungle_leaves", {
    description = "Jungle Leaves",
    drawtype = "allfaces_optional",
    waving = 1,
    tiles = {"jungle_leaves.png"},
    -- special_tiles = {name .. "_leaves_simple.png"},
    paramtype = "light",
    is_ground_content = false,
    groups = {snappy = 3, leafdecay = 3, flammable = 2, leaves = 1},
    drop = {
        max_items = 1,
        items = {
            {
                items = {"flora:jungle_sapling"},
                rarity = 20,
            },
            {
                items = {"item:stick"},
                rarity = 15,
            },
            {
                items = {"flora:jungle_leaves"},
            }
        }
    },
    on_timer = function(pos)
        satlantis.flora.leaves_on_timer(pos, LEAFDECAY_RADIUS, "flora:jungle_leaves", "flora:jungle_log")
    end,
    after_place_node = satlantis.flora.leaves_after_place,
})

satlantis.register_block("flora:jungle_planks", {
    description = "Jungle Planks",
    paramtype2 = "facedir",
    place_param2 = 0,
    tiles = {"jungle_planks.png"},
    is_ground_content = false,
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

minetest.register_alias("default:jungletree", "flora:jungle_log")
minetest.register_alias("default:jungleleaves", "flora:jungle_leaves")

satlantis.register_block("flora:jungle_sapling", {
    description = "Jungle Sapling",
    drawtype = "plantlike",
    tiles = {"jungle_sapling.png"},
    inventory_image = "jungle_sapling.png",
    wield_image = "jungle_sapling.png",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    on_timer = satlantis.flora.sapling_on_timer("flora:jungle_sapling", "soil", 2),
    grow = function(pos)
        local shape = 0
        for i = 0, 8 do
            shape = bit.lshift(shape, 1)
            if minetest.get_node(vector.new(i % 3 - 1, 0, math.floor(i / 3) - 1) + pos).name == "flora:jungle_sapling" then
                shape = bit.bor(shape, 1)
            end
        end

        -- valid shapes: 000 011 011, 000 110 110, 011 011 000, 110 110 000
        -- bytes:        0    1    B, 0    3    6, 0    D    8, 1    B    0
        local emergent_offset = nil
        if bit.band(shape, 0x01B) == 0x01B then
            emergent_offset = vector.zero()
        elseif bit.band(shape, 0x036) == 0x036 then
            emergent_offset = vector.new(-1, 0, 0)
        elseif bit.band(shape, 0x0D8) == 0x0D8 then
            emergent_offset = vector.new(0, 0, -1)
        elseif bit.band(shape, 0x1B0) == 0x1B0 then
            emergent_offset = vector.new(-1, 0, -1)
        end

        if emergent_offset then
            minetest.place_schematic(
                pos + emergent_offset + vector.new(-3, -5, -3),
                satlantis.flora.MODPATH .. "/schematics/trees/tree_jungle_emergent.mts",
                "random", nil, false
            )
        else
            minetest.place_schematic(
                pos + vector.new(-2, -1, -2),
                satlantis.flora.MODPATH .. "/schematics/trees/tree_jungle.mts",
                "random", nil, false
            )
        end
    end,
    selection_box = {
        type = "fixed",
        fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, 7 / 16, 4 / 16}
    },
    groups = {snappy = 2, dig_immediate = 3, flammable = 2, attached_node = 1, sapling = 1},
    on_construct = satlantis.flora.sapling_on_construct,
})

satlantis.doors.register_door("jungle_door", {
    description = "Jungle Door",
    tiles = {"jungle_door.png"},
    sounds = {
        open = "doors_door_open",
        close = "doors_door_close",
    },
    inventory_image = "jungle_door_inv.png",
    groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, wood = 1},
})

satlantis.walls.register_fence("jungle_fence", {
	description = "Jungle Fence",
	tiles = {"jungle_fence.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
})
