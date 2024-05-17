--[[
    Everness. Never ending discovery in Everness mapgen.
    Copyright (C) 2024 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

--]]

local S = minetest.get_translator(minetest.get_current_modname())

Everness:register_node('everness:mineral_cave_stone', {
    description = S('Mineral Cave Stone'),
    tiles = {
        {
            name = 'everness_mineral_stone_under_top.png',
            align_style = 'world',
            scale = 2
        },
        {
            name = 'everness_mineral_stone_under_top.png',
            align_style = 'world',
            scale = 2
        },
        {
            name = 'everness_mineral_stone_under.png',
            align_style = 'world',
            scale = 2
        }
    },
    drop = 'everness:mineral_cave_cobblestone',
    groups = {
        -- MTG
        cracky = 3,
        -- MCL
        pickaxey = 1,
        building_block = 1,
        material_stone = 1,
        -- ALL
        stone = 1,
    },
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_silk_touch_drop = true,
    sounds = Everness.node_sound_stone_defaults(),
})

Everness:register_node('everness:mineral_cave_cobblestone', {
    description = S('Mineral Cave Cobblestone'),
    is_ground_content = false,
    tiles = {
        {
            name = 'everness_mineral_cobblestone_under.png',
            align_style = 'world',
            scale = 2
        }
    },
    groups = {
        -- MTG
        cracky = 3,
        -- MCL
        pickaxey = 1,
        building_block = 1,
        material_stone = 1,
        -- ALL
        stone = 2,
    },
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_silk_touch_drop = true,
    sounds = Everness.node_sound_stone_defaults(),
})

Everness:register_node('everness:mineral_lava_stone', {
    description = S('Mineral Lava Stone with lava'),
    is_ground_content = false,
    -- Textures of node; +Y, -Y, +X, -X, +Z, -Z
    tiles = {
        {
            name = 'everness_mineral_lava_stone_animated.png',
            align_style = 'world',
            scale = 2,
            animation = {
                type = 'vertical_frames',
                aspect_w = 16,
                aspect_h = 16,
                length = 6.4,
            },
        },
        {
            name = 'everness_mineral_lava_stone_bottom.png',
            align_style = 'world',
            scale = 2
        },
        {
            name = 'everness_mineral_lava_stone_side.png',
            align_style = 'world',
            scale = 2
        }
    },
    drop = 'everness:mineral_lava_stone_dry',
    groups = {
        -- MTG
        cracky = 3,
        -- MCL
        pickaxey = 1,
        building_block = 1,
        material_stone = 1,
        -- ALL
        stone = 1,
    },
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_silk_touch_drop = true,
    light_source = 3,
    sounds = Everness.node_sound_stone_defaults(),
})

Everness:register_node('everness:mineral_lava_stone_dry', {
    description = S('Mineral Lava Stone without lava'),
    is_ground_content = false,
    -- Textures of node; +Y, -Y, +X, -X, +Z, -Z
    tiles = {
        {
            name = 'everness_mineral_lava_stone_bottom.png',
            align_style = 'world',
            scale = 2
        }
    },
    groups = {
        -- MTG
        cracky = 3,
        -- MCL
        pickaxey = 1,
        building_block = 1,
        material_stone = 1,
        -- ALL
        stone = 1,
    },
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_silk_touch_drop = true,
    sounds = Everness.node_sound_stone_defaults(),
})

Everness:register_node('everness:mineral_lava_stone_with_moss', {
    description = S('Mineral Lava Stone with moss'),
    is_ground_content = false,
    -- Textures of node; +Y, -Y, +X, -X, +Z, -Z
    tiles = {
        {
            name = 'everness_mineral_cave_moss.png',
            align_style = 'world',
            scale = 2
        },
        {
            name = 'everness_mineral_cave_moss.png',
            align_style = 'world',
            scale = 2
        },
        {
            name = 'everness_mineral_cave_moss_side.png',
            align_style = 'world',
            scale = 2
        },
    },
    drop = 'everness:mineral_lava_stone_dry',
    groups = {
        -- MTG
        cracky = 3,
        -- Everness
        everness_spreading_dirt_type_under = 1,
        -- MCL
        pickaxey = 1,
        building_block = 1,
        material_stone = 1,
        -- ALL
        stone = 1,
    },
    _mcl_blast_resistance = 6,
    _mcl_hardness = 1.5,
    _mcl_silk_touch_drop = true,
    light_source = 3,
    sounds = Everness.node_sound_stone_defaults(),
})

