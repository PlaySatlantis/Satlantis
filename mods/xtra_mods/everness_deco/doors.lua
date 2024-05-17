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

doors.register('everness:door_bamboo', {
    tiles = { { name = 'everness_door_bamboo.png', backface_culling = true } },
    description = S('Bamboo Door'),
    inventory_image = 'everness_door_bamboo_item.png',
    groups = { node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1 },
    sounds = Everness.node_sound_bamboo_defaults({
        dug = { name = 'everness_bamboo_hit', gain = 1.25 }
    }),
    sound_open = 'everness_door_bamboo_open',
    sound_close = 'everness_door_bamboo_open',
    gain_open = 5,
    gain_close = 5,
    recipe = {
        { 'everness:bamboo_wood', 'everness:bamboo_wood' },
        { 'everness:bamboo_wood', 'everness:bamboo_wood' },
        { 'everness:bamboo_wood', 'everness:bamboo_wood' },
    }
})

doors.register_trapdoor('everness:trapdoor_bamboo', {
    description = S('Bamboo Trapdoor'),
    inventory_image = 'everness_door_trapdoor_bamboo.png',
    wield_image = 'everness_door_trapdoor_bamboo.png',
    tile_front = 'everness_door_trapdoor_bamboo.png',
    tile_side = 'everness_door_trapdoor_bamboo_side.png',
    sounds = Everness.node_sound_bamboo_defaults({
        dug = { name = 'everness_bamboo_hit', gain = 1.25 }
    }),
    sound_open = 'everness_door_bamboo_open',
    sound_close = 'everness_door_bamboo_open',
    gain_open = 5,
    gain_close = 5,
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1 },
})

doors.register_fencegate('everness:gate_bamboo', {
    description = S('Bamboo Wood Fence Gate'),
    texture = 'everness_dry_bamboo_block_side.png^[transformR90',
    material = 'everness:bamboo_wood',
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 }
})

doors.register('everness:door_bone_pyrite', {
    tiles = { { name = 'everness_door_bone_pyrite.png', backface_culling = true } },
    description = S('Bone Pyrit Door'),
    inventory_image = 'everness_door_bone_pyrite_item.png',
    groups = { node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1 },
    sounds = Everness.node_sound_wood_defaults(),
    recipe = {
        { 'everness:pyrite_ingot', 'everness:bone' },
        { 'everness:pyrite_ingot', 'everness:bone' },
        { 'everness:pyrite_ingot', 'everness:bone' },
    }
})

doors.register('everness:door_willow', {
    tiles = { { name = 'everness_door_willow.png', backface_culling = true } },
    description = S('Willow Door'),
    inventory_image = 'everness_door_willow_item.png',
    groups = { node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1 },
    sounds = Everness.node_sound_wood_defaults(),
    recipe = {
        { 'everness:willow_wood', 'everness:willow_wood' },
        { 'everness:willow_wood', 'everness:willow_wood' },
        { 'everness:willow_wood', 'everness:willow_wood' },
    }
})

doors.register('everness:door_crystal_wood', {
    description = S('Crystal Wood Door'),
    tiles = { 'everness_door_crystal_wood.png' },
    inventory_image = 'everness_door_crystal_wood_item.png',
    use_texture_alpha = 'blend',
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
    sounds = Everness.node_sound_glass_defaults(),
    sound_open = 'everness_door_glass_open',
    sound_close = 'everness_door_glass_close',
    gain_open = 0.2,
    gain_close = 0.15,
    recipe = {
        { 'everness:crystal_wood', 'everness:crystal_wood' },
        { 'everness:crystal_wood', 'everness:crystal_wood' },
        { 'everness:crystal_wood', 'everness:crystal_wood' },
    }
})

doors.register_trapdoor('everness:trapdoor_crystal_wood', {
    description = S('Crystal Wood Trapdoor'),
    inventory_image = 'everness_door_trapdoor_crystal_wood.png',
    wield_image = 'everness_door_trapdoor_crystal_wood.png',
    tile_front = 'everness_door_trapdoor_crystal_wood.png',
    tile_side = 'everness_door_trapdoor_crystal_wood_side.png',
    use_texture_alpha = 'blend',
    sounds = Everness.node_sound_glass_defaults(),
    sound_open = 'everness_door_glass_open',
    sound_close = 'everness_door_glass_close',
    gain_open = 0.2,
    gain_close = 0.15,
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
})

doors.register_fencegate('everness:gate_crystal_wood', {
    description = S('Crystal Wood Fence Gate'),
    texture = 'everness_crystal_wood.png^[transformR90',
    material = 'everness:crystal_wood',
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 }
})

