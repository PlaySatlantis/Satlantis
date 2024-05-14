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

local y_max = Everness.settings.biomes.everness_coral_forest_dunes.y_max
local y_min = Everness.settings.biomes.everness_coral_forest_dunes.y_min

-- Coral Forest Dunes

Everness:register_biome({
    name = 'everness:coral_forest_dunes',
    node_top = 'everness:coral_sand',
    depth_top = 1,
    node_filler = 'everness:coral_sand',
    depth_filler = 3,
    node_riverbed = 'everness:coral_sand',
    depth_riverbed = 2,
    node_stone = 'everness:coral_desert_stone',
    node_dungeon = 'everness:coral_sandstone',
    node_dungeon_alt = 'everness:coral_sandstone_brick',
    node_dungeon_stair = 'stairs:stair_coral_sandstone',
    vertical_blend = 1,
    y_max = y_max,
    y_min = y_min,
    heat_point = 60,
    humidity_point = 50,
})

--
-- Register ores
--

-- Blob ore.
-- These before scatter ores to avoid other ores in blobs.

-- Coral sand

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:coral_sand',
    wherein = { 'everness:coral_desert_stone' },
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
    biomes = { 'everness:coral_forest_dunes' }
})

-- Dirt

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:coral_dirt',
    wherein = { 'everness:coral_desert_stone' },
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
    biomes = { 'everness:coral_forest_dunes' }
})

-- Scatter ores

-- Coal

Everness:register_ore({
    ore_type = 'scatter',
    ore = 'everness:coral_desert_stone_with_coal',
    wherein = 'everness:coral_desert_stone',
    clust_scarcity = 8 * 8 * 8,
    clust_num_ores = 9,
    clust_size = 3,
    y_max = y_max,
    y_min = y_min,
    biomes = { 'everness:coral_forest_dunes' }
})

--
-- Register decorations
--

-- Coral Forest Dunes

Everness:register_decoration({
    name = 'everness:coral_forest_dunes_coral_volcano',
    deco_type = 'schematic',
    place_on = { 'everness:coral_sand' },
    place_offset_y = -1,
    sidelen = 16,
    noise_params = {
        offset = -0.012,
        scale = 0.024,
        spread = { x = 100, y = 100, z = 100 },
        seed = 230,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:coral_forest_dunes' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('x_clay')
        and minetest.get_modpath('everness') .. '/schematics/everness_coral_volcano_x_clay.mts'
        or minetest.get_modpath('everness') .. '/schematics/everness_coral_volcano.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
    spawn_by = 'everness:coral_sand',
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:coral_forest_dunes_coral_bush',
    deco_type = 'simple',
    place_on = { 'everness:dirt_with_coral_grass', 'everness:coral_sand', 'everness:coral_white_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.02,
        scale = 0.04,
        spread = { x = 200, y = 200, z = 200 },
        seed = 436,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:coral_forest_dunes' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:coral_bush'
})

Everness:register_decoration({
    name = 'everness:coral_forest_dunes_coral_shrub',
    deco_type = 'simple',
    place_on = { 'everness:dirt_with_coral_grass', 'everness:coral_sand', 'everness:coral_white_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.02,
        scale = 0.04,
        spread = { x = 200, y = 200, z = 200 },
        seed = 1220999,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:coral_forest_dunes' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:coral_shrub'
})

--
-- On Generated
--

local disp = 16
local chance = 5
local water_level = tonumber(minetest.settings:get('water_level')) or 1
local schem = minetest.get_modpath('everness') .. '/schematics/everness_coral_forest_ocean_fishing_dock.mts'
local size = { x = 26, y = 10, z = 23 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local y_dis = 1

local c_water_source = minetest.get_content_id('mapgen_water_source')

local biome_id_everness_coral_forest_dunes = minetest.get_biome_id('everness:coral_forest_dunes')

Everness:add_to_queue_on_generated({
    name = 'everness:coral_forest_dunes',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_coral_forest_dunes) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        if rand:next(0, 100) < chance then
            for y = minp.y, maxp.y do
                local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

                if data[vi + area.ystride] == minetest.CONTENT_AIR
                    and data[vi] == c_water_source
                    -- Water Level
                    and water_level >= minp.y
                    and water_level <= maxp.y
                then
                    local s_pos = area:position(vi)

                    --
                    -- Coral Forest Ocean Fishing Dock
                    --

                    local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis, s_pos.z)

                    -- find floor big enough
                    local indexes = Everness.find_content_in_vm_area(
                        vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                        vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                        {
                            c_water_source,
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    if #indexes < size.x * size.z then
                        -- not enough space
                        return
                    end

                    -- enough space to place structure ?
                    local space_indexes = Everness.find_content_in_vm_area(
                        vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                        vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z),
                        {
                            c_water_source,
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    if #space_indexes > (size.x * size.y * size.z) / 2 then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            schem_pos,
                            schem,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        shared_args.schem_positions.everness_coral_forest_ocean_fishing_dock = shared_args.schem_positions.everness_coral_forest_ocean_fishing_dock or {}

                        table.insert(shared_args.schem_positions.everness_coral_forest_ocean_fishing_dock, {
                            pos = schem_pos,
                            minp = vector.new(s_pos.x - size_x, s_pos.y - y_dis, s_pos.z - size_z),
                            maxp = vector.new(s_pos.x + size_x, s_pos.y - y_dis + size.y, s_pos.z + size_z)
                        })

                        minetest.log('action', '[Everness] Coral Forest Ocean Fishing Dock was placed at ' .. schem_pos:to_string())

                        break
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
