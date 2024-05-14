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

Everness:register_tool('everness:vine_shears', {
    description = S('Vine Shears'),
    inventory_image = 'everness_vine_shears.png',
    wield_image = 'everness_vine_shears.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    sound = { breaks = 'everness_tool_breaks' },
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 0,
        groupcaps = {
            snappy = { times = { [3] = 0.2 }, uses = 30, maxlevel = 3 },
            wool = { times = { [3] = 0.2 }, uses = 30, maxlevel = 3 }
        }
    },
    groups = {
        -- Everness
        vine_shears = 1
    },
    -- MCL
    _mcl_toollike_wield = true,
    _mcl_diggroups = {
        shearsy = { speed = 1.5, level = 1, uses = 238 },
        shearsy_wool = { speed = 5, level = 1, uses = 238 },
        shearsy_cobweb = { speed = 15, level = 1, uses = 238 }
    },
})

Everness:register_tool('everness:pick_illuminating', {
    description = 'Illuminating Pickaxe (secondary use to place temporary illuminating crystal)',
    short_description = 'Illuminating Pickaxe',
    inventory_image = 'everness_pick_illuminating.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 3,
        groupcaps = {
            cracky = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.50 }, uses = 60, maxlevel = 3 }
        },
        damage_groups = { fleshy = 5 },
    },
    sound = { breaks = 'everness_tool_breaks' },
    groups = { pickaxe = 1, enchantability = 10 },
    on_place = function(itemstack, placer, pointed_thing)
        if pointed_thing.type == 'node' then
            local pos = minetest.get_pointed_thing_position(pointed_thing)

            if not pos or not placer then
                return itemstack
            end

            local player_name = placer:get_player_name()
            local pointed_node = minetest.get_node(pos)
            local pointed_node_def = minetest.registered_nodes[pointed_node.name]
            local pos_placer = placer:get_pos()

            if not pointed_node then
                return itemstack
            end

            -- check if we have to use default on_place first
            if pointed_node_def.on_rightclick then
                return pointed_node_def.on_rightclick(pos, pointed_node, placer, itemstack, pointed_thing)
            end

            if not minetest.is_protected(pointed_thing.above, player_name) and
                not minetest.is_protected(pointed_thing.under, player_name)
                and minetest.get_node(pointed_thing.above).name == 'air'
            then
                -- place crystal
                if minetest.has_feature({ dynamic_add_media_table = true, particlespawner_tweenable = true }) then
                    minetest.add_particlespawner({
                        amount = 50,
                        time = 1,
                        size = {
                            min = 0.5,
                            max = 1,
                        },
                        exptime = 2,
                        pos = vector.new(pos_placer.x, pos_placer.y, pos_placer.z),
                        texture = {
                            name = 'everness_particle.png^[colorize:#FFEE83:255',
                            alpha_tween = {
                                1, 0.5,
                                style = 'fwd',
                                reps = 1
                            },
                            scale_tween = {
                                1, 0.5,
                                style = 'fwd',
                                reps = 1
                            }
                        },
                        radius = { min = 0.5, max = 0.7 },
                        attract = {
                            kind = 'point',
                            strength = 1,
                            origin = vector.new(pointed_thing.above.x, pointed_thing.above.y, pointed_thing.above.z),
                        },
                        glow = 12
                    })
                end

                minetest.set_node(pointed_thing.above, { name = 'everness:floating_crystal' })
                minetest.get_node_timer(pointed_thing.above):start(math.random(85, 95))

                if not minetest.settings:get_bool('creative_mode')
                    or not minetest.check_player_privs(placer:get_player_name(), { creative = true })
                then
                    local wear_to_add = 65535 / (150 - 1)

                    if itemstack:get_wear() + wear_to_add > 65535 then
                        local itemstack_def = itemstack:get_definition()
                        -- Break tool
                        minetest.sound_play(itemstack_def.sound.breaks, {
                            pos = pos,
                            gain = 0.5
                        }, true)
                    end

                    itemstack:add_wear(wear_to_add)
                end

                return itemstack
            end
        end

        return itemstack
    end,
    -- MCL
    _mcl_toollike_wield = true,
    _mcl_diggroups = {
        pickaxey = { speed = 8, level = 5, uses = 1562 }
    },
})

