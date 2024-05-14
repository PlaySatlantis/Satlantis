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

local y_max = Everness.settings.biomes.everness_coral_forest_under.y_max
local y_min = Everness.settings.biomes.everness_coral_forest_under.y_min

-- Coral Forest Under

Everness:register_biome({
    name = 'everness:coral_forest_under',
    node_cave_liquid = { 'mapgen_water_source', 'mapgen_lava_source' },
    node_dungeon = 'everness:coral_desert_cobble',
    node_dungeon_alt = 'everness:coral_desert_mossy_cobble',
    node_dungeon_stair = 'stairs:stair_coral_desert_cobble',
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

-- Coral Desert Stone

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:coral_desert_stone',
    wherein = { 'default:stone' },
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
    biomes = { 'everness:coral_forest_under' }
})

--
-- Register decorations
--

-- Coral Forest Under

Everness:register_decoration({
    name = 'everness:coral_forest_under_desert_stone_with_moss_floors',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    place_offset_y = -1,
    sidelen = 16,
    fill_ratio = 10,
    biomes = { 'everness:coral_forest_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors, force_placement',
    decoration = {
        'everness:coral_desert_stone_with_moss'
    },
})

Everness:register_decoration({
    name = 'everness:coral_forest_under_mold_stone_ceilings',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    fill_ratio = 0.4,
    biomes = { 'everness:coral_forest_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    decoration = {
        'everness:moss_block'
    },
})

Everness:register_decoration({
    name = 'everness:coral_forest_under_coral_tree_bioluminescent',
    deco_type = 'simple',
    place_on = { 'everness:coral_desert_stone_with_moss' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:coral_forest_under' },
    y_max = y_max - 1500 > y_min and y_max - 1500 or y_max,
    y_min = y_min,
    flags = 'all_floors',
    decoration = {
        'everness:marker'
    },
})

Everness:register_decoration({
    name = 'everness:coral_forest_under_coral_plant_bioluminescent',
    deco_type = 'simple',
    place_on = { 'everness:coral_desert_stone_with_moss' },
    param2 = 8,
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:coral_forest_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:coral_plant_bioluminescent',
    flags = 'all_floors'
})

Everness:register_decoration({
    name = 'everness:coral_forest_under_lumecorn',
    deco_type = 'simple',
    place_on = { 'everness:coral_desert_stone_with_moss' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:coral_forest_under' },
    y_max = y_max - 1000 > y_min and y_max - 1000 or y_max,
    y_min = y_min,
    decoration = 'everness:lumecorn',
    flags = 'all_floors',
})

Everness:register_decoration({
    name = 'everness:coral_forest_under_vines',
    deco_type = 'simple',
    place_on = { 'everness:moss_block' },
    sidelen = 16,
    fill_ratio = 0.09,
    biomes = { 'everness:coral_forest_under' },
    param2 = 8,
    decoration = {
        'everness:lumabus_vine_1',
        'everness:lumabus_vine_2',
        'everness:flowered_vine_1',
        'everness:flowered_vine_2'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    spawn_by = 'air',
    num_spawn_by = 8
})

Everness:register_decoration({
    name = 'everness:coral_forest_under_plants',
    deco_type = 'simple',
    place_on = { 'everness:coral_desert_stone_with_moss' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:coral_forest_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = {
        'everness:coral_grass_orange',
        'everness:globulagus',
        'everness:coral_grass_tall',
    },
    flags = 'all_floors',
})

--
-- On Generated
--

local biome_id_everness_coral_forest_under = minetest.get_biome_id('everness:coral_forest_under')

local deco_id_coral_forest_under_coral_tree_bioluminescent = minetest.get_decoration_id('everness:coral_forest_under_coral_tree_bioluminescent')

local schem_bioluminescent_tree = minetest.get_modpath('everness') .. '/schematics/everness_coral_tree_bioluminescent.mts'
local coral_bioluminescent_tree_size = { x = 15, y = 17, z = 15 }
local bioluminescent_tree_size_x = math.round(coral_bioluminescent_tree_size.x / 2)
local bioluminescent_tree_size_z = math.round(coral_bioluminescent_tree_size.z / 2)
local bioluminescent_tree_safe_volume = (coral_bioluminescent_tree_size.x * coral_bioluminescent_tree_size.y * coral_bioluminescent_tree_size.z) / 1.5
local bioluminescent_tree_y_dis = 1
local bioluminescent_tree_place_on = minetest.registered_decorations['everness:coral_forest_under_coral_tree_bioluminescent'].place_on
bioluminescent_tree_place_on = type(bioluminescent_tree_place_on) == 'string' and { bioluminescent_tree_place_on } or bioluminescent_tree_place_on

minetest.set_gen_notify({ decoration = true }, { deco_id_coral_forest_under_coral_tree_bioluminescent })

Everness:add_to_queue_on_generated({
    name = 'everness:coral_forest_under',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_coral_forest_under) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        --
        -- Coral Tree Bioluminescent
        --
        for _, pos in ipairs(gennotify['decoration#' .. (deco_id_coral_forest_under_coral_tree_bioluminescent or '')] or {}) do
            -- `pos` is position of the 'place_on' node
            local marker_pos = vector.new(pos.x, pos.y + 1, pos.z)
            local marker_node = minetest.get_node(marker_pos)
            local place_on_node = minetest.get_node(pos)

            if marker_node and marker_node.name == 'everness:marker' then
                -- remove marker
                minetest.remove_node(marker_pos)

                if table.indexof(bioluminescent_tree_place_on, place_on_node.name) ~= -1 then
                    -- enough air to place structure ?
                    local positions = minetest.find_nodes_in_area(
                        vector.new(
                            pos.x - bioluminescent_tree_size_x,
                            pos.y - bioluminescent_tree_y_dis,
                            pos.z - bioluminescent_tree_size_z
                        ),
                        vector.new(
                            pos.x + bioluminescent_tree_size_x,
                            pos.y - bioluminescent_tree_y_dis + coral_bioluminescent_tree_size.y,
                            pos.z + bioluminescent_tree_size_z
                        ),
                        {
                            'air',
                            'everness:coral_tree'
                        },
                        true
                    )

                    local air = positions.air or {}
                    local tree = positions['everness:coral_tree'] or {}

                    -- do not overlap another tree
                    if #tree == 0 and #air > bioluminescent_tree_safe_volume then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            vector.new(marker_pos.x, marker_pos.y - bioluminescent_tree_y_dis, marker_pos.z),
                            schem_bioluminescent_tree,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        -- minetest.log('action', '[Everness] Coral Tree Bioluminescent was placed at ' .. pos:to_string())
                    end
                end
            end
        end
    end
})