for i = 1, 7 do
    local last = i == 7

    Everness:register_node('everness:volcanic_spike_' .. i, {
        description = S('Volcanic Spike') .. ' ' .. i,
        tiles = { 'everness_volcanic_rock.png' },
        sounds = Everness.node_sound_stone_defaults(),
        drawtype = 'nodebox',
        groups = {
            -- MTG
            cracky = 1,
            level = 2,
            stone = 1,
            -- MCL
            pickaxey = 5,
            building_block = 1,
            material_stone = 1,
        },
        _mcl_blast_resistance = 1200,
        _mcl_hardness = 50,
        is_ground_content = false,
        node_box = {
            type = 'fixed',
            fixed = {
                {
                    (-8 + i) / 16,
                    -8 / 16,
                    (-8 + i) / 16,
                    (8 - i) / 16,
                    8 / 16,
                    (8 - i) / 16
                }
            }
        },
        selection_box = {
            type = 'fixed',
            fixed = {
                (-8 + i - 1) / 16,
                -8 / 16,
                (-8 + i - 1) / 16,
                (8 - i + 1) / 16,
                8 / 16,
                (8 - i + 1) / 16
            }
        },
        collision_box = {
            type = 'fixed',
            fixed = {
                (-8 + i) / 16,
                -8 / 16,
                (-8 + i) / 16,
                (8 - i) / 16,
                8 / 16,
                (8 - i) / 16
            },
        },
        move_resistance = last and 7 or 0,
        damage_per_second = last and 4 or 0,
        drowning = last and 1 or 0,
        walkable = not last,
        climbable = last,
    })

    Everness:register_node('everness:mineral_cave_stone_spike_' .. i, {
        description = S('Mineral Lava Stone Spike') .. ' ' .. i,
        -- Textures of node; +Y, -Y, +X, -X, +Z, -Z
        tiles = {
            {
                name = 'everness_mineral_stone_under_top.png',
                align_style = 'world',
                scale = 2
            },
            {
                name = 'everness_mineral_stone_under_top.png',
                align_style = 'world',
                scale = 2
            },
            {
                name = 'everness_mineral_stone_under.png',
                align_style = 'world',
                scale = 2
            }
        },
        groups = {
            -- MTG
            cracky = 3,
            -- MCL
            pickaxey = 1,
            building_block = 1,
            material_stone = 1,
            -- ALL
            stone = 1,
        },
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        _mcl_silk_touch_drop = true,
        sounds = Everness.node_sound_stone_defaults(),
        drawtype = 'nodebox',
        is_ground_content = false,
        node_box = {
            type = 'fixed',
            fixed = {
                {
                    (-8 + i) / 16,
                    -8 / 16,
                    (-8 + i) / 16,
                    (8 - i) / 16,
                    8 / 16,
                    (8 - i) / 16
                }
            }
        },
        selection_box = {
            type = 'fixed',
            fixed = {
                (-8 + i - 1) / 16,
                -8 / 16,
                (-8 + i - 1) / 16,
                (8 - i + 1) / 16,
                8 / 16,
                (8 - i + 1) / 16
            }
        },
        collision_box = {
            type = 'fixed',
            fixed = {
                (-8 + i) / 16,
                -8 / 16,
                (-8 + i) / 16,
                (8 - i) / 16,
                8 / 16,
                (8 - i) / 16
            },
        },
        move_resistance = last and 7 or 0,
        damage_per_second = last and 4 or 0,
        drowning = last and 1 or 0,
        walkable = not last,
        climbable = last,
    })

    Everness:register_node('everness:mineral_lava_stone_spike_' .. i, {
        description = S('Mineral Lava Stone Spike') .. ' ' .. i,
        -- Textures of node; +Y, -Y, +X, -X, +Z, -Z
        tiles = {
            {
                name = 'everness_mineral_lava_stone_animated.png',
                align_style = 'world',
                scale = 2,
                animation = {
                    type = 'vertical_frames',
                    aspect_w = 16,
                    aspect_h = 16,
                    length = 6.4,
                },
            },
        },
        groups = {
            -- MTG
            cracky = 3,
            -- MCL
            pickaxey = 1,
            building_block = 1,
            material_stone = 1,
            -- ALL
            stone = 1,
        },
        _mcl_blast_resistance = 6,
        _mcl_hardness = 1.5,
        _mcl_silk_touch_drop = true,
        sounds = Everness.node_sound_stone_defaults(),
        drawtype = 'nodebox',
        is_ground_content = false,
        node_box = {
            type = 'fixed',
            fixed = {
                {
                    (-8 + i) / 16,
                    -8 / 16,
                    (-8 + i) / 16,
                    (8 - i) / 16,
                    8 / 16,
                    (8 - i) / 16
                }
            }
        },
        selection_box = {
            type = 'fixed',
            fixed = {
                (-8 + i - 1) / 16,
                -8 / 16,
                (-8 + i - 1) / 16,
                (8 - i + 1) / 16,
                8 / 16,
                (8 - i + 1) / 16
            }
        },
        collision_box = {
            type = 'fixed',
            fixed = {
                (-8 + i) / 16,
                -8 / 16,
                (-8 + i) / 16,
                (8 - i) / 16,
                8 / 16,
                (8 - i) / 16
            },
        },
        light_source = 12,
        move_resistance = last and 7 or 0,
        damage_per_second = last and 4 or 0,
        drowning = last and 1 or 0,
        walkable = not last,
        climbable = last,
    })