Everness:register_tool('everness:pick_archeological', {
    description = 'Archeological pickaxe has the ability to get rare items from certain ores. (Use to get different kinds of ceramic sherds from ores with ceramic sherds)',
    short_description = 'Archeological pickaxe',
    inventory_image = 'everness_pick_archeological.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 1.2,
        max_drop_level = 0,
        groupcaps = {
            cracky = { times = { [3] = 1.60 }, uses = 20, maxlevel = 1 }
        },
        damage_groups = { fleshy = 2 },
    },
    sound = { breaks = 'everness_tool_breaks' },
    groups = {
        -- MTG
        pickaxe = 1,
        -- X Enchanting
        enchantability = 10,
        -- Everness
        archeological_drop = 1
    },
    -- MCL
    _mcl_toollike_wield = true,
    _mcl_diggroups = {
        pickaxey = { speed = 2, level = 2, uses = 500 }
    },
})

Everness:register_tool('everness:shovel_silk', {
    description = S('Silk Shovel'),
    inventory_image = 'everness_shovel_silk.png',
    wield_image = 'everness_shovel_silk.png^[transformR90',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 1,
        groupcaps = {
            crumbly = { times = { [1] = 1.10,[2] = 0.50,[3] = 0.30 }, uses = 30, maxlevel = 3 },
        },
        damage_groups = { fleshy = 4 },
    },
    sound = {
        breaks = 'everness_tool_breaks'
    },
    -- no `shovel` group so it cannot be enchanted
    -- groups = { shovel = 1 }
    -- MCL
    _mcl_toollike_wield = true,
    _mcl_diggroups = {
        shovely = { speed = 8, level = 5, uses = 1562 }
    },
})

local old_handle_node_drops = minetest.handle_node_drops

function minetest.handle_node_drops(pos, drops, digger)
    if not digger
        or not digger:is_player()
        or digger:get_wielded_item():get_name() ~= 'everness:shovel_silk'
    then
        return old_handle_node_drops(pos, drops, digger)
    end

    local node = minetest.get_node(pos)

    -- Silk Touch
    if minetest.get_item_group(node.name, 'crumbly') > 0
        and minetest.get_item_group(node.name, 'no_silktouch') == 0
    then
        -- drop raw item/node
        return old_handle_node_drops(pos, { ItemStack(node.name) }, digger)
    end

    return old_handle_node_drops(pos, drops, digger)
end

Everness:register_tool('everness:shell_of_underwater_breathing', {
    description = S('Shell of Underwater Breating'),
    inventory_image = 'everness_shell_of_underwarer_breathing.png',
    wield_image = 'everness_shell_of_underwarer_breathing.png',
    wield_scale = { x = 2, y = 2, z = 1 },
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            crumbly = { times = { [2] = 3.00,[3] = 0.70 }, uses = 0, maxlevel = 1 },
            snappy = { times = { [3] = 0.40 }, uses = 0, maxlevel = 1 },
            oddly_breakable_by_hand = { times = { [1] = 3.50,[2] = 2.00,[3] = 0.70 }, uses = 0 }
        },
        damage_groups = { fleshy = 1 },
    },
    sound = { breaks = 'everness_tool_breaks' },
    on_place = function(itemstack, placer, pointed_thing)
        return Everness:use_shell_of_underwater_breathing(itemstack, placer, pointed_thing)
    end,
    on_secondary_use = function(itemstack, user, pointed_thing)
        return Everness:use_shell_of_underwater_breathing(itemstack, user, pointed_thing)
    end,
    -- MCL
    _mcl_toollike_wield = true,
})

--
-- Hammer
--

