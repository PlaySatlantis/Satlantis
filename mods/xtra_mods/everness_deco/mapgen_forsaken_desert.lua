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

local y_max = Everness.settings.biomes.everness_forsaken_desert.y_max
local y_min = Everness.settings.biomes.everness_forsaken_desert.y_min

-- Forsaken Desert

Everness:register_biome({
    name = 'everness:forsaken_desert',
    node_top = 'everness:forsaken_desert_sand',
    depth_top = 1,
    node_stone = 'everness:forsaken_desert_stone',
    node_filler = 'everness:forsaken_desert_sand',
    depth_filler = 1,
    node_riverbed = 'everness:forsaken_desert_sand',
    depth_riverbed = 2,
    node_dungeon = 'everness:forsaken_desert_brick',
    node_dungeon_alt = 'everness:forsaken_desert_brick_red',
    node_dungeon_stair = 'stairs:stair_forsaken_desert_brick',
    y_max = y_max,
    y_min = y_min,
    heat_point = 100,
    humidity_point = 30,
})

--
-- Register ores
--

-- Stratum ores.
-- These obviously first.

Everness:register_ore({
    ore_type = 'stratum',
    ore = 'everness:forsaken_desert_cobble',
    wherein = { 'everness:forsaken_desert_stone' },
    clust_scarcity = 1,
    y_max = (y_max - y_max) + 46,
    y_min = (y_max - y_max) + 4,
    noise_params = {
        offset = 28,
        scale = 16,
        spread = { x = 128, y = 128, z = 128 },
        seed = 90122,
        octaves = 1,
    },
    stratum_thickness = 4,
    biomes = { 'everness:forsaken_desert' },
})

Everness:register_ore({
    ore_type = 'stratum',
    ore = 'everness:forsaken_desert_cobble',
    wherein = { 'everness:forsaken_desert_stone' },
    clust_scarcity = 1,
    y_max = (y_max - y_max) + 42,
    y_min = (y_max - y_max) + 6,
    noise_params = {
        offset = 24,
        scale = 16,
        spread = { x = 128, y = 128, z = 128 },
        seed = 90122,
        octaves = 1,
    },
    stratum_thickness = 2,
    biomes = { 'everness:forsaken_desert' },
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:forsaken_desert_sand_plants_1',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:forsaken_desert' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:forsaken_desert_plant_1' },
    param2 = 11,
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_sand_plants_2',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:forsaken_desert' },
    y_max = y_max,
    y_min = y_min,
    decoration = {
        'everness:forsaken_desert_plant_2',
        'everness:forsaken_desert_plant_3'
    },
    param2 = 8,
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_termite_nest',
    deco_type = 'schematic',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:forsaken_desert' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_termite_nest.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_hollow_tree',
    deco_type = 'schematic',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:forsaken_desert' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_hollow_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_hollow_tree_large',
    deco_type = 'schematic',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.001,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:forsaken_desert' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_hollow_tree_large.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

--
-- On Generated
--

local chance = 20
local disp = 16
local schem = minetest.get_modpath('everness') .. '/schematics/everness_forsaken_desert_temple.mts'
local size = { x = 9, y = 16, z = 9 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)

local c_forsaken_desert_sand = minetest.get_content_id('everness:forsaken_desert_sand')

local biome_id_everness_forsaken_desert = minetest.get_biome_id('everness:forsaken_desert')

Everness:add_to_queue_on_generated({
    name = 'everness:forsaken_desert',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_forsaken_desert) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if data[vi + area.ystride] == minetest.CONTENT_AIR
                and data[vi] == c_forsaken_desert_sand
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Forsaken Desert Temple
                --

                local schem_pos = vector.new(s_pos.x, s_pos.y, s_pos.z)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:forsaken_desert_sand'
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

                    shared_args.schem_positions.everness_forsaken_desert_temple = shared_args.schem_positions.everness_forsaken_desert_temple or {}

                    table.insert(shared_args.schem_positions.everness_forsaken_desert_temple, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Forsaken Desert Temple was placed at ' .. schem_pos:to_string())
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