doors.register('everness:door_cursed_wood', {
    description = S('Cursed Wood Door'),
    tiles = { 'everness_door_cursed_wood.png' },
    inventory_image = 'everness_door_cursed_wood_item.png',
    use_texture_alpha = 'blend',
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
    sounds = Everness.node_sound_wood_defaults(),
    sound_open = 'everness_creaky_door_open',
    sound_close = 'everness_creaky_door_close',
    gain_open = 0.15,
    gain_close = 0.15,
    recipe = {
        { 'everness:dry_wood', 'everness:dry_wood' },
        { 'everness:dry_wood', 'everness:dry_wood' },
        { 'everness:dry_wood', 'everness:dry_wood' },
    }
})

doors.register_trapdoor('everness:trapdoor_cursed_wood', {
    description = S('Cursed Wood Trapdoor'),
    inventory_image = 'everness_door_trapdoor_cursed_wood.png',
    wield_image = 'everness_door_trapdoor_cursed_wood.png',
    tile_front = 'everness_door_trapdoor_cursed_wood.png',
    tile_side = 'everness_door_trapdoor_cursed_wood_side.png',
    sounds = Everness.node_sound_wood_defaults(),
    sound_open = 'everness_creaky_door_open',
    sound_close = 'everness_creaky_door_close',
    gain_open = 0.15,
    gain_close = 0.15,
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
})

-- Palm Wood

doors.register('everness:door_palm_wood', {
    description = S('Palm Wood Door'),
    tiles = { 'everness_door_palm_wood.png' },
    inventory_image = 'everness_door_palm_wood_item.png',
    use_texture_alpha = 'blend',
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
    sounds = Everness.node_sound_wood_defaults(),
    recipe = {
        { 'everness:palm_tree_wood', 'everness:palm_tree_wood' },
        { 'everness:palm_tree_wood', 'everness:palm_tree_wood' },
        { 'everness:palm_tree_wood', 'everness:palm_tree_wood' },
    }
})

doors.register_trapdoor('everness:trapdoor_palm_wood', {
    description = S('Palm Wood Trapdoor'),
    inventory_image = 'everness_door_trapdoor_palm_wood.png',
    wield_image = 'everness_door_trapdoor_palm_wood.png',
    tile_front = 'everness_door_trapdoor_palm_wood.png',
    tile_side = 'everness_door_trapdoor_palm_wood_side.png',
    sounds = Everness.node_sound_wood_defaults(),
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
})

doors.register_fencegate('everness:gate_palm_wood', {
    description = S('Palm Wood Fence Gate'),
    texture = 'everness_palm_tree_wood.png^[sheet:2x2:1,1',
    material = 'everness:palm_tree_wood',
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 }
})

-- Coral Wood

doors.register_fencegate('everness:gate_coral_wood', {
    description = S('Coral Wood Fence Gate'),
    texture = 'everness_coral_wood.png',
    material = 'everness:coral_wood',
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 }
})

-- Lava Tree Wood

doors.register('everness:door_lava_tree', {
    description = S('Lava Tree Wood Door'),
    tiles = { 'everness_door_lava_tree_wood.png' },
    inventory_image = 'everness_door_lava_tree_wood_item.png',
    use_texture_alpha = 'blend',
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
    sounds = Everness.node_sound_wood_defaults(),
    recipe = {
        { 'everness:lava_tree_wood', 'everness:lava_tree_wood' },
        { 'everness:lava_tree_wood', 'everness:lava_tree_wood' },
        { 'everness:lava_tree_wood', 'everness:lava_tree_wood' },
    }
})

doors.register_trapdoor('everness:trapdoor_lava_tree', {
    description = S('Lava Tree Wood Trapdoor'),
    inventory_image = 'everness_door_trapdoor_lava_tree_wood.png',
    wield_image = 'everness_door_trapdoor_lava_tree_wood.png',
    tile_front = 'everness_door_trapdoor_lava_tree_wood.png',
    tile_side = 'everness_door_trapdoor_lava_tree_wood_side.png',
    sounds = Everness.node_sound_wood_defaults(),
    groups = { node = 1, choppy = 3, oddly_breakable_by_hand = 3, door = 1 },
})

doors.register_fencegate('everness:gate_lava_tree_wood', {
    description = S('Lava Tree Wood Fence Gate'),
    texture = 'everness_lava_tree.png^[sheet:2x2:1,1',
    material = 'everness:lava_tree',
    groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 }
})
