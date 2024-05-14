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

--
-- Register biomes
--

local y_max = Everness.settings.biomes.everness_baobab_savanna.y_max
local y_min = Everness.settings.biomes.everness_baobab_savanna.y_min

-- Baobab Savanna

Everness:register_biome({
    name = 'everness:baobab_savanna',
    node_top = 'everness:dry_dirt_with_dry_grass',
    depth_top = 1,
    node_filler = 'everness:dry_dirt',
    depth_filler = 1,
    node_riverbed = 'default:sand',
    depth_riverbed = 2,
    node_dungeon = 'default:cobble',
    node_dungeon_alt = 'default:mossycobble',
    node_dungeon_stair = 'stairs:stair_cobble',
    y_max = y_max,
    y_min = y_min,
    heat_point = 80,
    humidity_point = 30,
})

--
-- Register decorations
--

-- Savanna bare dirt patches.
-- Must come before all savanna decorations that are placed on dry grass.
-- Noise is similar to long dry grass noise, but scale inverted, to appear
-- where long dry grass is least dense and shortest.

Everness:register_decoration({
    name = 'everness:baobab_savanna_dry_dirt_with_dry_grass',
    deco_type = 'simple',
    place_on = { 'everness:dry_dirt_with_dry_grass' },
    sidelen = 4,
    noise_params = {
        offset = -1.5,
        scale = -1.5,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 4,
        persist = 1.0
    },
    biomes = { 'everness:baobab_savanna' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:dry_dirt',
    place_offset_y = -1,
    flags = 'force_placement',
})

Everness:register_decoration({
    name = 'everness:baobab_savanna_baobab_tree_1',
    deco_type = 'schematic',
    place_on = { 'everness:dry_dirt_with_dry_grass', 'everness:dry_dirt' },
    spawn_by = { 'everness:dry_dirt_with_dry_grass', 'everness:dry_dirt' },
    num_spawn_by = 8,
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:baobab_savanna' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_baobab_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:baobab_savanna_baobab_tree_2',
    deco_type = 'schematic',
    place_on = { 'everness:dry_dirt_with_dry_grass', 'everness:dry_dirt' },
    spawn_by = { 'everness:dry_dirt_with_dry_grass', 'everness:dry_dirt' },
    num_spawn_by = 8,
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 90155,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:baobab_savanna' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_baobab_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:baobab_savanna_baobab_log',
    deco_type = 'schematic',
    place_on = { 'everness:dry_dirt_with_dry_grass' },
    sidelen = 16,
    place_offset_y = 1,
    noise_params = {
        offset = 0,
        scale = 0.001,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:baobab_savanna' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_baobab_log.mts',
    flags = 'place_center_x',
    rotation = 'random',
    spawn_by = 'everness:dry_dirt_with_dry_grass',
    num_spawn_by = 8,
})

-- Dry grasses

local function register_dry_grass_decoration(offset, scale, length)
    Everness:register_decoration({
        name = 'everness:dry_grass_' .. length,
        deco_type = 'simple',
        place_on = { 'everness:dry_dirt_with_dry_grass' },
        sidelen = 16,
        noise_params = {
            offset = offset,
            scale = scale,
            spread = { x = 200, y = 200, z = 200 },
            seed = 329,
            octaves = 3,
            persist = 0.6
        },
        biomes = { 'everness:baobab_savanna' },
        y_max = y_max,
        y_min = y_min,
        decoration = 'everness:dry_grass_' .. length,
    })
end

register_dry_grass_decoration(0.01, 0.05, 4)
register_dry_grass_decoration(0.03, 0.03, 3)
register_dry_grass_decoration(0.05, 0.01, 2)
register_dry_grass_decoration(0.07, -0.01, 1)

--
-- On Generated
--

local disp = 16
local chance = 100
local schem = minetest.get_modpath('everness') .. '/schematics/everness_giant_sequoia_tree.mts'
local size = { x = 25, y = 75, z = 25 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)

local baobab_tree_size = { x = 24, y = 39, z = 24 }
local baobab_tree_size_x = math.round(size.x / 2)
local baobab_tree_size_z = math.round(size.z / 2)

local c_everness_dry_dirt_with_dry_grass = minetest.get_content_id('everness:dry_dirt_with_dry_grass')
local c_everness_dry_dirt = minetest.get_content_id('everness:dry_dirt')
local c_everness_dry_grass_1 = minetest.get_content_id('everness:dry_grass_1')
local c_everness_dry_grass_2 = minetest.get_content_id('everness:dry_grass_2')
local c_everness_dry_grass_3 = minetest.get_content_id('everness:dry_grass_3')
local c_everness_dry_grass_4 = minetest.get_content_id('everness:dry_grass_4')

local biome_id_baobab_savanna = minetest.get_biome_id('everness:baobab_savanna')

local deco_ids_baobab = {
    minetest.get_decoration_id('everness:baobab_savanna_baobab_tree_1'),
    minetest.get_decoration_id('everness:baobab_savanna_baobab_tree_2')
}

if #deco_ids_baobab > 1 then
    minetest.set_gen_notify({ decoration = true }, deco_ids_baobab)
end

Everness:add_to_queue_on_generated({
    name = 'everness:baobab_savanna',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_baobab_savanna) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if (
                    data[vi + area.ystride] == minetest.CONTENT_AIR
                    or data[vi + area.ystride] == c_everness_dry_grass_1
                    or data[vi + area.ystride] == c_everness_dry_grass_2
                    or data[vi + area.ystride] == c_everness_dry_grass_3
                    or data[vi + area.ystride] == c_everness_dry_grass_4
                )
                and (
                    data[vi] == c_everness_dry_dirt_with_dry_grass
                    or data[vi] == c_everness_dry_dirt
                )
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Giant Sequoia
                --

                minetest.emerge_area(
                    vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z),
                    function(blockpos, action, calls_remaining, param)
                        Everness:emerge_area(blockpos, action, calls_remaining, param)
                    end,
                    {
                        callback = function()
                            local positions = minetest.find_nodes_in_area_under_air(
                                vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                                vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                                {
                                    'everness:dry_dirt_with_dry_grass',
                                    'everness:dry_dirt',
                                    'group:flora',
                                    'group:flower'
                                })

                            if #positions < size.x * size.z then
                                -- not enough space
                                return
                            end

                            minetest.place_schematic(
                                s_pos,
                                schem,
                                'random',
                                nil,
                                true,
                                'place_center_x, place_center_z'
                            )

                            minetest.log('action', '[Everness] Giant Sequoia was placed at ' .. s_pos:to_string())
                        end
                    }
                )
            end
        end
    end,
    after_write_to_map = function(shared_args, gennotify)
        --
        -- Baobab Tree - fix light
        --
        for _, deco_id in ipairs(deco_ids_baobab) do
            for _, pos in ipairs(gennotify['decoration#' .. (deco_id or '')] or {}) do
                minetest.fix_light(
                    vector.new(pos.x - baobab_tree_size_x, pos.y - 1, pos.z - baobab_tree_size_z),
                    vector.new(pos.x + baobab_tree_size_x, pos.y + baobab_tree_size.y, pos.z + baobab_tree_size_z)
                )
            end
        end
    end
})