minetest.register_on_mods_loaded(function()
    -- Hammer functionality and populating `cid_data` for lated VoxelManipulation
    for name, def in pairs(minetest.registered_nodes) do
        if def.walkable and def.pointable and def.diggable then
            local prev_after_dig = def.after_dig_node

            local func = function(pos, node, metadata, digger)
                Everness.hammer_after_dig_node(pos, node, metadata, digger, def.can_dig)
            end

            if prev_after_dig then
                func = function(pos, node, metadata, digger)
                    prev_after_dig(pos, node, metadata, digger)
                    Everness.hammer_after_dig_node(pos, node, metadata, digger, def.can_dig)
                end
            end

            minetest.override_item(name, { after_dig_node = func })

            Everness.hammer_cid_data[minetest.get_content_id(name)] = {
                name = name,
                drops = def.drops,
                can_dig = def.can_dig,
                sounds = def.sounds
            }
        end
    end
end)

Everness:register_node('everness:hammer', {
    description = S('Hammer'),
    mod_origin = 'evermess',
    inventory_image = 'everness_hammer_item.png',
    use_texture_alpha = 'clip',
    drawtype = 'mesh',
    mesh = 'everness_hammer_pick.obj',
    tiles = { 'everness_hammer_mesh.png' },
    wield_scale = { x = 2, y = 2, z = 2 },
    node_placement_prediction = '',
    range = 4.0,
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 3,
        groupcaps = {
            cracky = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.50 }, uses = 30, maxlevel = 3 },
        },
        damage_groups = { fleshy = 5 },
        -- MCL
        punch_attack_uses = 781,
    },
    stack_max = 1,
    sound = { breaks = 'everness_tool_breaks' },
    -- MCL
    _mcl_toollike_wield = true,
    groups = {
        -- MCL
        tool = 1,
        dig_speed_class = 5
    },
    -- MCL
    _mcl_diggroups = {
        pickaxey = { speed = 8, level = 5, uses = 1562 }
    },
    on_place = function(itemstack, placer, pointed_thing)
        -- disable placing (returns `nil`)
        if pointed_thing.type == 'node' then
            local pos = minetest.get_pointed_thing_position(pointed_thing)

            if not pos or not placer then
                return
            end

            local pointed_node = minetest.get_node(pos)
            local pointed_node_def = minetest.registered_nodes[pointed_node.name]

            if not pointed_node then
                return
            end

            -- check if we have to use default on_place first
            if pointed_node_def.on_rightclick then
                return pointed_node_def.on_rightclick(pos, pointed_node, placer, itemstack, pointed_thing)
            end
        end
    end
})

Everness:register_node('everness:hammer_sharp', {
    description = S('Sharp') .. ' ' .. S('Hammer'),
    mod_origin = 'evermess',
    inventory_image = 'everness_hammer_sharp_item.png',
    use_texture_alpha = 'clip',
    drawtype = 'mesh',
    mesh = 'everness_hammer_pick.obj',
    tiles = { 'everness_hammer_sharp_mesh.png' },
    wield_scale = { x = 2, y = 2, z = 2 },
    node_placement_prediction = '',
    range = 4.0,
    tool_capabilities = {
        full_punch_interval = 1.0,
        max_drop_level = 3,
        groupcaps = {
            cracky = { times = { [1] = 2.0, [2] = 1.0, [3] = 0.50 }, uses = 30, maxlevel = 3 },
        },
        damage_groups = { fleshy = 5 },
        -- MCL
        punch_attack_uses = 781,
    },
    stack_max = 1,
    sound = { breaks = 'everness_tool_breaks' },
    -- MCL
    _mcl_toollike_wield = true,
    groups = {
        -- MCL
        tool = 1,
        dig_speed_class = 5
    },
    -- MCL
    _mcl_diggroups = {
        pickaxey = { speed = 8, level = 5, uses = 1562 }
    },
    on_place = function(itemstack, placer, pointed_thing)
        -- disable placing (returns `nil`)
        if pointed_thing.type == 'node' then
            local pos = minetest.get_pointed_thing_position(pointed_thing)

            if not pos or not placer then
                return
            end

            local pointed_node = minetest.get_node(pos)
            local pointed_node_def = minetest.registered_nodes[pointed_node.name]

            if not pointed_node then
                return
            end

            -- check if we have to use default on_place first
            if pointed_node_def.on_rightclick then
                return pointed_node_def.on_rightclick(pos, pointed_node, placer, itemstack, pointed_thing)
            end
        end
    end
})
