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

local y_max = Everness.settings.biomes.everness_crystal_forest_deep_ocean.y_max
local y_min = Everness.settings.biomes.everness_crystal_forest_deep_ocean.y_min

-- Coral Forest Ocean

Everness:register_biome({
    name = 'everness:crystal_forest_deep_ocean',
    node_top = 'everness:crystal_forest_deep_ocean_sand',
    depth_top = 1,
    node_filler = 'everness:crystal_forest_deep_ocean_sand',
    depth_filler = 3,
    node_riverbed = 'everness:crystal_forest_deep_ocean_sand',
    depth_riverbed = 2,
    node_cave_liquid = 'mapgen_water_source',
    node_dungeon = 'everness:crystal_forest_deep_ocean_sandstone_block',
    node_dungeon_alt = 'everness:crystal_forest_deep_ocean_sandstone_brick',
    node_dungeon_stair = 'stairs:stair_crystal_forest_deep_ocean_sandstone_block',
    y_max = y_max,
    y_min = y_min,
    heat_point = 35,
    humidity_point = 50,
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_coral_1',
    deco_type = 'schematic',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
    sidelen = 16,
    fill_ratio = 0.003,
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_deep_ocean_coral_1.mts',
    flags = 'place_center_x, place_center_z, force_placement',
})

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_coral_2',
    deco_type = 'schematic',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
    sidelen = 16,
    fill_ratio = 0.003,
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_deep_ocean_coral_2.mts',
    flags = 'place_center_x, place_center_z, force_placement',
})

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_coral_3',
    deco_type = 'schematic',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
    sidelen = 16,
    fill_ratio = 0.003,
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_deep_ocean_coral_3.mts',
    flags = 'place_center_x, place_center_z, force_placement',
})

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_sand_with_crack',
    deco_type = 'simple',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    place_offset_y = -1,
    sidelen = 4,
    fill_ratio = 0.002,
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    flags = 'force_placement',
    decoration = { 'everness:crystal_forest_deep_ocean_sand_with_crack' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_coral_plant_1',
    deco_type = 'simple',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    place_offset_y = -1,
    sidelen = 4,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    flags = 'force_placement',
    decoration = { 'everness:crystal_forest_deep_ocean_coral_plant_1' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_coral_plant_2',
    deco_type = 'simple',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    place_offset_y = -1,
    sidelen = 4,
    noise_params = {
        offset = -0.02,
        scale = 0.04,
        spread = { x = 200, y = 200, z = 200 },
        seed = 436,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    flags = 'force_placement',
    decoration = { 'everness:crystal_forest_deep_ocean_coral_plant_2' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:crystal_forest_deep_ocean_coral_plant_3',
    deco_type = 'simple',
    place_on = { 'everness:crystal_forest_deep_ocean_sand' },
    place_offset_y = -1,
    sidelen = 4,
    noise_params = {
        offset = -0.02,
        scale = 0.04,
        spread = { x = 200, y = 200, z = 200 },
        seed = 19822,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_deep_ocean' },
    y_max = y_max,
    y_min = y_min,
    flags = 'force_placement',
    decoration = { 'everness:crystal_forest_deep_ocean_coral_plant_3' },
    spawn_by = 'mapgen_water_source',
    num_spawn_by = 8,
})

--
-- On Generated
--

local c_water_source = minetest.get_content_id('mapgen_water_source')
local c_everness_crystal_forest_deep_ocean_sand = minetest.get_content_id('everness:crystal_forest_deep_ocean_sand')
local c_everness_crystal_forest_deep_ocean_coral_plant_1 = minetest.get_content_id('everness:crystal_forest_deep_ocean_coral_plant_1')
local c_everness_crystal_forest_deep_ocean_coral_plant_2 = minetest.get_content_id('everness:crystal_forest_deep_ocean_coral_plant_2')
local c_everness_crystal_forest_deep_ocean_coral_plant_3 = minetest.get_content_id('everness:crystal_forest_deep_ocean_coral_plant_3')
local c_everness_crystal_forest_deep_ocean_coral_1 = minetest.get_content_id('everness:crystal_forest_deep_ocean_coral_1')
local c_everness_crystal_forest_deep_ocean_coral_2 = minetest.get_content_id('everness:crystal_forest_deep_ocean_coral_2')
local c_everness_crystal_forest_deep_ocean_coral_3 = minetest.get_content_id('everness:crystal_forest_deep_ocean_coral_3')
-- Biome IDs
local biome_id_everness_crystal_forest_deep_ocean = minetest.get_biome_id('everness:crystal_forest_deep_ocean')

local chance = 30
local schem = minetest.get_modpath('everness') .. '/schematics/everness_crystal_forest_deep_ocean_ruins.mts'
local size = { x = 14, y = 12, z = 9 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)

Everness:add_to_queue_on_generated({
    name = 'everness:crystal_forest_deep_ocean',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_crystal_forest_deep_ocean) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        shared_args.schem_positions = {}
        local schem_placed = false

        if rand:next(0, 100) < chance then
            for y = maxp.y, minp.y, -1 do
                if schem_placed then
                    break
                end

                for z = minp.z, maxp.z do
                    if schem_placed then
                        break
                    end

                    for x = minp.x, maxp.x do
                        local vi = area:index(x, y, z)

                        if
                            data[vi] == c_everness_crystal_forest_deep_ocean_sand
                            and data[vi + area.ystride] == c_water_source
                        then
                            local s_pos = area:position(vi)

                            --
                            -- Crystal Forest Deep Ocean Ruins
                            --

                            local schem_pos = vector.new(s_pos)

                            -- find floor big enough
                            local indexes = Everness.find_content_in_vm_area(
                                vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                                vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                                {
                                    c_everness_crystal_forest_deep_ocean_sand,
                                    c_everness_crystal_forest_deep_ocean_coral_plant_1,
                                    c_everness_crystal_forest_deep_ocean_coral_plant_2,
                                    c_everness_crystal_forest_deep_ocean_coral_plant_3,
                                    c_everness_crystal_forest_deep_ocean_coral_1,
                                    c_everness_crystal_forest_deep_ocean_coral_2,
                                    c_everness_crystal_forest_deep_ocean_coral_3
                                },
                                data,
                                area
                            )

                            if #indexes < size.x * size.z then
                                -- not enough space
                                return
                            end

                            -- enough water to place structure ?
                            local water_indexes = Everness.find_content_in_vm_area(
                                vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                                vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z),
                                {
                                    c_water_source
                                },
                                data,
                                area
                            )

                            if #water_indexes > (size.x * size.y * size.z) / 2 then
                                minetest.place_schematic_on_vmanip(
                                    vm,
                                    schem_pos,
                                    schem,
                                    'random',
                                    nil,
                                    true,
                                    'place_center_x, place_center_z'
                                )

                                schem_placed = true

                                shared_args.schem_positions.everness_crystal_forest_deep_ocean_ruins = shared_args.schem_positions.everness_crystal_forest_deep_ocean_ruins or {}

                                table.insert(shared_args.schem_positions.everness_crystal_forest_deep_ocean_ruins, {
                                    pos = schem_pos,
                                    minp = vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                                    maxp = vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z)
                                })

                                minetest.log('action', '[Everness] Crystal Forest Deep Ocean Ruins was placed at ' .. schem_pos:to_string())

                                break
                            end
                        end
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
