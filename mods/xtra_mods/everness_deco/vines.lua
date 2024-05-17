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

local function register_vine(name, def, overrides)
    local _overrides = overrides and table.copy(overrides) or {}
    local _def = table.copy(def)
    local _name = name

    _def.walkable = false
    _def.climbable = true
    _def.sunlight_propagates = true
    _def.paramtype = 'light'
    _def.buildable_to = false
    _def.drawtype = 'plantlike'
    _def.paramtype2 = 'meshoptions'
    _def.place_param2 = 8
    _def.visual_scale = 1.1
    _def.light_source = 7
    _def.selection_box = def.selection_box or {
        type = 'fixed',
        fixed = { -4 / 16, -8 / 16, -4 / 16, 4 / 16, 8 / 16, 4 / 16 }
    }
    _def.groups = {
        -- MTG
        vine = 1,
        snappy = 3,
        -- Everness
        falling_vines = 1,
        no_silktouch = 1,
        -- X Farming
        compost = 30,
        -- MCL
        handy = 1,
        axey = 1,
        shearsy = 1,
        swordy = 1,
        deco_block = 1,
        dig_by_piston = 1,
        destroy_by_lava_flow = 1,
        compostability = 30,
        fire_encouragement = 15,
        fire_flammability = 100,
        -- ALL
        flammable = 2,
    }

    if _overrides.groups then
        Everness.mergeTables(_def.groups, _overrides.groups)
    end

    -- MCL
    _def._mcl_shears_drop = true
    _def._mcl_blast_resistance = 0.2
    _def._mcl_hardness = 0.2
    _def.on_rotate = function()
        return false
    end
    _def.sounds = Everness.node_sound_leaves_defaults()
    _def.waving = 1
    _def.on_destruct = function(pos)
        local pos_below = vector.new(pos.x, pos.y - 1, pos.z)
        local node_below = minetest.get_node(pos_below)

        if minetest.get_item_group(node_below.name, 'vine') > 0 then
            minetest.remove_node(pos_below)
        end
    end
    _def.after_dig_node = function(pos, oldnode, oldmetadata, digger)
        local pos_above = vector.new(pos.x, pos.y + 1, pos.z)
        Everness:tick_vine(pos_above)
    end
    _def.on_construct = function(pos)
        Everness:tick_vine(pos)
    end

    local grow_vine_node_names = {}
    local grow_vine_end_node_name = ''

    for i = 1, 3 do
        local _d = table.copy(_def)
        local _n = _name
        local first = i == 1
        local last = i == 3

        if last then
            -- end
            _n = _n .. '_end'
            _d.groups.vine_end = 1
            grow_vine_end_node_name = 'everness:' .. _n
            _d.tiles = { 'everness_' .. _n .. '.png' }
            _d.wield_image = 'everness_' .. _n .. '.png'
            _d.inventory_image = 'everness_' .. _n .. '.png'

            _d.drop = {
                max_items = 1,
                items = {
                    {
                        tool_groups = { 'vine_shears' },
                        items = { 'everness:' .. _n }
                    }
                }
            }

            if _overrides.last_def then
                -- custom, not 'plantlike' drawtype
                for k, v in pairs(_overrides.last_def) do
                    _d[k] = v
                end

                if not _overrides.last_def.place_param2 then
                    _d.place_param2 = nil
                end
            end
        else
            -- 1, 2..
            _n = _n .. '_' .. i
            _d.tiles = { 'everness_' .. _n .. '.png' }
            _d.wield_image = 'everness_' .. _n .. '.png'
            _d.inventory_image = 'everness_' .. _n .. '.png'

            _d.drop = {
                max_items = 1,
                items = {
                    {
                        tool_groups = { 'vine_shears' },
                        items = { 'everness:' .. _n }
                    }
                }
            }

            table.insert(grow_vine_node_names, 'everness:' .. _n)
        end

        if not first then
            -- 2.., end
            _d.light_source = 12
        end

        _d.on_timer = function(pos, elapsed)
            Everness:grow_vine(pos, elapsed, {
                node_names = grow_vine_node_names,
                end_node_name = grow_vine_end_node_name,
                end_node_param2 = _overrides.end_node_param2 and _overrides.end_node_param2 or nil
            })
        end

        Everness:register_node('everness:' .. _n, _d)
    end
