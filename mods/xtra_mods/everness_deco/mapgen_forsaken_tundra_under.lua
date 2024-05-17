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

local y_max = Everness.settings.biomes.everness_forsaken_tundra_under.y_max
local y_min = Everness.settings.biomes.everness_forsaken_tundra_under.y_min

-- Forsaken Tundra Under

Everness:register_biome({
    name = 'everness:forsaken_tundra_under',
    node_cave_liquid = { 'mapgen_water_source', 'mapgen_lava_source' },
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
    biomes = { 'everness:forsaken_tundra_under' }
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_mold_stone_floors',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 10,
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors, force_placement',
    decoration = {
        'everness:mold_stone_with_moss'
    },
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_mold_stone_ceilings',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    fill_ratio = 0.4,
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    decoration = {
        'everness:moss_block'
    },
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_obsidian_floors',
    deco_type = 'simple',
    place_on = { 'default:stone', 'everness:mold_stone_with_moss' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 0.02,
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = {
        'everness:blue_crying_obsidian',
        'everness:blue_weeping_obsidian',
        'everness:weeping_obsidian'
    },
    flags = 'all_floors, force_placement'
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_obsidian_ceilings',
    deco_type = 'simple',
    place_on = { 'default:stone', 'everness:moss_block' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 0.02,
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = {
        'everness:blue_crying_obsidian',
        'everness:blue_weeping_obsidian',
        'everness:weeping_obsidian'
    },
    flags = 'all_ceilings, force_placement'
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_cactus_orange',
    deco_type = 'simple',
    place_on = { 'everness:mold_stone_with_moss' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = 'everness:cactus_orange',
    height = 2,
    height_max = 6,
    flags = 'all_floors'
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_willow_tree',
    deco_type = 'simple',
    place_on = {
        'everness:mold_stone_with_moss',
        'everness:blue_crying_obsidian',
        'everness:blue_weeping_obsidian',
        'everness:weeping_obsidian'
    },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max - 1500 > y_min and y_max - 1500 or y_max,
    y_min = y_min,
    flags = 'all_floors',
    decoration = {
        'everness:marker'
    },
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_bloodspore_plant_small',
    deco_type = 'simple',
    place_on = { 'everness:mold_stone_with_moss' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:bloodspore_plant_small',
    param2 = 8,
    flags = 'all_floors'
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_vines',
    deco_type = 'simple',
    place_on = { 'everness:moss_block' },
    sidelen = 16,
    fill_ratio = 0.09,
    biomes = { 'everness:forsaken_tundra_under' },
    param2 = 8,
    decoration = {
        'everness:whispering_gourd_vine_1',
        'everness:whispering_gourd_vine_2',
        'everness:bulb_vine_1',
        'everness:bulb_vine_2'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    spawn_by = 'air',
    num_spawn_by = 8
})

Everness:register_decoration({
    name = 'everness:forsaken_tundra_under_glowing_pillar',
    deco_type = 'simple',
    place_on = { 'everness:mold_stone_with_moss' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:forsaken_tundra_under' },
    y_max = y_max - 1000 > y_min and y_max - 1000 or y_max,
    y_min = y_min,
    decoration = { 'everness:glowing_pillar' },
    flags = 'all_floors',
})

local function register_agave_leaf_decoration(offset, scale, length)
    Everness:register_decoration({
        name = 'everness:forsaken_tundra_under_agave_leaf_' .. length,
        deco_type = 'simple',
        place_on = { 'everness:mold_stone_with_moss' },
        sidelen = 16,
        noise_params = {
            offset = offset,
            scale = scale,
            spread = { x = 200, y = 200, z = 200 },
            seed = 329,
            octaves = 3,
            persist = 0.6
        },
        param2 = 8,
        biomes = { 'everness:forsaken_tundra_under' },
        y_max = y_max,
        y_min = y_min,
        decoration = 'everness:agave_leaf_' .. length,
        flags = 'all_floors'
    })
end

-- Grasses

register_agave_leaf_decoration(-0.03, 0.09, 3)
register_agave_leaf_decoration(-0.015, 0.075, 2)
register_agave_leaf_decoration(0, 0.06, 1)

--
-- On Generated
--

local biome_id_everness_forsaken_tundra_under = minetest.get_biome_id('everness:forsaken_tundra_under')

local deco_id_everness_forsaken_tundra_under_willow_tree = minetest.get_decoration_id('everness:forsaken_tundra_under_willow_tree')

local willow_tree_schem = minetest.get_modpath('everness') .. '/schematics/everness_willow_tree.mts'
local size = { x = 39, y = 28, z = 39 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local safe_volume = (size.x * size.y * size.z) / 1.5
local y_dis = 1
local willow_tree_place_on = minetest.registered_decorations['everness:forsaken_tundra_under_willow_tree'].place_on
willow_tree_place_on = type(willow_tree_place_on) == 'string' and { willow_tree_place_on } or willow_tree_place_on

minetest.set_gen_notify({ decoration = true }, { deco_id_everness_forsaken_tundra_under_willow_tree })

Everness:add_to_queue_on_generated({
    name = 'everness:forsaken_tundra_under',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_forsaken_tundra_under) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        --
        -- Willow Tree
        --

        for _, pos in ipairs(gennotify['decoration#' .. (deco_id_everness_forsaken_tundra_under_willow_tree or '')] or {}) do
            -- `pos` is position of the 'place_on' node
            local marker_pos = vector.new(pos.x, pos.y + 1, pos.z)
            local marker_node = minetest.get_node(marker_pos)
            local place_on_node = minetest.get_node(pos)

            if marker_node and marker_node.name == 'everness:marker' then
                -- remove marker
                minetest.remove_node(marker_pos)

                if table.indexof(willow_tree_place_on, place_on_node.name) ~= -1 then
                    -- enough air to place structure ?
                    local positions = minetest.find_nodes_in_area(
                        vector.new(
                            pos.x - size_x,
                            pos.y - y_dis,
                            pos.z - size_z
                        ),
                        vector.new(
                            pos.x + size_x,
                            pos.y - y_dis + size.y,
                            pos.z + size_z
                        ),
                        {
                            'air',
                            'everness:willow_tree'
                        },
                        true
                    )

                    local air = positions.air or {}
                    local tree = positions['everness:willow_tree'] or {}

                    if #air > safe_volume and #tree == 0 then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            vector.new(marker_pos.x, marker_pos.y - y_dis, marker_pos.z),
                            willow_tree_schem,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        -- minetest.log('action', '[Everness] Willow Tree was placed at ' .. pos:to_string())
                    end
                end
            end
        end
    end
})
