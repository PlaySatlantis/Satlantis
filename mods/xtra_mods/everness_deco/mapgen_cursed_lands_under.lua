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

local y_max = Everness.settings.biomes.everness_cursed_lands_under.y_max
local y_min = Everness.settings.biomes.everness_cursed_lands_under.y_min

-- Cursed Lands Under

Everness:register_biome({
    name = 'everness:cursed_lands_under',
    node_cave_liquid = { 'mapgen_water_source', 'mapgen_lava_source' },
    node_dungeon = 'everness:cursed_brick',
    node_dungeon_alt = 'everness:cursed_brick_with_growth',
    node_dungeon_stair = 'stairs:stair_cursed_brick',
    y_max = y_max,
    y_min = y_min,
    heat_point = 45,
    humidity_point = 85,
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:cursed_lands_under_soul_sandstone_floors',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    place_offset_y = -1,
    sidelen = 16,
    fill_ratio = 10,
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors, force_placement',
    decoration = {
        'everness:soul_sandstone_veined'
    },
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_mold_stone_ceilings',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    fill_ratio = 0.4,
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    decoration = {
        'everness:moss_block'
    },
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_skull_with_candle',
    deco_type = 'simple',
    place_on = { 'everness:soul_sandstone_veined' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max - 1000 > y_min and y_max - 1000 or y_max,
    y_min = y_min,
    decoration = 'everness:skull_with_candle',
    flags = 'all_floors',
    param2_max = 3
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_vines',
    deco_type = 'simple',
    place_on = { 'everness:moss_block' },
    sidelen = 16,
    fill_ratio = 0.09,
    biomes = { 'everness:cursed_lands_under' },
    param2 = 8,
    decoration = {
        'everness:eye_vine_1',
        'everness:eye_vine_2',
        'everness:ivis_vine_1',
        'everness:ivis_vine_2'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    spawn_by = 'air',
    num_spawn_by = 8
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_pumpkin_lantern',
    deco_type = 'simple',
    place_on = { 'everness:soul_sandstone_veined' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = { 'everness:cursed_pumpkin_lantern' },
    flags = 'all_floors',
    param2_max = 3
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_cursed_dream_tree',
    deco_type = 'simple',
    place_on = { 'everness:soul_sandstone_veined' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max - 1500 > y_min and y_max - 1500 or y_max,
    y_min = y_min,
    flags = 'all_floors',
    decoration = {
        'everness:marker'
    },
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_plants',
    deco_type = 'simple',
    place_on = { 'everness:soul_sandstone_veined' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = {
        'everness:egg_plant',
        'everness:ngrass_1',
        'everness:ngrass_2',
    },
    flags = 'all_floors',
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_ivis_moss',
    deco_type = 'simple',
    place_on = { 'everness:soul_sandstone_veined' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.02,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = {
        'everness:ivis_moss',
    },
    flags = 'all_floors',
    param2 = 3
})

Everness:register_decoration({
    name = 'everness:cursed_lands_under_cobweb_floors',
    deco_type = 'simple',
    place_on = { 'everness:soul_sandstone_veined' },
    sidelen = 16,
    fill_ratio = 0.02,
    biomes = { 'everness:cursed_lands_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:cobweb' },
    flags = 'all_floors'
})

--
-- On Generated
--

local biome_id_everness_cursed_lands_under = minetest.get_biome_id('everness:cursed_lands_under')

local deco_id_cursed_lands_under_cursed_dream_tree = minetest.get_decoration_id('everness:cursed_lands_under_cursed_dream_tree')

local schem_cursed_dream_tree = minetest.get_modpath('everness') .. '/schematics/everness_cursed_dream_tree.mts'
local cursed_dream_tree_size = { x = 17, y = 15, z = 17 }
local cursed_dream_tree_size_x = math.round(cursed_dream_tree_size.x / 2)
local cursed_dream_tree_size_z = math.round(cursed_dream_tree_size.z / 2)
local cursed_dream_tree_safe_volume = (cursed_dream_tree_size.x * cursed_dream_tree_size.y * cursed_dream_tree_size.z) / 1.5
local cursed_dream_tree_y_dis = 1
local cursed_dream_tree_place_on = minetest.registered_decorations['everness:cursed_lands_under_cursed_dream_tree'].place_on
cursed_dream_tree_place_on = type(cursed_dream_tree_place_on) == 'string' and { cursed_dream_tree_place_on } or cursed_dream_tree_place_on

minetest.set_gen_notify({ decoration = true }, { deco_id_cursed_lands_under_cursed_dream_tree })

Everness:add_to_queue_on_generated({
    name = 'everness:cursed_lands_under',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_cursed_lands_under) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        --
        -- Cursed Dream Tree
        --
        for _, pos in ipairs(gennotify['decoration#' .. (deco_id_cursed_lands_under_cursed_dream_tree or '')] or {}) do
            -- `pos` is position of the 'place_on' node
            local marker_pos = vector.new(pos.x, pos.y + 1, pos.z)
            local marker_node = minetest.get_node(marker_pos)
            local place_on_node = minetest.get_node(pos)

            if marker_node and marker_node.name == 'everness:marker' then
                -- remove marker
                minetest.remove_node(marker_pos)

                if table.indexof(cursed_dream_tree_place_on, place_on_node.name) ~= -1 then
                    -- enough air to place structure ?
                    local positions = minetest.find_nodes_in_area(
                        vector.new(
                            pos.x - cursed_dream_tree_size_x,
                            pos.y - cursed_dream_tree_y_dis,
                            pos.z - cursed_dream_tree_size_z
                        ),
                        vector.new(
                            pos.x + cursed_dream_tree_size_x,
                            pos.y - cursed_dream_tree_y_dis + cursed_dream_tree_size.y,
                            pos.z + cursed_dream_tree_size_z
                        ),
                        {
                            'air',
                            'everness:dry_tree'
                        },
                        true
                    )

                    local air = positions.air or {}
                    local tree = positions['everness:dry_tree'] or {}

                    if #air > cursed_dream_tree_safe_volume and #tree <= 1 then
                        minetest.place_schematic_on_vmanip(
                            vm,
                            vector.new(marker_pos.x, marker_pos.y - cursed_dream_tree_y_dis, marker_pos.z),
                            schem_cursed_dream_tree,
                            'random',
                            nil,
                            true,
                            'place_center_x, place_center_z'
                        )

                        -- minetest.log('action', '[Everness] Cursed Dream Tree was placed at ' .. pos:to_string())
                    end
                end
            end
        end
    end
})