end

Everness:register_node('everness:lava_tree', {
    description = S('Lava Tree Trunk'),
    short_description = S('Lava Tree Trunk'),
    tiles = {
        { name = 'everness_lava_tree_top.png' },
        { name = 'everness_lava_tree_top.png' },
        {
            name = 'everness_lava_tree.png',
            align_style = 'world',
            scale = 2,
        },
    },
    paramtype2 = 'facedir',
    is_ground_content = false,
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 5,
        -- ALL
        tree = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
    sounds = Everness.node_sound_wood_defaults(),
    on_place = minetest.rotate_node
})

Everness:register_node('everness:lava_tree_with_lava', {
    description = S('Lava Tree Trunk with Lava Veins'),
    short_description = S('Lava Tree Trunk with Lava Veins'),
    tiles = {
        { name = 'everness_lava_tree_top.png' },
        { name = 'everness_lava_tree_top.png' },
        {
            name = 'everness_lava_tree_animated.png',
            align_style = 'world',
            scale = 8,
            animation = {
                type = 'vertical_frames',
                aspect_w = 16,
                aspect_h = 16,
                length = 8,
            },
        },
    },
    paramtype2 = 'facedir',
    is_ground_content = false,
    groups = {
        -- MTG
        choppy = 2,
        oddly_breakable_by_hand = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 5,
        -- ALL
        tree = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 2,
    _mcl_hardness = 2,
    sounds = Everness.node_sound_wood_defaults(),
    on_place = minetest.rotate_node,
    light_source = 3,
})

Everness:register_node('everness:lava_tree_wood', {
    description = S('Lava Tree Wood Planks'),
    paramtype2 = 'facedir',
    place_param2 = 0,
    tiles = {
        {
            name = 'everness_lava_tree_wood.png',
            align_style = 'world',
            scale = 2
        },
    },
    is_ground_content = false,
    groups = {
        -- MTG
        choppy = 3,
        oddly_breakable_by_hand = 2,
        -- Everness
        everness_wood = 1,
        -- MCL
        handy = 1,
        axey = 1,
        building_block = 1,
        material_wood = 1,
        fire_encouragement = 5,
        fire_flammability = 20,
        -- ALL
        flammable = 3,
        wood = 1,
    },
    _mcl_blast_resistance = 3,
    _mcl_hardness = 2,
    sounds = Everness.node_sound_wood_defaults(),
})

Everness:register_node('everness:lava_tree_sapling', {
    description = S('Lava') .. ' ' .. S('Tree') .. ' ' .. S('Sapling'),
    short_description = S('Lava') .. ' ' .. S('Tree') .. ' ' .. S('Sapling'),
    drawtype = 'plantlike',
    tiles = { 'everness_lava_tree_sapling.png' },
    inventory_image = 'everness_lava_tree_sapling.png',
    wield_image = 'everness_lava_tree_sapling.png',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = 'fixed',
        fixed = { -4 / 16, -0.5, -4 / 16, 4 / 16, 4 / 16, 4 / 16 }
    },
    groups = {
        -- MTG
        snappy = 2,
        flammable = 2,
        -- X Farming
        compost = 30,
        -- MCL
        plant = 1,
        non_mycelium_plant = 1,
        deco_block = 1,
        dig_by_water = 1,
        dig_by_piston = 1,
        destroy_by_lava_flow = 1,
        compostability = 30,
        -- ALL
        dig_immediate = 3,
        attached_node = 1,
        sapling = 1,
    },
    _mcl_blast_resistance = 0,
    _mcl_hardness = 0,
    sounds = Everness.node_sound_leaves_defaults(),
    on_timer = function(pos)
        Everness.grow_sapling(pos)
    end,
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(math.random(300, 1500))
    end,
    on_place = function(itemstack, placer, pointed_thing)
        local on_place_props = {
            sapling_name = 'everness:lava_tree_sapling',
            minp_relative = { x = -7, y = 1, z = -7 },
            maxp_relative = { x = 7, y = 13, z = 7 },
            interval = 4,
        }

        return Everness:sapling_on_place(itemstack, placer, pointed_thing, on_place_props)
    end,
})

