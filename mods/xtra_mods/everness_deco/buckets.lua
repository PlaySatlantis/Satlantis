--[[
    Authors of original source code
    ----------------------
    Kahrl <kahrl@gmx.net> (LGPLv2.1+)
    celeron55, Perttu Ahola <celeron55@gmail.com> (LGPLv2.1+)
    Various Minetest developers and contributors (LGPLv2.1+)
    Everness. Never ending discovery in Everness mapgen.

    Modified by:

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

-- Load support for MT game translation.
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craft({
    output = 'everness:bucket_empty 1',
    recipe = {
        { 'everness:pyrite_ingot', '', 'everness:pyrite_ingot' },
        { '', 'everness:pyrite_ingot', '' },
    }
})

local bucket = {
    liquids = {}
}

local function check_protection(pos, name, text)
    if minetest.is_protected(pos, name) then
        minetest.log('action', (name ~= '' and name or 'A mod')
            .. ' tried to ' .. text
            .. ' at protected position '
            .. minetest.pos_to_string(pos)
            .. ' with a bucket')
        minetest.record_protection_violation(pos, name)
        return true
    end
    return false
end

-- Register a new liquid
--    source = name of the source node
--    flowing = name of the flowing node
--    itemname = name of the new bucket item (or nil if liquid is not takeable)
--    inventory_image = texture of the new bucket item (ignored if itemname == nil)
--    name = text description of the bucket item
--    groups = (optional) groups of the bucket item, for example {water_bucket = 1}
--    force_renew = (optional) bool. Force the liquid source to renew if it has a
--                  source neighbour, even if defined as 'liquid_renewable = false'.
--                  Needed to avoid creating holes in sloping rivers.
-- This function can be called from any mod (that depends on bucket).
function bucket.register_liquid(source, flowing, itemname, inventory_image, name,
        groups, force_renew)
    bucket.liquids[source] = {
        source = source,
        flowing = flowing,
        itemname = itemname,
        force_renew = force_renew,
    }
    bucket.liquids[flowing] = bucket.liquids[source]

    if itemname ~= nil then
        Everness:register_craftitem(itemname, {
            description = name,
            inventory_image = inventory_image,
            stack_max = 1,
            liquids_pointable = true,
            groups = groups,
            wield_scale = { x = 2, y = 2, z = 1 },

            on_place = function(itemstack, user, pointed_thing)
                -- Must be pointing to node
                if pointed_thing.type ~= 'node' then
                    return
                end

                local node = minetest.get_node_or_nil(pointed_thing.under)
                local ndef = node and minetest.registered_nodes[node.name]

                -- Call on_rightclick if the pointed node defines it
                if ndef and ndef.on_rightclick and
                        not (user and user:is_player() and
                        user:get_player_control().sneak) then
                    return ndef.on_rightclick(
                        pointed_thing.under,
                        node, user,
                        itemstack)
                end

                local lpos

                -- Check if pointing to a buildable node
                if ndef and ndef.buildable_to then
                    -- buildable; replace the node
                    lpos = pointed_thing.under
                else
                    -- not buildable to; place the liquid above
                    -- check if the node above can be replaced

                    lpos = pointed_thing.above
                    node = minetest.get_node_or_nil(lpos)
                    local above_ndef = node and minetest.registered_nodes[node.name]

                    if not above_ndef or not above_ndef.buildable_to then
                        -- do not remove the bucket with the liquid
                        return itemstack
                    end
                end

                if check_protection(lpos, user
                        and user:get_player_name()
                        or '', 'place '..source) then
                    return
                end

                minetest.set_node(lpos, {name = source})
                return ItemStack('everness:bucket_empty')
            end
        })
    end
end

Everness:register_craftitem('everness:bucket_empty', {
    description = S('Empty Bucket'),
    inventory_image = 'everness_bucket_empty.png',
    groups = { tool = 1 },
    liquids_pointable = true,
    wield_scale = { x = 2, y = 2, z = 1 },

    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == 'object' then
            pointed_thing.ref:punch(user, 1.0, { full_punch_interval=1.0 }, nil)
            return user:get_wielded_item()
        elseif pointed_thing.type ~= 'node' then
            -- do nothing if it's neither object nor node
            return
        end
        -- Check if pointing to a liquid source
        local node = minetest.get_node(pointed_thing.under)
        local liquiddef = bucket.liquids[node.name]
        local item_count = user:get_wielded_item():get_count()

        if liquiddef ~= nil
            and liquiddef.itemname ~= nil
            and node.name == liquiddef.source
        then
            if check_protection(pointed_thing.under,
                    user:get_player_name(),
                    'take '.. node.name) then
                return
            end

            -- default set to return filled bucket
            local giving_back = liquiddef.itemname

            -- check if holding more than 1 empty bucket
            if item_count > 1 then
                -- if space in inventory add filled bucked, otherwise drop as item
                local inv = user:get_inventory()

                if inv:room_for_item('main', { name = liquiddef.itemname }) then
                    inv:add_item('main', liquiddef.itemname)
                else
                    local pos = user:get_pos()
                    pos.y = math.floor(pos.y + 0.5)
                    minetest.add_item(pos, liquiddef.itemname)
                end

                -- set to return empty buckets minus 1
                giving_back = 'everness:bucket_empty '.. tostring(item_count - 1)
            end

            -- force_renew requires a source neighbour
            local source_neighbor = false

            if liquiddef.force_renew then
                source_neighbor = minetest.find_node_near(pointed_thing.under, 1, liquiddef.source)
            end

            if not (source_neighbor and liquiddef.force_renew) then
                minetest.add_node(pointed_thing.under, { name = 'air' })
            end

            return ItemStack(giving_back)
        else
            -- non-liquid nodes will have their on_punch triggered
            local node_def = minetest.registered_nodes[node.name]

            if node_def then
                node_def.on_punch(pointed_thing.under, node, user, pointed_thing)
            end

            return user:get_wielded_item()
        end
    end,
})

-- Mineral water source is 'liquid_renewable = false' to avoid horizontal spread
-- of water sources in sloping rivers that can cause water to overflow
-- riverbanks and cause floods.
-- River water source is instead made renewable by the 'force renew' option
-- used here.

bucket.register_liquid(
    'everness:mineral_water_source',
    'everness:mineral_water_flowing',
    'everness:bucket_mineral_water',
    'everness_bucket_mineral_water.png',
    S('Mineral') .. ' ' .. S('Water') .. ' ' .. S('Bucket'),
    { tool = 1, water_bucket = 1 }
)

bucket.register_liquid(
    'everness:lava_source',
    'everness:lava_flowing',
    'everness:bucket_lava',
    'everness_bucket_lava.png',
    S('Lava Bucket'),
    { tool = 1 }
)

minetest.register_craft({
    type = 'fuel',
    recipe = 'everness:bucket_lava',
    burntime = 370,
    replacements = {{ 'everness:bucket_lava', 'everness:bucket_empty' }},
})
