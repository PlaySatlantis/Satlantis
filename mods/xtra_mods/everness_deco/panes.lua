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

xpanes.register_pane('pyrite_pane', {
    description = S('Pyrite Glass Pane'),
    textures = { 'everness_pyrite_glass.png', '', 'everness_xpanes_edge_pyrite.png' },
    use_texture_alpha = 'clip',
    inventory_image = 'everness_pyrite_glass.png',
    wield_image = 'everness_pyrite_glass.png',
    sounds = Everness.node_sound_glass_defaults(),
    groups = { snappy = 2, cracky = 3, oddly_breakable_by_hand = 3 },
    recipe = {
        { 'everness:pyrite_glass', 'everness:pyrite_glass', 'everness:pyrite_glass' },
        { 'everness:pyrite_glass', 'everness:pyrite_glass', 'everness:pyrite_glass' }
    }
})

xpanes.register_pane('cursed_bar', {
    description = S('Cursed Steel Bars'),
    textures = {'everness_cursed_bar.png', '', 'everness_cursed_bar_top.png'},
    inventory_image = 'everness_cursed_bar.png',
    wield_image = 'everness_cursed_bar.png',
    groups = { cracky = 2 },
    sounds = Everness.node_sound_metal_defaults(),
    recipe = {
        { 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot' },
        { 'default:steel_ingot', 'default:steel_ingot', 'default:steel_ingot' },
        { 'everness:cursed_lands_deep_ocean_sandstone_block', 'everness:cursed_lands_deep_ocean_sandstone_block', 'everness:cursed_lands_deep_ocean_sandstone_block' }
    }
})

-- Register steel bar doors and trapdoors

if minetest.get_modpath('doors') then

    doors.register('everness:door_cursed_steel_bar', {
        tiles = {
            {
                name = 'everness_door_cursed_steel_bar.png',
                backface_culling = true
            }
        },
        description = S('Cursed Steel Bar Door'),
        inventory_image = 'everness_door_cursed_steel_bar_item.png',
        protected = true,
        groups = {
            node = 1,
            cracky = 1,
            level = 2
        },
        sounds = Everness.node_sound_metal_defaults(),
        sound_open = 'xpanes_steel_bar_door_open',
        sound_close = 'xpanes_steel_bar_door_close',
        gain_open = 0.15,
        gain_close = 0.13,
        recipe = {
            {'xpanes:cursed_bar_flat', 'xpanes:cursed_bar_flat'},
            {'xpanes:cursed_bar_flat', 'xpanes:cursed_bar_flat'},
            {'xpanes:cursed_bar_flat', 'xpanes:cursed_bar_flat'},
        },
    })

    doors.register_trapdoor('everness:trapdoor_cursed_steel_bar', {
        description = S('Steel Bar Trapdoor'),
        inventory_image = 'everness_trapdoor_cursed_steel_bar.png',
        wield_image = 'everness_trapdoor_cursed_steel_bar.png',
        tile_front = 'everness_trapdoor_cursed_steel_bar.png',
        tile_side = 'everness_trapdoor_cursed_steel_bar_side.png',
        protected = true,
        groups = {
            node = 1,
            cracky = 1,
            level = 2,
            door = 1
        },
        sounds = Everness.node_sound_metal_defaults(),
        sound_open = 'xpanes_steel_bar_door_open',
        sound_close = 'xpanes_steel_bar_door_close',
        gain_open = 0.15,
        gain_close = 0.13,
    })

    minetest.register_craft({
        output = 'everness:trapdoor_cursed_steel_bar',
        recipe = {
            {'xpanes:cursed_bar_flat', 'xpanes:cursed_bar_flat'},
            {'xpanes:cursed_bar_flat', 'xpanes:cursed_bar_flat'},
        }
    })
end
