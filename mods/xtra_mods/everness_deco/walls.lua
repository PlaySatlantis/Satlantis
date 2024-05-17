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

walls.register(
    'everness:coral_desert_cobble_wall',
    S('Coral Cobblestone Wall'),
    { 'everness_coral_desert_cobble.png' },
    'everness:coral_desert_cobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:coral_desert_mossy_cobble_wall',
    S('Coral Mossy Cobblestone Wall'),
    { 'everness_coral_desert_mossy_cobble.png' },
    'everness:coral_desert_mossy_cobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:cursed_brick_wall',
    S('Cursed Brick Wall'),
    { 'everness_cursed_brick.png' },
    'everness:cursed_brick',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:cursed_brick_with_growth_wall',
    S('Cursed Brick with Growth Wall'),
    { 'everness_cursed_brick_with_growth.png' },
    'everness:cursed_brick_with_growth',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_tundra_cobble_wall',
    S('Forsaken Tundra Cobblestone Wall'),
    { 'everness_forsaken_tundra_cobblestone.png' },
    'everness:forsaken_tundra_cobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_tundra_stone_wall',
    S('Forsaken Tundra Stone Wall'),
    { 'everness_forsaken_tundra_stone.png' },
    'everness:forsaken_tundra_stone',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_tundra_brick_wall',
    S('Forsaken Tundra Brick Wall'),
    { 'everness_forsaken_tundra_brick.png' },
    'everness:forsaken_tundra_brick',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:magmacobble_wall',
    S('Magma Cobblestone Wall'),
    {
        {
            name = 'everness_magmacobble_animated.png',
            animation = {
                type = 'vertical_frames',
                aspect_w = 16,
                aspect_h = 16,
                length = 3.0,
            },
        },
    },
    'everness:magmacobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:volcanic_rock_wall',
    S('Volcanic Rock Wall'),
    { 'everness_volcanic_rock.png' },
    'everness:volcanic_rock',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:volcanic_rock_with_magma_wall',
    S('Volcanic Rock with Magma Wall'),
    {
        {
            name = 'everness_volcanic_rock_with_magma_animated.png',
            animation = {
                type = 'vertical_frames',
                aspect_w = 16,
                aspect_h = 16,
                length = 3.0,
            },
        },
    },
    'everness:volcanic_rock_with_magma',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:coral_bones_block_wall',
    S('Coral Bones Block Wall'),
    { 'everness_coral_bones_block.png' },
    'everness:coral_bones_block',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:coral_bones_brick_wall',
    S('Coral Bones Brick Wall'),
    { 'everness_coral_bones_brick.png' },
    'everness:coral_bones_brick',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:coral_deep_ocean_sandstone_brick_wall',
    S('Coral Bones Brick Wall'),
    { 'everness_deep_ocean_sandstone_brick.png' },
    'everness:coral_deep_ocean_sandstone_brick',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:coral_deep_ocean_sandstone_block_wall',
    S('Coral Bones Brick Wall'),
    { 'everness_deep_ocean_sandstone_block.png' },
    'everness:coral_deep_ocean_sandstone_block',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:crystal_cobble_wall',
    S('Crystal Cobblestone Wall'),
    { 'everness_crystal_cobble.png' },
    'everness:crystal_cobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:crystal_mossy_cobble_wall',
    S('Crystal Mossy Cobblestone Wall'),
    { 'everness_crystal_mossy_cobble.png' },
    'everness:crystal_mossy_cobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:cursed_sandstone_brick_wall',
    S('Cursed Sandstone Brick Wall'),
    { 'everness_cursed_sandstone_brick.png' },
    'everness:cursed_sandstone_brick',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:cursed_sandstone_block_wall',
    S('Cursed Sandstone Block Wall'),
    { 'everness_cursed_sandstone_block.png' },
    'everness:cursed_sandstone_block',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:cursed_stone_carved_wall',
    S('Cursed Stone Carved Wall'),
    {
        {
            name = 'everness_cursed_stone_carved.png',
            align_style = 'world',
            scale = 2
        }
    },
    'everness:cursed_stone_carved',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_desert_cobble_wall',
    S('Forsaken Desert Cobblestone Wall'),
    { 'everness_forsaken_desert_cobble.png' },
    'everness:forsaken_desert_cobble',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_desert_cobble_red_wall',
    S('Forsaken Desert Cobblestone Red Wall'),
    { 'everness_forsaken_desert_cobble_red.png' },
    'everness:forsaken_desert_cobble_red',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_desert_brick_wall',
    S('Forsaken Desert Brick Wall'),
    { 'everness_forsaken_desert_brick.png' },
    'everness:forsaken_desert_brick',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_desert_brick_red_wall',
    S('Forsaken Desert Brick Red Wall'),
    { 'everness_forsaken_desert_brick_red.png' },
    'everness:forsaken_desert_brick_red',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_desert_chiseled_stone_wall',
    S('Forsaken Desert Chiseled Stone'),
    {
        'everness_forsaken_desert_chiseled_stone_top.png',
        'everness_forsaken_desert_chiseled_stone_bottom.png',
        'everness_forsaken_desert_chiseled_stone_side.png'
    },
    'everness:forsaken_desert_chiseled_stone',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:forsaken_desert_engraved_stone_wall',
    S('Forsaken Desert Engraved Stone Wall'),
    { 'everness_forsaken_desert_engraved_stone.png' },
    'everness:forsaken_desert_engraved_stone',
    Everness.node_sound_stone_defaults()
)

-- Mineral Waters Under
walls.register(
    'everness:mineral_cave_stone_wall',
    S('Mineral Cave Stone Wall'),
    {{
        name = 'everness_mineral_stone_under.png',
        align_style = 'world',
        scale = 2
    }},
    'everness:mineral_cave_stone',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:mineral_cave_cobblestone_wall',
    S('Mineral Cave Cobblestone Wall'),
    {{
        name = 'everness_mineral_cobblestone_under.png',
        align_style = 'world',
        scale = 2
    }},
    'everness:mineral_cave_cobblestone',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:mineral_lava_stone_wall',
    S('Mineral Lava Stone with lava Wall'),
    {{
        name = 'everness_mineral_lava_stone_animated.png',
        align_style = 'world',
        scale = 2,
        animation = {
            type = 'vertical_frames',
            aspect_w = 16,
            aspect_h = 16,
            length = 6.4,
        },
    }},
    'everness:mineral_lava_stone',
    Everness.node_sound_stone_defaults()
)

walls.register(
    'everness:mineral_lava_stone_dry_wall',
    S('Mineral Lava Stone without lava Wall'),
    {{
        name = 'everness_mineral_lava_stone_bottom.png',
        align_style = 'world',
        scale = 2
    }},
    'everness:mineral_lava_stone_dry',
    Everness.node_sound_stone_defaults()
)
