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

local y_max = Everness.settings.biomes.everness_cursed_lands_dunes.y_max
local y_min = Everness.settings.biomes.everness_cursed_lands_dunes.y_min

-- Cursed Lands Dunes

Everness:register_biome({
    name = 'everness:cursed_lands_dunes',
    node_top = 'everness:cursed_sand',
    depth_top = 1,
    node_filler = 'everness:cursed_sand',
    depth_filler = 3,
    node_riverbed = 'everness:cursed_sand',
    depth_riverbed = 2,
    node_stone = 'everness:cursed_stone_carved',
    node_dungeon = 'everness:cursed_sandstone_brick',
    node_dungeon_alt = 'everness:cursed_sandstone_block',
    node_dungeon_stair = 'stairs:stair_cursed_sandstone_brick',
    vertical_blend = 1,
    y_max = y_max,
    y_min = y_min,
    heat_point = 45,
    humidity_point = 85,
})

--
-- Register ores
--

-- Blob ore.
-- These before scatter ores to avoid other ores in blobs.

-- Sand

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:cursed_sand',
    wherein = { 'everness:cursed_stone_carved' },
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
    biomes = { 'everness:cursed_lands_dunes' }
})

-- Dirt

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:cursed_dirt',
    wherein = { 'everness:cursed_stone_carved' },
    clust_scarcity = 16 * 16 * 16,
    clust_size = 5,
    y_max = y_max,
    y_min = y_min,
    noise_threshold = 0.0,
    noise_params = {
        offset = 0.5,
        scale = 0.2,
        spread = { x = 5, y = 5, z = 5 },
        seed = 766,
        octaves = 1,
        persist = 0.0
    },
    biomes = { 'everness:cursed_lands_dunes' }
})

-- Mud

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:cursed_mud',
    wherein = { 'everness:cursed_stone_carved' },
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
    biomes = { 'everness:cursed_lands_dunes' }
})

-- Scatter ores

-- Coal

Everness:register_ore({
    ore_type = 'scatter',
    ore = 'everness:cursed_stone_carved_with_coal',
    wherein = 'everness:cursed_stone_carved',
    clust_scarcity = 8 * 8 * 8,
    clust_num_ores = 9,
    clust_size = 3,
    y_max = y_max,
    y_min = y_min,
    biomes = { 'everness:cursed_lands_dunes' }
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:cursed_lands_dunes_dry_tree',
    deco_type = 'schematic',
    place_on = {
        'everness:dirt_with_cursed_grass',
        'everness:cursed_dirt',
        'everness:cursed_sand',
        'everness:cursed_stone'
    },
    place_offset_y = 0,
    sidelen = 16,
    noise_params = {
        offset = 0.0015,
        scale = 0.0021,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:cursed_lands_dunes' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_dry_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

--
-- On Generated
--

local chance = 30
local chance_water = 10
local disp = 16
local water_level = tonumber(minetest.settings:get('water_level')) or 1

local schem_cursed_cabin = minetest.get_modpath('everness') .. '/schematics/everness_cursed_cabin.mts'
local size = { x = 7, y = 7, z = 12 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)

local schem_ocean_island = minetest.get_modpath('everness') .. '/schematics/everness_cursed_lands_deep_ocean_island.mts'
local size_ocean_island = { x = 25, y = 23, z = 23 }
local size_x_ocean_island = math.round(size.x / 2)
local size_z_ocean_island = math.round(size.z / 2)
local y_dis_ocean_island = 7

local c_cursed_sand = minetest.get_content_id('everness:cursed_sand')
local c_water_source = minetest.get_content_id('mapgen_water_source')

local biome_id_everness_cursed_lands_dunes = minetest.get_biome_id('everness:cursed_lands_dunes')

Everness:add_to_queue_on_generated({
    name = 'everness:cursed_lands_dunes',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_cursed_lands_dunes) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if data[vi + area.ystride] == minetest.CONTENT_AIR then
                local s_pos = area:position(vi)

                if data[vi] == c_cursed_sand
                    and rand:next(0, 100) < chance
                then
                    --
                    -- Cursed Cabin
                    --

                    -- add Y displacement
                    local schem_pos = vector.new(s_pos.x, s_pos.y, s_pos.z)

                    -- find floor big enough
                    local positions = minetest.find_nodes_in_area_under_air(
                        vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                        vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                        {
                            'everness:cursed_sand'
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
                            schem_cursed_cabin,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        shared_args.schem_positions.everness_cursed_cabin = shared_args.schem_positions.everness_cursed_cabin or {}

                        table.insert(shared_args.schem_positions.everness_cursed_cabin, {
                            pos = schem_pos,
                            minp = vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                            maxp = vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z)
                        })

                        minetest.log('action', '[Everness] Cursed Cabin was placed at ' .. schem_pos:to_string())
                    end
                end

                if data[vi] == c_water_source
                    and rand:next(0, 100) < chance_water
                    -- Water Level
                    and water_level >= minp.y
                    and water_level <= maxp.y
                then
                    --
                    -- Cursed Lands Deep Ocean Island
                    --

                    local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis_ocean_island, s_pos.z)

                    -- find floor big enough
                    local indexes = Everness.find_content_in_vm_area(
                        vector.new(s_pos.x - size_x_ocean_island, s_pos.y - 1, s_pos.z - size_z),
                        vector.new(s_pos.x + size_x_ocean_island, s_pos.y + 1, s_pos.z + size_z),
                        {
                            c_water_source,
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    if #indexes < size_ocean_island.x * size_ocean_island.z then
                        -- not enough space
                        return
                    end

                    -- enough space to place structure ?
                    local space_indexes = Everness.find_content_in_vm_area(
                        vector.new(s_pos.x - size_x_ocean_island, s_pos.y, s_pos.z - size_z_ocean_island),
                        vector.new(s_pos.x + size_x_ocean_island, s_pos.y + size_ocean_island.y, s_pos.z + size_z_ocean_island),
                        {
                            c_water_source,
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    if #space_indexes > (size_ocean_island.x * size_ocean_island.y * size_ocean_island.z) / 2 then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            schem_pos,
                            schem_ocean_island,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        shared_args.schem_positions.everness_cursed_lands_deep_ocean_island = shared_args.schem_positions.everness_cursed_lands_deep_ocean_island or {}

                        table.insert(shared_args.schem_positions.everness_cursed_lands_deep_ocean_island, {
                            pos = schem_pos,
                            minp = vector.new(s_pos.x - size_x_ocean_island, s_pos.y - y_dis_ocean_island, s_pos.z - size_z_ocean_island),
                            maxp = vector.new(s_pos.x + size_x_ocean_island, s_pos.y - y_dis_ocean_island + size_ocean_island.y, s_pos.z + size_z_ocean_island)
                        })

                        minetest.log('action', '[Everness] Cursed Lands Deep Ocean Island was placed at ' .. schem_pos:to_string())
                    end
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
