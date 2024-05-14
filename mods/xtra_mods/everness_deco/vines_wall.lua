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

local function register_vine_wall(name, def, overrides)
    local _def = table.copy(def)
    local _name = name

    _def.short_description = _def.short_description or _def.description
    _def.drawtype = 'mesh'
    _def.tiles = _def.tiles or {
        { name = 'everness_' .. _name .. '.png' }
    }
    _def.inventory_image = 'everness_' .. _name .. '_item.png'
    _def.wield_image = 'everness_' .. _name .. '_item.png'
    _def.mesh = 'everness_vine_wall.obj'
    _def.use_texture_alpha = 'clip'
    _def.paramtype = 'light'
    _def.paramtype2 = 'wallmounted'
    _def.sunlight_propagates = true
    _def.walkable = false
    _def.climbable = true
    _def.buildable_to = false
    _def.sounds = Everness.node_sound_leaves_defaults()
    _def.groups = {
        -- MTG
        vine = 1,
        snappy = 3,
        -- Everness
        -- falling_vines = 1,
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
        attached_node = 1,
    }
    _def._mcl_blast_resistance = 0.2
    _def._mcl_hardness = 0.2
    _def.selection_box = {
        type = 'fixed',
        fixed = {
            -8 / 16,
            -8 / 16,
            -8 / 16,
            8 / 16,
            -5 / 16,
            8 / 16
        }
    }
    _def.collision_box = {
        type = 'fixed',
        fixed = {
            -8 / 16,
            -8 / 16,
            -8 / 16,
            8 / 16,
            -5 / 16,
            8 / 16
        }
    }
    _def.waving = 3
    _def.light_source = _def.light_source or 4

    _def.on_rotate = function()
        return false
    end

    Everness:register_node('everness:' .. _name, _def)
end

-- Cave vine

-- register_vine_wall('wall_vine_cave_green', {
--     description = S('Wall Cave Vine Green'),
-- })

register_vine_wall('wall_vine_cave_blue', {
    description = S('Wall Cave Vine Blue'),
})

register_vine_wall('wall_vine_cave_cyan', {
    description = S('Wall Cave Vine Cyan'),
})

register_vine_wall('wall_vine_cave_violet', {
    description = S('Wall Cave Vine Violet'),
})
