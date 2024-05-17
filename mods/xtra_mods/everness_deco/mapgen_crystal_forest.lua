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

local y_max = Everness.settings.biomes.everness_crystal_forest.y_max
local y_min = Everness.settings.biomes.everness_crystal_forest.y_min

-- Crystal Forest

Everness:register_biome({
    name = 'everness:crystal_forest',
    node_top = 'everness:dirt_with_crystal_grass',
    depth_top = 1,
    node_filler = 'everness:crystal_dirt',
    depth_filler = 1,
    node_riverbed = 'everness:crystal_dirt',
    depth_riverbed = 2,
    node_stone = 'everness:crystal_stone',
    node_dungeon = 'everness:crystal_cobble',
    node_dungeon_alt = 'everness:crystal_mossy_cobble',
    node_dungeon_stair = 'stairs:stair_crystal_cobble',
    y_max = y_max,
    y_min = y_min,
    heat_point = 35,
    humidity_point = 50,
})

--
-- Register ores
--

-- Blob ore.
-- These before scatter ores to avoid other ores in blobs.

-- Crystal sand

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:crystal_sand',
    wherein = { 'everness:crystal_stone' },
    clust_scarcity = 16 * 16 * 16,
    clust_size = 5,
    y_max = y_max,
    y_min = y_min,
    noise_threshold = 0.0,
    noise_params = {
        offset = 0.5,
        scale = 0.2,
        spread = { x = 5, y = 5, z = 5 },
        seed = 2316,
        octaves = 1,
        persist = 0.0
    },
    biomes = { 'everness:crystal_forest' }
})

-- Dirt

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:crystal_dirt',
    wherein = { 'everness:crystal_stone' },
    clust_scarcity = 16 * 16 * 16,
    clust_size = 5,
    y_max = y_max,
    y_min = y_min,
    noise_threshold = 0.0,
    noise_params = {
        offset = 0.5,
        scale = 0.2,
        spread = { x = 5, y = 5, z = 5 },
        seed = 17676,
        octaves = 1,
        persist = 0.0
    },
    biomes = { 'everness:crystal_forest' }
})

-- Scatter ores

-- Coal

Everness:register_ore({
    ore_type = 'scatter',
    ore = 'everness:crystal_stone_with_coal',
    wherein = 'everness:crystal_stone',
    clust_scarcity = 8 * 8 * 8,
    clust_num_ores = 9,
    clust_size = 3,
    y_max = y_max,
    y_min = y_min,
    biomes = { 'everness:crystal_forest' }
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:crystal_forest_crystal_mushrooms',
    deco_type = 'simple',
    place_on = { 'everness:dirt_with_crystal_grass' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.006,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:crystal_forest' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:crystal_mushrooms',
    param2 = 40
})

Everness:register_decoration({
    name = 'everness:crystal_forest_crystal_tree',
    deco_type = 'schematic',
    place_on = { 'everness:dirt_with_crystal_grass' },
    place_offset_y = 0,
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:crystal_forest' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:crystal_forest_crystal_tree_large',
    deco_type = 'schematic',
    place_on = { 'everness:dirt_with_crystal_grass' },
    place_offset_y = 0,
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.001,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:crystal_forest' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_tree_large.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:crystal_forest_crystal_bush',
    deco_type = 'schematic',
    place_on = { 'everness:dirt_with_crystal_grass' },
    sidelen = 16,
    place_offset_y = 1,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:crystal_forest' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_bush.mts',
    flags = 'place_center_x, place_center_z',
})

local function register_crystal_grass_decoration(offset, scale, length)
    Everness:register_decoration({
        name = 'everness:crystal_forest_crystal_grass_' .. length,
        deco_type = 'simple',
        place_on = { 'everness:dirt_with_crystal_grass' },
        sidelen = 16,
        noise_params = {
            offset = offset,
            scale = scale,
            spread = { x = 200, y = 200, z = 200 },
            seed = 329,
            octaves = 3,
            persist = 0.6
        },
        biomes = { 'everness:crystal_forest' },
        y_max = y_max,
        y_min = y_min,
        decoration = 'everness:crystal_grass_' .. length,
    })
end

-- Crystal Grasses

register_crystal_grass_decoration(-0.03, 0.09, 3)
register_crystal_grass_decoration(-0.015, 0.075, 2)
register_crystal_grass_decoration(0, 0.06, 1)

--
-- On Generated
--

local chance = 20
local disp = 16
local schem = minetest.get_modpath('everness') .. '/schematics/everness_quartz_temple.mts'
local size = { x = 16, y = 13, z = 16 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local y_dis = 1

local c_dirt_with_crystal_grass = minetest.get_content_id('everness:dirt_with_crystal_grass')

local biome_id_everness_crystal_forest = minetest.get_biome_id('everness:crystal_forest')

Everness:add_to_queue_on_generated({
    name = 'everness:crystal_forest',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_crystal_forest) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if data[vi + area.ystride] == minetest.CONTENT_AIR
                and data[vi] == c_dirt_with_crystal_grass
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Quartz Temple
                --

                -- add Y displacement
                local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis, s_pos.z)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:dirt_with_crystal_grass'
                    }
                )

                if #positions < size.x * size.z then
                    -- not enough space
                    return
                end

                -- enough air to place structure ?
                local air_positions = minetest.find_nodes_in_area(
                    vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z),
                    {
                        'air'
                    }
                )

                if #air_positions > (size.x * size.y * size.z) / 2 then
                    minetest.place_schematic_on_vmanip(
                        vm,
                        schem_pos,
                        schem,
                        'random',
                        nil,
                        true,
                        'place_center_x, place_center_z'
                    )

                    shared_args.schem_positions.everness_quartz_temple = shared_args.schem_positions.everness_quartz_temple or {}

                    table.insert(shared_args.schem_positions.everness_quartz_temple, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y - y_dis, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y - y_dis + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Quartz Temple was placed at ' .. schem_pos:to_string())
                end
            end
        end
    end,
    after_write_to_map = function(shared_args)
        local schem_positions = shared_args.schem_positions or {}

        for name, tbl in pairs(schem_positions) do
            if next(tbl) then
                for i, v in ipairs(tbl) do
                    local chest_positions = minetest.find_nodes_in_area(
                        v.minp,
                        v.maxp,
                        { 'everness:chest' }
                    )

                    if #chest_positions > 0 then
                        Everness:populate_loot_chests(chest_positions)
                    end
                end
            end
        end
    end
})
