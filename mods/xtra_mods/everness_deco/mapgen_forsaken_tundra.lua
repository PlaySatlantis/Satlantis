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

local y_max = Everness.settings.biomes.everness_forsaken_tundra.y_max
local y_min = Everness.settings.biomes.everness_forsaken_tundra.y_min

-- Forsaken Tundra

Everness:register_biome({
    name = 'everness:forsaken_tundra',
    node_top = 'everness:forsaken_tundra_dirt',
    depth_top = 1,
    node_stone = 'everness:forsaken_tundra_stone',
    node_filler = 'everness:forsaken_tundra_dirt',
    depth_filler = 1,
    node_riverbed = 'everness:forsaken_tundra_beach_sand',
    depth_riverbed = 2,
    node_dungeon = 'everness:forsaken_tundra_cobble',
    node_dungeon_alt = 'everness:forsaken_tundra_brick',
    node_dungeon_stair = 'stairs:stair_forsaken_tundra_cobble',
    y_max = y_max,
    y_min = y_min,
    heat_point = 10,
    humidity_point = 10,
})

--
-- Register ores
--

-- Blob ore.
-- These before scatter ores to avoid other ores in blobs.

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:sulfur_stone',
    wherein = { 'default:stone', 'everness:forsaken_tundra_stone' },
    clust_scarcity = 16 * 16 * 16,
    clust_size = 5,
    y_max = y_max,
    y_min = y_min,
    noise_threshold = 0.0,
    noise_params = {
        offset = 0.5,
        scale = 0.2,
        spread = { x = 5, y = 5, z = 5 },
        seed = -316,
        octaves = 1,
        persist = 0.0
    },
    biomes = {'everness:forsaken_tundra' }
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:forsaken_tundra_volcanic_sulfur',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_tundra_dirt' },
    sidelen = 4,
    noise_params = {
        offset = -0.7,
        scale = 4.0,
        spread = { x = 16, y = 16, z = 16 },
        seed = 513337,
        octaves = 1,
        persist = 0.0,
        flags = 'absvalue, eased'
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:volcanic_sulfur' },
    place_offset_y = -1,
    flags = 'force_placement',
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_sulfur_stone',
    deco_type = 'simple',
    place_on = {
        'everness:forsaken_tundra_dirt',
        'everness:volcanic_sulfur'
    },
    sidelen = 4,
    noise_params = {
        offset = -4,
        scale = 4,
        spread = { x = 50, y = 50, z = 50 },
        seed = 7013,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    place_offset_y = -1,
    flags = 'force_placement',
    decoration = { 'everness:sulfur_stone' },
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_dirt_with_grass',
    deco_type = 'simple',
    place_on = {
        'everness:forsaken_tundra_dirt',
        'everness:volcanic_sulfur'
    },
    sidelen = 4,
    noise_params = {
        offset = -0.8,
        scale = 2.0,
        spread = { x = 100, y = 100, z = 100 },
        seed = 53995,
        octaves = 3,
        persist = 1.0
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:forsaken_tundra_dirt_with_grass',
    place_offset_y = -1,
    flags = 'force_placement',
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_volcanic_sulfur_on_top_of_sulfur_stone',
    deco_type = 'simple',
    place_on = { 'everness:sulfur_stone' },
    sidelen = 4,
    noise_params = {
        offset = -4,
        scale = 4,
        spread = { x = 50, y = 50, z = 50 },
        seed = 7013,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:volcanic_sulfur' },
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_rocks',
    deco_type = 'schematic',
    place_on = { 'everness:forsaken_tundra_dirt', 'everness:forsaken_tundra_dirt_with_grass' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_forsaken_tundra_rocks.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_sulfur_volcano',
    deco_type = 'schematic',
    place_on = { 'everness:forsaken_tundra_dirt', 'everness:volcanic_sulfur' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_sulfur_volcano.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
    spawn_by = { 'everness:forsaken_tundra_dirt', 'everness:volcanic_sulfur' },
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_bloodpore_plant',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_tundra_dirt_with_grass' },
    sidelen = 16,
    noise_params = {
        offset = -0.03,
        scale = 0.09,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:bloodspore_plant',
    param2 = 8,
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_bloodspore_plant_on_dirt',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_tundra_dirt' },
    spawn_by = 'everness:forsaken_tundra_dirt_with_grass',
    num_spawn_by = 1,
    sidelen = 16,
    noise_params = {
        offset = -0.03,
        scale = 0.09,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:forsaken_tundra' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:bloodspore_plant',
    param2 = 8,
})

--
-- On Generated
--

local chance = 20
local disp = 16
local schem = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_jungle_temple.mts', {})
local size = { x = 12, y = 14, z = 15 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local y_dis = 3

local c_everness_forsaken_tundra_dirt = minetest.get_content_id('everness:forsaken_tundra_dirt')
local c_everness_forsaken_tundra_dirt_with_grass = minetest.get_content_id('everness:forsaken_tundra_dirt_with_grass')
local c_everness_volcanic_sulfur = minetest.get_content_id('everness:volcanic_sulfur')

local biome_id_everness_forsaken_tundra = minetest.get_biome_id('everness:forsaken_tundra')

Everness:add_to_queue_on_generated({
    name = 'everness:forsaken_tundra',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_forsaken_tundra) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if data[vi + area.ystride] == minetest.CONTENT_AIR
                and (
                    data[vi] == c_everness_forsaken_tundra_dirt
                    or data[vi] == c_everness_forsaken_tundra_dirt_with_grass
                    or data[vi] == c_everness_volcanic_sulfur
                )
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Jungle Temple
                --

                -- add Y displacement
                local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis, s_pos.z)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:forsaken_tundra_dirt',
                        'everness:forsaken_tundra_dirt_with_grass',
                        'everness:volcanic_sulfur'
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

                    shared_args.schem_positions.everness_jungle_temple = shared_args.schem_positions.everness_jungle_temple or {}

                    table.insert(shared_args.schem_positions.everness_jungle_temple, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y - y_dis, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y - y_dis + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Jungle Temple was placed at ' .. schem_pos:to_string())
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

