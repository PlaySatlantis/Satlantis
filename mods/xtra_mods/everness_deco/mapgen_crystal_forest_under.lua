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

local y_max = Everness.settings.biomes.everness_crystal_forest_under.y_max
local y_min = Everness.settings.biomes.everness_crystal_forest_under.y_min

-- Crystal Forest Under

Everness:register_biome({
    name = 'everness:crystal_forest_under',
    node_cave_liquid = { 'mapgen_water_source', 'mapgen_lava_source' },
    node_dungeon = 'everness:crystal_cobble',
    node_dungeon_alt = 'everness:crystal_mossy_cobble',
    node_dungeon_stair = 'stairs:stair_crystal_cobble',
    y_max = y_max,
    y_min = y_min,
    heat_point = 35,
    humidity_point = 50,
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:crystal_forest_under_floors',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 10,
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = {
        'everness:crystal_cave_dirt_with_moss',
        'everness:crystal_moss_block'
    },
    flags = 'all_floors, force_placement'
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_ceilings',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    fill_ratio = 0.4,
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    decoration = {
        'everness:crystal_moss_block'
    },
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_vines',
    deco_type = 'simple',
    place_on = { 'everness:crystal_moss_block' },
    sidelen = 16,
    fill_ratio = 0.09,
    biomes = { 'everness:crystal_forest_under' },
    param2 = 8,
    decoration = {
        'everness:twisted_vine_1',
        'everness:twisted_vine_2',
        'everness:golden_vine_1',
        'everness:golden_vine_2'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    spawn_by = 'air',
    num_spawn_by = 8
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_crystal_cluster',
    deco_type = 'simple',
    place_on = {
        'everness:crystal_cave_dirt_with_moss',
        'everness:crystal_moss_block'
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
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max - 1000 > y_min and y_max - 1000 or y_max,
    y_min = y_min,
    flags = 'all_floors',
    decoration = {
        'everness:marker'
    },
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_crystal_sphere_cluster',
    deco_type = 'simple',
    place_on = {
        'everness:crystal_cave_dirt_with_moss',
        'everness:crystal_moss_block'
    },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.0005,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max - 1500 > y_min and y_max - 1500 or y_max,
    y_min = y_min,
    flags = 'all_floors',
    decoration = {
        'everness:marker'
    },
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_crystal_cyan',
    deco_type = 'simple',
    place_on = {
        'everness:crystal_cave_dirt_with_moss',
        'everness:crystal_moss_block'
    },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = {
        'everness:crystal_cyan',
        'everness:crystal_purple',
        'everness:crystal_orange'
    },
    flags = 'all_floors',
    param2 = 1
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_twisted_crystal_grass',
    deco_type = 'simple',
    place_on = {
        'everness:crystal_cave_dirt_with_moss',
        'everness:crystal_moss_block'
    },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.2,
        spread = { x = 100, y = 100, z = 100 },
        seed = 801,
        octaves = 3,
        persist = 0.7
    },
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = 'everness:twisted_crystal_grass',
    flags = 'all_floors',
    param2 = 40
})

Everness:register_decoration({
    name = 'everness:crystal_forest_under_crystal_cyan_ceiling',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:crystal_forest_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = {
        'everness:crystal_cyan',
        'everness:crystal_purple',
        'everness:crystal_orange'
    },
    flags = 'all_ceilings',
})

--
-- On Generated
--

local biome_id_everness_crystal_forest_under = minetest.get_biome_id('everness:crystal_forest_under')

local deco_id_crystal_forest_under_crystal_cluster = minetest.get_decoration_id('everness:crystal_forest_under_crystal_cluster')
local deco_id_crystal_forest_under_crystal_sphere_cluster = minetest.get_decoration_id('everness:crystal_forest_under_crystal_sphere_cluster')

-- `minetest.read_schematic` here so we don't cache the schem file, otherwise `replacements` will not work
local schem_crystal_cluster = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_crystal_orange_cluster.mts', {})
local crystal_cluster_size = { x = 8, y = 4, z = 7}
local crystal_cluster_size_x = math.round(crystal_cluster_size.x / 2)
local crystal_cluster_size_z = math.round(crystal_cluster_size.z / 2)
local crystal_cluster_safe_volume = (crystal_cluster_size.x * crystal_cluster_size.y * crystal_cluster_size.z) / 2
local crystal_cluster_place_on = minetest.registered_decorations['everness:crystal_forest_under_crystal_cluster'].place_on
crystal_cluster_place_on = type(crystal_cluster_place_on) == 'string' and { crystal_cluster_place_on } or crystal_cluster_place_on

-- `minetest.read_schematic` here so we don't cache the schem file, otherwise `replacements` will not work
local schem_crystal_sphere_cluster = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_crystal_purple_cluster.mts', {})
local crystal_sphere_cluster_size = { x = 20, y = 19, z = 19 }
local crystal_sphere_cluster_size_x = math.round(crystal_sphere_cluster_size.x / 2)
local crystal_sphere_cluster_size_z = math.round(crystal_sphere_cluster_size.z / 2)
local crystal_sphere_cluster_safe_volume = (crystal_sphere_cluster_size.x * crystal_sphere_cluster_size.y * crystal_sphere_cluster_size.z) / 2
local crystal_sphere_cluster_place_on = minetest.registered_decorations['everness:crystal_forest_under_crystal_sphere_cluster'].place_on
crystal_sphere_cluster_place_on = type(crystal_sphere_cluster_place_on) == 'string' and { crystal_sphere_cluster_place_on } or crystal_sphere_cluster_place_on

minetest.set_gen_notify({ decoration = true }, {
    deco_id_crystal_forest_under_crystal_cluster,
    deco_id_crystal_forest_under_crystal_sphere_cluster
})

Everness:add_to_queue_on_generated({
    name = 'everness:crystal_forest_under',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_crystal_forest_under) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        --
        -- Crystal Cluster
        --
        for _, pos in ipairs(gennotify['decoration#' .. (deco_id_crystal_forest_under_crystal_cluster or '')] or {}) do
            -- `pos` is position of the 'place_on' node
            local marker_pos = vector.new(pos.x, pos.y + 1, pos.z)
            local marker_node = minetest.get_node(marker_pos)
            local place_on_node = minetest.get_node(pos)

            if marker_node and marker_node.name == 'everness:marker' then
                -- remove marker
                minetest.remove_node(marker_pos)

                if table.indexof(crystal_cluster_place_on, place_on_node.name) ~= -1 then
                    -- enough air to place structure ?
                    local positions = minetest.find_nodes_in_area(
                        vector.new(
                            pos.x - crystal_cluster_size_x,
                            pos.y,
                            pos.z - crystal_cluster_size_z
                        ),
                        vector.new(
                            pos.x + crystal_cluster_size_x,
                            pos.y + crystal_cluster_size.y,
                            pos.z + crystal_cluster_size_z
                        ),
                        {
                            'air'
                        },
                        true
                    )

                    local air = positions.air or {}

                    if #air > crystal_cluster_safe_volume then
                        local replacements
                        local rand_color

                        if rand:next(0, 100) < 25 then
                            local colors = { 'purple', 'cyan' }
                            rand_color = colors[rand:next(1, #colors)]

                            replacements = {
                                ['everness:crystal_block_orange'] = 'everness:crystal_block_' .. rand_color,
                                ['everness:crystal_orange'] = 'everness:crystal_' .. rand_color
                            }
                        end

                        minetest.place_schematic_on_vmanip(
                            vm,
                            vector.new(marker_pos.x, marker_pos.y, marker_pos.z),
                            schem_crystal_cluster,
                            'random',
                            replacements,
                            true,
                            'place_center_x, place_center_z'
                        )

                        -- minetest.log('action', '[Everness] Crystal Cluster ' .. (rand_color or 'orange') .. ' was placed at ' .. pos:to_string())
                    end
                end
            end
        end

        --
        -- Crystal Sphere Cluster
        --
        for _, pos in ipairs(gennotify['decoration#' .. (deco_id_crystal_forest_under_crystal_sphere_cluster or '')] or {}) do
            -- `pos` is position of the 'place_on' node
            local marker_pos = vector.new(pos.x, pos.y + 1, pos.z)
            local marker_node = minetest.get_node(marker_pos)
            local place_on_node = minetest.get_node(pos)
            local crystal_sphere_cluster_y_dis = rand:next(5, 9)

            if marker_node and marker_node.name == 'everness:marker' then
                -- remove marker
                minetest.remove_node(marker_pos)

                if table.indexof(crystal_sphere_cluster_place_on, place_on_node.name) ~= -1 then
                    -- enough air to place structure ?
                    local positions = minetest.find_nodes_in_area(
                        vector.new(
                            pos.x - crystal_sphere_cluster_size_x,
                            pos.y - crystal_sphere_cluster_y_dis,
                            pos.z - crystal_sphere_cluster_size_z
                        ),
                        vector.new(
                            pos.x + crystal_sphere_cluster_size_x,
                            pos.y - crystal_sphere_cluster_y_dis + crystal_sphere_cluster_size.y,
                            pos.z + crystal_sphere_cluster_size_z
                        ),
                        {
                            'air',
                            'everness:coral_tree',
                            'everness:crystal_block_orange',
                            'everness:crystal_block_purple',
                            'everness:crystal_block_cyan',
                        },
                        true
                    )

                    local air = positions.air or {}
                    local tree = positions['everness:coral_tree'] or {}
                    local block_orange = positions['everness:crystal_block_orange'] or {}
                    local block_purple = positions['everness:crystal_block_purple'] or {}
                    local block_cyan = positions['everness:crystal_block_cyan'] or {}

                    if
                        #air > crystal_sphere_cluster_safe_volume
                        -- do not overlap
                        and not (
                            #tree > 0
                            or #block_orange > 0
                            or #block_purple > 0
                            or #block_cyan > 0
                        )
                    then
                        local replacements
                        local rand_color

                        if rand:next(0, 100) < 25 then
                            local colors = { 'orange', 'cyan' }
                            rand_color = colors[rand:next(1, #colors)]

                            replacements = {
                                ['everness:crystal_block_purple'] = 'everness:crystal_block_' .. rand_color,
                                ['everness:crystal_purple'] = 'everness:crystal_' .. rand_color
                            }
                        end

                        minetest.place_schematic_on_vmanip(
                            vm,
                            vector.new(marker_pos.x, marker_pos.y - crystal_sphere_cluster_y_dis, marker_pos.z),
                            schem_crystal_sphere_cluster,
                            'random',
                            replacements,
                            true,
                            'place_center_x, place_center_z'
                        )

                        -- minetest.log('action', '[Everness] Crystal Sphere Cluster ' .. (rand_color or 'orange') .. ' was placed at ' .. pos:to_string())
                    end
                end
            end
        end
    end
})