Everness:register_node('everness:lava_tree_leaves', {
    description = S('Lava') .. ' ' .. S('Tree') .. ' ' .. S('Leaves'),
    short_description = S('Lava') .. ' ' .. S('Tree') .. ' ' .. S('Leaves'),
    drawtype = 'allfaces_optional',
    tiles = {
        {
            name = 'everness_lava_tree_leaves.png',
            align_style = 'world',
            scale = 2,
        },
    },
    special_tiles = {
        {
            name = 'everness_lava_tree_leaves.png',
            align_style = 'world',
            scale = 2,
        },
    },
    paramtype = 'light',
    is_ground_content = false,
    sunlight_propagates = true,
    groups = {
        -- MTG
        snappy = 3,
        leafdecay = 3,
        -- X Farming
        compost = 30,
        -- MCL
        handy = 1,
        hoey = 1,
        shearsy = 1,
        swordy = 1,
        dig_by_piston = 1,
        fire_encouragement = 30,
        fire_flammability = 60,
        deco_block = 1,
        compostability = 30,
        -- ALL
        flammable = 2,
        leaves = 1,
    },
    _mcl_shears_drop = true,
    _mcl_blast_resistance = 0.2,
    _mcl_hardness = 0.2,
    _mcl_silk_touch_drop = true,
    drop = {
        max_items = 1,
        items = {
            {
                -- player will get sapling with 1/100 chance
                items = { 'everness:lava_tree_sapling' },
                rarity = 100,
            },
            {
                -- player will get leaves only if he get no saplings,
                -- this is because max_items is 1
                items = { 'everness:lava_tree_leaves' },
            }
        }
    },
    sounds = Everness.node_sound_leaves_defaults(),
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        return Everness:after_place_leaves(pos, placer, itemstack, pointed_thing)
    end
})

Everness:register_node('everness:mineral_cave_moss_grass', {
    description = S('Mineral Cave Moss Grass'),
    short_description = S('Mineral Cave Moss Grass'),
    drawtype = 'plantlike',
    waving = 1,
    tiles = { 'everness_mineral_cave_moss_grass.png' },
    inventory_image = 'everness_mineral_cave_moss_grass.png',
    wield_image = 'everness_mineral_cave_moss_grass.png',
    paramtype = 'light',
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {
        -- MTG
        snappy = 3,
        flora = 1,
        -- Everness
        mineral_waters_grass_under = 1,
        -- X Farming
        compost = 30,
        -- MCL
        handy = 1,
        shearsy = 1,
        deco_block = 1,
        plant = 1,
        non_mycelium_plant = 1,
        fire_encouragement = 60,
        fire_flammability = 100,
        dig_by_water = 1,
        destroy_by_lava_flow = 1,
        compostability = 30,
        -- ALL
        attached_node = 1,
        flammable = 2,
    },
    _mcl_blast_resistance = 0,
    _mcl_hardness = 0,
    sounds = Everness.node_sound_leaves_defaults(),
    selection_box = {
        type = 'fixed',
        fixed = { -6 / 16, -0.5, -6 / 16, 6 / 16, 4 / 16, 6 / 16 },
    },
    light_source = 7
})
