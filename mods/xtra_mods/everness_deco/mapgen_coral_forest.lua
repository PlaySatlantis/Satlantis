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

local y_max = Everness.settings.biomes.everness_coral_forest.y_max
local y_min = Everness.settings.biomes.everness_coral_forest.y_min

-- Coral Forest

Everness:register_biome({
    name = 'everness:coral_forest',
    node_top = 'everness:dirt_with_coral_grass',
    depth_top = 1,
    node_filler = 'everness:coral_dirt',
    depth_filler = 1,
    node_riverbed = 'everness:coral_dirt',
    depth_riverbed = 2,
    node_stone = 'everness:coral_desert_stone',
    node_dungeon = 'everness:coral_desert_stone_block',
    node_dungeon_alt = 'everness:coral_desert_stone_brick',
    node_dungeon_stair = 'stairs:stair_coral_desert_stone_block',
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
    biomes = { 'everness:coral_forest' }
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
    biomes = { 'everness:coral_forest' }
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
    biomes = { 'everness:coral_forest' }
})

--
-- Register decorations
--

-- Coral Forest

local chunksize = tonumber(minetest.get_mapgen_setting('chunksize'))

if chunksize >= 5 then
    Everness:register_decoration({
        name = 'everness:coral_forest_coral_tree',
        deco_type = 'schematic',
        place_on = { 'everness:dirt_with_coral_grass' },
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
        biomes = { 'everness:coral_forest' },
        y_max = y_max,
        y_min = y_min,
        schematic = minetest.get_modpath('everness') .. '/schematics/everness_coral_tree.mts',
        flags = 'place_center_x, place_center_z',
        rotation = 'random',
        spawn_by = 'everness:dirt_with_coral_grass',
        num_spawn_by = 8,
    })
end

Everness:register_decoration({
    name = 'everness:coral_forest_coral_bones_tree',
    deco_type = 'schematic',
    place_on = { 'everness:dirt_with_coral_grass' },
    sidelen = 16,
    place_offset_y = -1,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:coral_forest' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_coral_bones_tree.mts',
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:coral_forest_coral_burdock',
    deco_type = 'simple',
    place_on = { 'everness:dirt_with_coral_grass' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.006,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:coral_forest' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:coral_burdock_1', 'everness:coral_burdock_2' },
    spawn_by = 'everness:coral_tree',
    param2 = 8
})

Everness:register_decoration({
    name = 'everness:coral_forest_coral_bush',
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
    biomes = { 'everness:coral_forest' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:coral_bush'
})

Everness:register_decoration({
    name = 'everness:coral_forest_coral_shrub',
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
    biomes = { 'everness:coral_forest' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:coral_shrub'
})

local function register_coral_grass_decoration(offset, scale, length)
    Everness:register_decoration({
        name = 'everness:coral_forest_coral_grass_' .. length,
        deco_type = 'simple',
        place_on = { 'everness:dirt_with_coral_grass' },
        sidelen = 16,
        noise_params = {
            offset = offset,
            scale = scale,
            spread = { x = 200, y = 200, z = 200 },
            seed = 329,
            octaves = 3,
            persist = 0.6
        },
        biomes = { 'everness:coral_forest' },
        y_max = y_max,
        y_min = y_min,
        decoration = 'everness:coral_grass_' .. length,
    })
end

-- Grasses

register_coral_grass_decoration(-0.03, 0.09, 5)
register_coral_grass_decoration(-0.015, 0.075, 4)
register_coral_grass_decoration(0, 0.06, 3)
register_coral_grass_decoration(0.015, 0.045, 2)
register_coral_grass_decoration(0.03, 0.03, 1)

--
-- On Generated
--

local deco_id_coral_bones_tree = minetest.get_decoration_id('everness:coral_forest_coral_bones_tree')

local biome_id_coral_forest = minetest.get_biome_id('everness:coral_forest')

local coral_bones_tree_size = { x = 16, y = 35, z = 16 }

minetest.set_gen_notify({ decoration = true }, { deco_id_coral_bones_tree })

Everness:add_to_queue_on_generated({
    name = 'everness:coral_forest',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_coral_forest) ~= -1
    end,
    after_write_to_map = function(shared_args, gennotify)
        --
        -- Coral bone tree - fix light
        --
        for _, pos in ipairs(gennotify['decoration#' .. (deco_id_coral_bones_tree or '')] or {}) do
            minetest.fix_light(
                vector.round(vector.new(pos.x - (coral_bones_tree_size.x / 2), pos.y, pos.z - (coral_bones_tree_size.z / 2))),
                vector.round(vector.new(pos.x + (coral_bones_tree_size.x / 2), pos.y + coral_bones_tree_size.y, pos.z + (coral_bones_tree_size.z / 2)))
            )
        end
    end
})