end

-- Cave vine

register_vine('vine_cave', {
    description = S('Cave Vine')
})

minetest.register_alias('everness:vine_cave', 'everness:vine_cave_1')
minetest.register_alias('everness:vine_cave_with_mese_leaves', 'everness:vine_cave_2')

-- Whispering Gourd Vine

register_vine('whispering_gourd_vine', {
    description = S('Whispering Gourd Vine')
})

-- Bulb Vine

register_vine('bulb_vine', {
    description = S('Bulb Vine')
})

-- Willow Vine

register_vine('willow_vine', {
    description = S('Willow Vine')
}, {
    groups = {
        falling_vines = 0
    }
})

-- Eye Vine

register_vine('eye_vine',
    {
        description = S('Eye Vine'),
    },
    {
        end_node_param2 = 0,
        last_def = {
            tiles = {
                'everness_eye_vine_end_top.png',
                'everness_eye_vine_end_bottom.png',
                'everness_eye_vine_end_side.png',
            },
            wield_image = 'everness_eye_vine_end_bottom.png',
            inventory_image = 'everness_eye_vine_end_bottom.png',
            drawtype = 'normal',
            paramtype2 = 'facedir',
            sunlight_propagates = false,
            visual_scale = 1,
            selection_box = {
                type = 'fixed',
                fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 }
            },
            drop = {
                max_items = 1,
                items = {
                    {
                        tool_groups = { 'vine_shears' },
                        items = { 'everness:eye_vine_lantern' }
                    }
                }
            }
        }
    }
)

-- Lumabus Vine

register_vine('lumabus_vine',
    {
        description = S('Lumabus Vine')
    },
    {
        end_node_param2 = 0,
        last_def = {
            tiles = {
                'everness_lumabus_bulb_purple.png',
                {
                    name = 'everness_lumabus_leaves.png',
                    backface_culling = false
                }
            },
            use_texture_alpha = 'clip',
            drawtype = 'mesh',
            mesh = 'everness_lumabus.obj',
            paramtype2 = 'wallmounted',
            sunlight_propagates = false,
            visual_scale = 1,
            selection_box = {
                type = 'fixed',
                fixed = {
                    -1 / 2 + 3 / 16,
                    -1 / 2,
                    -1 / 2 + 3 / 16,
                    1 / 2 - 3 / 16,
                    1 / 2 - 6 / 16,
                    1 / 2 - 3 / 16
                }
            },
            drop = {
                max_items = 1,
                items = {
                    {
                        tool_groups = { 'vine_shears' },
                        items = { 'everness:lumabus_vine_lantern' }
                    }
                }
            }
        },
    }
)

-- Ivis Vine

register_vine('ivis_vine', {
    description = S('Ivis Vine')
})

-- Flowered vine

register_vine('flowered_vine', {
    description = S('Flowered Vine')
})

-- Reeds vine

register_vine('reeds_vine', {
    description = S('Reeds Vine')
})

-- Tenanea Flowers vine

register_vine('tenanea_flowers_vine', {
    description = S('Tenanea Flowers Vine')
})

-- Twisted vine

register_vine('twisted_vine', {
    description = S('Twisted Vine')
})

-- Golden vine

register_vine('golden_vine', {
    description = S('Golden Vine')
})

-- Dense vine

register_vine('dense_vine', {
    description = S('Dense Vine')
})

-- LBMs

Everness:register_lbm({
    label = 'Grows vines',
    name = 'everness:vines',
    nodenames = { 'group:vine' },
    run_at_every_load = true,
    action = function(pos, node)
        Everness:tick_vine(pos)
    end,
})
