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


    Authors of source code
    ----------------------
    Originally by celeron55, Perttu Ahola <celeron55@gmail.com> (LGPLv2.1+)
    Various Minetest developers and contributors (LGPLv2.1+)

    The torch code was derived by sofar from the 'torches' mod by
    BlockMen (LGPLv2.1+)
--]]

local S = minetest.get_translator(minetest.get_current_modname())

local function on_flood(pos, oldnode, newnode)
    minetest.add_item(pos, ItemStack('everness:mineral_torch 1'))
    -- Play flame-extinguish sound if liquid is not an 'igniter'
    local nodedef = minetest.registered_items[newnode.name]

    if not (
        nodedef
        and nodedef.groups
        and nodedef.groups.igniter
        and nodedef.groups.igniter > 0
    ) then
        minetest.sound_play('default_cool_lava',
            {
                pos = pos,
                max_hear_distance = 16,
                gain = 0.07
            },
            true
        )
    end
    -- Remove the torch node
    return false
end

Everness:register_node('everness:mineral_torch', {
    description = S('Mineral') .. ' ' .. S('Torch'),
    drawtype = 'mesh',
    mesh = 'everness_mineral_torch.obj',
    inventory_image = 'everness_mineral_torch_item.png',
    wield_image = 'everness_mineral_torch_item.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tiles = {
        { name = 'everness_mineral_torch_mesh.png' },
        {
            name = 'everness_mineral_torch_animated.png',
            animation = {
                type = 'vertical_frames',
                aspect_w = 36,
                aspect_h = 6,
                length = 1
            },
            backface_culling = false
        }
    },
    use_texture_alpha = 'blend',
    paramtype = 'light',
    paramtype2 = 'wallmounted',
    sunlight_propagates = true,
    walkable = false,
    liquids_pointable = false,
    light_source = 12,
    groups = {
        choppy = 2,
        dig_immediate = 3,
        flammable = 1,
        attached_node = 1,
        torch = 1
    },
    drop = 'everness:mineral_torch',
    selection_box = {
        type = 'wallmounted',
        wall_bottom = { -1 / 8, -1 / 2, -1 / 8, 1 / 8, 2 / 16, 1 / 8 },
    },
    sounds = Everness.node_sound_wood_defaults(),
    on_place = function(itemstack, placer, pointed_thing)
        local under = pointed_thing.under
        local node = minetest.get_node(under)
        local def = minetest.registered_nodes[node.name]

        if def
            and def.on_rightclick
            and not (
                placer
                and placer:is_player()
                and placer:get_player_control().sneak
            )
        then
            return def.on_rightclick(under, node, placer, itemstack,
                pointed_thing) or itemstack
        end

        local above = pointed_thing.above
        local wdir = minetest.dir_to_wallmounted(vector.subtract(under, above))

        local fakestack = itemstack

        if wdir == 0 then
            fakestack:set_name('everness:mineral_torch_ceiling')
        elseif wdir == 1 then
            fakestack:set_name('everness:mineral_torch')
        else
            fakestack:set_name('everness:mineral_torch_wall')
        end

        itemstack = minetest.item_place(fakestack, placer, pointed_thing, wdir)

        itemstack:set_name('everness:mineral_torch')

        return itemstack
    end,
    floodable = true,
    on_flood = on_flood,
    on_rotate = false
})

Everness:register_node('everness:mineral_torch_wall', {
    drawtype = 'mesh',
    mesh = 'everness_mineral_torch_wall.obj',
    tiles = {
        { name = 'everness_mineral_torch_mesh.png' },
        {
            name = 'everness_mineral_torch_animated.png',
            animation = {
                type = 'vertical_frames',
                aspect_w = 36,
                aspect_h = 6,
                length = 1
            },
            backface_culling = false
        }
    },
    use_texture_alpha = 'blend',
    paramtype = 'light',
    paramtype2 = 'wallmounted',
    sunlight_propagates = true,
    walkable = false,
    light_source = 12,
    groups = {
        choppy = 2,
        dig_immediate = 3,
        flammable = 1,
        not_in_creative_inventory = 1,
        attached_node = 1,
        torch = 1
    },
    drop = 'everness:mineral_torch',
    selection_box = {
        type = 'wallmounted',
        wall_side = { -1 / 2, -1 / 2, -1 / 8, -1 / 8, 1 / 8, 1 / 8 },
    },
    sounds = Everness.node_sound_wood_defaults(),
    floodable = true,
    on_flood = on_flood,
    on_rotate = false
})

Everness:register_node('everness:mineral_torch_ceiling', {
    drawtype = 'mesh',
    mesh = 'everness_mineral_torch_ceiling.obj',
    tiles = {
        { name = 'everness_mineral_torch_mesh.png' },
        {
            name = 'everness_mineral_torch_animated.png',
            animation = {
                type = 'vertical_frames',
                aspect_w = 36,
                aspect_h = 6,
                length = 1
            },
            backface_culling = false
        }
    },
    use_texture_alpha = 'blend',
    paramtype = 'light',
    paramtype2 = 'wallmounted',
    sunlight_propagates = true,
    walkable = false,
    light_source = 12,
    groups = {
        choppy = 2,
        dig_immediate = 3,
        flammable = 1,
        not_in_creative_inventory = 1,
        attached_node = 1,
        torch = 1
    },
    drop = 'everness:mineral_torch',
    selection_box = {
        type = 'wallmounted',
        wall_top = { -1 / 8, -1 / 16, -5 / 16, 1 / 8, 1 / 2, 1 / 8 },
    },
    sounds = Everness.node_sound_wood_defaults(),
    floodable = true,
    on_flood = on_flood,
    on_rotate = false
})

minetest.register_craft({
    output = 'everness:mineral_torch 16',
    recipe = {
        { 'everness:lotus_flower_pink' },
        { 'everness:palm_tree_wood' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_torch 16',
    recipe = {
        { 'everness:lotus_flower_purple' },
        { 'everness:palm_tree_wood' },
    }
})

minetest.register_craft({
    output = 'everness:mineral_torch 16',
    recipe = {
        { 'everness:lotus_flower_white' },
        { 'everness:palm_tree_wood' },
    }
})

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:mineral_torch',
    burntime = 4,
})
