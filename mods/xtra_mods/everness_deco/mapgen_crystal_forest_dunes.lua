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

local y_max = Everness.settings.biomes.everness_crystal_forest_dunes.y_max
local y_min = Everness.settings.biomes.everness_crystal_forest_dunes.y_min

-- Crystal Forest Dunes

Everness:register_biome({
    name = 'everness:crystal_forest_dunes',
    node_top = 'everness:crystal_sand',
    depth_top = 1,
    node_filler = 'everness:crystal_sand',
    depth_filler = 3,
    node_riverbed = 'everness:crystal_sand',
    depth_riverbed = 2,
    node_stone = 'everness:crystal_stone',
    node_dungeon = 'everness:crystal_cobble',
    node_dungeon_alt = 'everness:crystal_mossy_cobble',
    node_dungeon_stair = 'stairs:stair_crystal_cobble',
    vertical_blend = 1,
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
    biomes = { 'everness:crystal_forest_dunes' }
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
    biomes = { 'everness:crystal_forest_dunes' }
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:crystal_forest_dunes_ruins_1',
    deco_type = 'schematic',
    place_on = { 'everness:crystal_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.0003,
        scale = 0.0009,
        spread = { x = 200, y = 200, z = 200 },
        seed = 230,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_dunes' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_ruins_1.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:crystal_forest_dunes_ruins_2',
    deco_type = 'schematic',
    place_on = { 'everness:crystal_sand' },
    place_offset_y = 0,
    sidelen = 16,
    noise_params = {
        offset = -0.0003,
        scale = 0.0009,
        spread = { x = 200, y = 200, z = 200 },
        seed = 230,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_dunes' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_ruins_2.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

--
-- On Generated
--

local chance = 20
local chance_water = 10
local disp = 16
local water_level = tonumber(minetest.settings:get('water_level')) or 1

local schem = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_quartz_fountain.mts', {})
local size = { x = 11, y = 10, z = 11 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local y_dis = 1

local schem_shrine = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_ocean_shrine.mts', {})
local size_shrine = { x = 13, y = 16, z = 13 }
local size_x_shrine = math.round(size.x / 2)
local size_z_shrine = math.round(size.z / 2)
local y_dis_shrine = 8

local c_everness_crystal_sand = minetest.get_content_id('everness:crystal_sand')
local c_water_source = minetest.get_content_id('mapgen_water_source')

local biome_id_everness_crystal_forest_dunes = minetest.get_biome_id('everness:crystal_forest_dunes')

Everness:add_to_queue_on_generated({
    name = 'everness:crystal_forest_dunes',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_crystal_forest_dunes) ~= -1
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

                if
                    data[vi] == c_everness_crystal_sand
                    and rand:next(0, 100) < chance
                then
                    --
                    -- Quartz Fountain
                    --

                    -- add Y displacement
                    local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis, s_pos.z)

                    -- find floor big enough
                    local positions = minetest.find_nodes_in_area_under_air(
                        vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                        vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                        {
                            'everness:crystal_sand'
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

                    local replacements

                    if rand:next(0, 100) < 50 then
                        replacements = {
                            ['everness:chest'] = 'everness:quartz_pillar'
                        }
                    end

                    if #air_positions > (size.x * size.y * size.z) / 2 then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            schem_pos,
                            schem,
                            'random',
                            replacements,
                            true,
                            'place_center_x, place_center_z'
                        )

                        shared_args.schem_positions.everness_quartz_fountain = shared_args.schem_positions.everness_quartz_fountain or {}

                        table.insert(shared_args.schem_positions.everness_quartz_fountain, {
                            pos = schem_pos,
                            minp = vector.new(s_pos.x - size_x, s_pos.y - y_dis, s_pos.z - size_z),
                            maxp = vector.new(s_pos.x + size_x, s_pos.y - y_dis + size.y, s_pos.z + size_z)
                        })

                        minetest.log('action', '[Everness] Quartz Fountain was placed at ' .. schem_pos:to_string())
                    end
                end

                if data[vi] == c_water_source
                    and rand:next(0, 100) < chance_water
                    -- Water Level
                    and water_level >= minp.y
                    and water_level <= maxp.y
                then
                    --
                    -- Crystal Forest Ocean Shrine
                    --

                    -- add Y displacement
                    local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis_shrine, s_pos.z)

                    -- find floor big enough
                    local indexes = Everness.find_content_in_vm_area(
                        vector.new(s_pos.x - size_x_shrine, s_pos.y - 1, s_pos.z - size_z_shrine),
                        vector.new(s_pos.x + size_x_shrine, s_pos.y + 1, s_pos.z + size_z_shrine),
                        {
                            c_water_source,
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    if #indexes < size_shrine.x * size_shrine.z then
                        -- not enough space
                        return
                    end

                    -- enough space to place structure ?
                    local space_indexes = Everness.find_content_in_vm_area(
                        vector.new(s_pos.x - size_x_shrine, s_pos.y, s_pos.z - size_z_shrine),
                        vector.new(s_pos.x + size_x_shrine, s_pos.y + size_shrine.y, s_pos.z + size_z_shrine),
                        {
                            c_water_source,
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    if #space_indexes > (size_shrine.x * size_shrine.y * size_shrine.z) / 2 then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            schem_pos,
                            schem_shrine,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        shared_args.schem_positions.everness_crystal_forest_ocean_shrine = shared_args.schem_positions.everness_crystal_forest_ocean_shrine or {}

                        table.insert(shared_args.schem_positions.everness_crystal_forest_ocean_shrine, {
                            pos = schem_pos,
                            minp = vector.new(s_pos.x - size_x_shrine, s_pos.y - y_dis_shrine, s_pos.z - size_z_shrine),
                            maxp = vector.new(s_pos.x + size_x_shrine, s_pos.y - y_dis_shrine + size_shrine.y, s_pos.z + size_z_shrine)
                        })

                        minetest.log('action', '[Everness] Crystal Forest Ocean Shrine was placed at ' .. schem_pos:to_string())
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
