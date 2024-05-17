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

local y_max = Everness.settings.biomes.everness_mineral_waters_under.y_max
local y_min = Everness.settings.biomes.everness_mineral_waters_under.y_min

-- Mineral Waters

Everness:register_biome({
    name = 'everness:mineral_waters_under',
    node_stone = 'everness:mineral_cave_stone',
    node_filler = 'everness:mineral_cave_stone',
    node_cave_liquid = 'everness:lava_source',
    node_water = 'air',
    node_dungeon = 'everness:mineral_stone_brick',
    node_dungeon_alt = 'everness:mineral_stone_brick_with_growth',
    node_dungeon_stair = 'stairs:stair_mineral_stone_brick',
    y_max = y_max,
    y_min = y_min,
    vertical_blend = 16,
    heat_point = 78,
    humidity_point = 58,
})

--
-- Ores
--

minetest.register_on_mods_loaded(function()
    local c_mapgen_stone = minetest.get_content_id('mapgen_stone')
    local mapgen_stone_itemstring = minetest.get_name_from_content_id(c_mapgen_stone)

    for name, def in pairs(minetest.registered_ores) do
        local wherein = def.wherein
        local biomes = def.biomes

        if type(def.wherein) == 'string' then
            wherein = { wherein }
        end

        -- Register the same ores what are defined for `mapgen_stone`
        if
            table.indexof(wherein, mapgen_stone_itemstring) > -1
            and not biomes
        then
            def.wherein = { 'everness:mineral_cave_stone' }
            def.biomes = { 'everness:mineral_waters_under' }
            def.y_max = y_max
            def.y_min = y_min

            Everness:register_ore(def)
        end
    end
end)

-- Blob ore.
-- These before scatter ores to avoid other ores in blobs.

Everness:register_ore({
    ore_type = 'blob',
    ore = 'everness:mineral_stone',
    wherein = { 'everness:mineral_cave_stone' },
    clust_scarcity = 16 * 16 * 16,
    clust_size = 5,
    y_max = y_max,
    y_min = y_min,
    noise_threshold = 0.0,
    noise_params = {
        offset = 0.5,
        scale = 0.2,
        spread = { x = 5, y = 5, z = 5 },
        seed = 766,
        octaves = 1,
        persist = 0.0
    },
    biomes = { 'everness:mineral_waters_under' }
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:mineral_waters_under_floors',
    deco_type = 'simple',
    place_on = { 'everness:mineral_cave_stone' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 10,
    biomes = { 'everness:mineral_waters_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors, force_placement',
    decoration = {
        'everness:mineral_lava_stone'
    },
})

--
-- Floors
--

Everness:register_decoration({
    name = 'everness:mineral_waters_under_volcanic_spike',
    deco_type = 'simple',
    place_on = {
        'everness:mineral_lava_stone',
        'everness:mineral_cave_stone'
    },
    sidelen = 16,
    noise_params = {
        offset = -0.03,
        scale = 0.09,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:mineral_waters_under' },
    spawn_by = 'air',
    check_offset = 0,
    num_spawn_by = 1,
    decoration = {
        'everness:marker'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors',
})

Everness:register_decoration({
    name = 'everness:mineral_waters_under_lava_stone_spike',
    deco_type = 'simple',
    place_on = {
        'everness:mineral_lava_stone',
        'everness:mineral_cave_stone'
    },
    sidelen = 16,
    noise_params = {
        offset = -0.015,
        scale = 0.075,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:mineral_waters_under' },
    decoration = {
        'everness:marker'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors',
})

Everness:register_decoration({
    name = 'everness:mineral_waters_under_lava_tree',
    deco_type = 'simple',
    place_on = {
        'everness:mineral_lava_stone',
        'everness:mineral_cave_stone',
        'everness:mineral_lava_stone_with_moss'
    },
    sidelen = 16,
    fill_ratio = 0.025,
    biomes = { 'everness:mineral_waters_under' },
    decoration = {
        'everness:marker'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors',
})

--
-- Ceilings
--

Everness:register_decoration({
    name = 'everness:mineral_waters_under_volcanic_spike_ceiling',
    deco_type = 'simple',
    place_on = {
        'everness:mineral_lava_stone',
        'everness:mineral_cave_stone'
    },
    sidelen = 16,
    noise_params = {
        offset = -0.03,
        scale = 0.09,
        spread = { x = 200, y = 200, z = 200 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:mineral_waters_under' },
    decoration = {
        'everness:marker'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
})

--
-- On Generated
--

-- Get the content IDs for the nodes used
local c_everness_wall_vine_cave_cyan = minetest.get_content_id('everness:wall_vine_cave_cyan')
local c_everness_wall_vine_cave_violet = minetest.get_content_id('everness:wall_vine_cave_violet')
local c_everness_wall_vine_cave_blue = minetest.get_content_id('everness:wall_vine_cave_blue')
local c_everness_mineral_lava_stone = minetest.get_content_id('everness:mineral_lava_stone')
local c_everness_mineral_cave_stone = minetest.get_content_id('everness:mineral_cave_stone')
local c_everness_mineral_cave_cobblestone = minetest.get_content_id('everness:mineral_cave_cobblestone')
local c_everness_lava_source = minetest.get_content_id('everness:lava_source')
local c_everness_marker = minetest.get_content_id('everness:marker')
local c_everness_volcanic_rock = minetest.get_content_id('everness:volcanic_rock')
local c_everness_volcanic_spike_1 = minetest.get_content_id('everness:volcanic_spike_1')
local c_everness_volcanic_spike_2 = minetest.get_content_id('everness:volcanic_spike_2')
local c_everness_volcanic_spike_3 = minetest.get_content_id('everness:volcanic_spike_3')
local c_everness_volcanic_spike_4 = minetest.get_content_id('everness:volcanic_spike_4')
local c_everness_volcanic_spike_5 = minetest.get_content_id('everness:volcanic_spike_5')
local c_everness_volcanic_spike_6 = minetest.get_content_id('everness:volcanic_spike_6')
local c_everness_volcanic_spike_7 = minetest.get_content_id('everness:volcanic_spike_7')
local c_everness_mineral_cave_stone_spike_1 = minetest.get_content_id('everness:mineral_cave_stone_spike_1')
local c_everness_mineral_cave_stone_spike_2 = minetest.get_content_id('everness:mineral_cave_stone_spike_2')
local c_everness_mineral_cave_stone_spike_3 = minetest.get_content_id('everness:mineral_cave_stone_spike_3')
local c_everness_mineral_cave_stone_spike_4 = minetest.get_content_id('everness:mineral_cave_stone_spike_4')
local c_everness_mineral_cave_stone_spike_5 = minetest.get_content_id('everness:mineral_cave_stone_spike_5')
local c_everness_mineral_cave_stone_spike_6 = minetest.get_content_id('everness:mineral_cave_stone_spike_6')
local c_everness_mineral_cave_stone_spike_7 = minetest.get_content_id('everness:mineral_cave_stone_spike_7')
local c_everness_mineral_lava_stone_spike_1 = minetest.get_content_id('everness:mineral_lava_stone_spike_1')
local c_everness_mineral_lava_stone_spike_2 = minetest.get_content_id('everness:mineral_lava_stone_spike_2')
local c_everness_mineral_lava_stone_spike_3 = minetest.get_content_id('everness:mineral_lava_stone_spike_3')
local c_everness_mineral_lava_stone_spike_4 = minetest.get_content_id('everness:mineral_lava_stone_spike_4')
local c_everness_mineral_lava_stone_spike_5 = minetest.get_content_id('everness:mineral_lava_stone_spike_5')
local c_everness_mineral_lava_stone_spike_6 = minetest.get_content_id('everness:mineral_lava_stone_spike_6')
local c_everness_mineral_lava_stone_spike_7 = minetest.get_content_id('everness:mineral_lava_stone_spike_7')
local c_everness_mineral_lava_stone_with_moss = minetest.get_content_id('everness:mineral_lava_stone_with_moss')
-- Biome IDs
local biome_id_everness_mineral_waters_under = minetest.get_biome_id('everness:mineral_waters_under')
-- Decoration IDs
local d_everness_mineral_waters_under_volcanic_spike = minetest.get_decoration_id('everness:mineral_waters_under_volcanic_spike')
local d_everness_mineral_waters_under_volcanic_spike_ceiling = minetest.get_decoration_id('everness:mineral_waters_under_volcanic_spike_ceiling')
local d_everness_mineral_waters_under_lava_stone_spike = minetest.get_decoration_id('everness:mineral_waters_under_lava_stone_spike')
local d_everness_mineral_waters_under_lava_tree = minetest.get_decoration_id('everness:mineral_waters_under_lava_tree')

local volcanic_spike_place_on = minetest.registered_decorations['everness:mineral_waters_under_volcanic_spike'].place_on
volcanic_spike_place_on = type(volcanic_spike_place_on) == 'string' and { volcanic_spike_place_on } or volcanic_spike_place_on

local volcanic_spike_ceiling_place_on = minetest.registered_decorations['everness:mineral_waters_under_volcanic_spike_ceiling'].place_on
volcanic_spike_ceiling_place_on = type(volcanic_spike_ceiling_place_on) == 'string' and { volcanic_spike_ceiling_place_on } or volcanic_spike_ceiling_place_on

local lava_stone_spike_place_on = minetest.registered_decorations['everness:mineral_waters_under_lava_stone_spike'].place_on
lava_stone_spike_place_on = type(lava_stone_spike_place_on) == 'string' and { lava_stone_spike_place_on } or lava_stone_spike_place_on

local lava_tree_place_on = minetest.registered_decorations['everness:mineral_waters_under_lava_tree'].place_on
lava_tree_place_on = type(lava_tree_place_on) == 'string' and { lava_tree_place_on } or lava_tree_place_on

-- `minetest.read_schematic` here so we don't cache the schem file, otherwise `replacements` will not work
local schem_everness_lava_tree = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_lava_tree.mts', {})
local lava_tree_size = { x = 7, y = 13, z = 7 }
local lava_tree_size_x = math.round(lava_tree_size.x / 2)
local lava_tree_size_z = math.round(lava_tree_size.z / 2)
local lava_tree_safe_volume = lava_tree_size.x * lava_tree_size.y * lava_tree_size.z

local wall_vines = {
    c_everness_wall_vine_cave_cyan,
    c_everness_wall_vine_cave_violet,
    c_everness_wall_vine_cave_blue
}

local volcanic_spike_map = {
    c_everness_volcanic_rock,
    c_everness_volcanic_spike_1,
    c_everness_volcanic_spike_2,
    c_everness_volcanic_spike_3,
    c_everness_volcanic_spike_4,
    c_everness_volcanic_spike_5,
    c_everness_volcanic_spike_6,
    c_everness_volcanic_spike_7
}

local cave_stone_spike_map = {
    c_everness_mineral_cave_cobblestone,
    c_everness_mineral_cave_stone_spike_1,
    c_everness_mineral_cave_stone_spike_2,
    c_everness_mineral_cave_stone_spike_3,
    c_everness_mineral_cave_stone_spike_4,
    c_everness_mineral_cave_stone_spike_5,
    c_everness_mineral_cave_stone_spike_6,
    c_everness_mineral_cave_stone_spike_7
}

local lava_stone_spike_map = {
    c_everness_mineral_lava_stone,
    c_everness_mineral_lava_stone_spike_1,
    c_everness_mineral_lava_stone_spike_2,
    c_everness_mineral_lava_stone_spike_3,
    c_everness_mineral_lava_stone_spike_4,
    c_everness_mineral_lava_stone_spike_5,
    c_everness_mineral_lava_stone_spike_6,
    c_everness_mineral_lava_stone_spike_7
}

minetest.set_gen_notify({ decoration = true }, {
    d_everness_mineral_waters_under_volcanic_spike,
    d_everness_mineral_waters_under_lava_stone_spike,
    d_everness_mineral_waters_under_volcanic_spike_ceiling,
    d_everness_mineral_waters_under_lava_tree
})

Everness:add_to_queue_on_generated({
    name = 'everness:mineral_waters_under',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_mineral_waters_under) ~= -1
    end,
    -- read/write to `data` what will be eventually saved (set_data)
    -- used for voxelmanip `data` manipulation
    on_data = function(minp, maxp, area, data, p2data, gennotify, rand, shared_args)
        local rand_version = rand:next(1, 2)
        shared_args.rand_version = rand_version

        if rand_version == 1 then
            --
            -- Lakes
            --
            for z = minp.z, maxp.z do
                for y = minp.y, maxp.y do
                    for x = minp.x, maxp.x do
                        local ai = area:index(x, y, z)
                        local c_current = data[ai]

                        -- +Y, -Y, +X, -X, +Z, -Z
                        -- top, bottom, right, left, front, back
                        -- right
                        local c_right = data[ai + 1]
                        -- left
                        local c_left = data[ai - 1]
                        -- front
                        local c_front = data[ai + area.zstride]
                        -- back
                        local c_back = data[ai - area.zstride]

                        local keep_going = true
                        local while_count = 1
                        local max_dig_depth = 11

                        if
                            c_current == c_everness_mineral_lava_stone
                            and (
                                c_right == c_everness_mineral_lava_stone
                                or c_right == c_everness_mineral_cave_stone
                                or c_right == c_everness_lava_source
                            )
                            and (
                                c_left == c_everness_mineral_lava_stone
                                or c_left == c_everness_mineral_cave_stone
                                or c_left == c_everness_lava_source
                            )
                            and (
                                c_front == c_everness_mineral_lava_stone
                                or c_front == c_everness_mineral_cave_stone
                                or c_front == c_everness_lava_source
                            )
                            and (
                                c_back == c_everness_mineral_lava_stone
                                or c_back == c_everness_mineral_cave_stone
                                or c_back == c_everness_lava_source
                            )
                        then
                            -- dig below
                            while keep_going and while_count <= max_dig_depth do
                                local while_index = ai - area.ystride * while_count

                                if
                                    -- below
                                    data[while_index] == c_everness_mineral_cave_stone
                                    and (
                                        -- right
                                        data[while_index + 1 + area.ystride] == c_everness_mineral_lava_stone
                                        or data[while_index + 1 + area.ystride] == c_everness_lava_source
                                        or data[while_index + 1 + area.ystride] == c_everness_mineral_cave_stone
                                    )
                                    and (
                                        -- left
                                        data[while_index - 1 + area.ystride] == c_everness_mineral_lava_stone
                                        or data[while_index - 1 + area.ystride] == c_everness_lava_source
                                        or data[while_index - 1 + area.ystride] == c_everness_mineral_cave_stone
                                    )
                                    and (
                                        -- front
                                        data[while_index + area.zstride + area.ystride] == c_everness_mineral_lava_stone
                                        or data[while_index + area.zstride + area.ystride] == c_everness_lava_source
                                        or data[while_index + area.zstride + area.ystride] == c_everness_mineral_cave_stone
                                    )
                                    and (
                                        -- back
                                        data[while_index - area.zstride + area.ystride] == c_everness_mineral_lava_stone
                                        or data[while_index - area.zstride + area.ystride] == c_everness_lava_source
                                        or data[while_index - area.zstride + area.ystride] == c_everness_mineral_cave_stone
                                    )
                                then
                                    data[while_index + area.ystride] = c_everness_lava_source
                                else
                                    keep_going = false
                                end

                                while_count = while_count + 1
                            end
                        end
                    end
                end
            end
        else
            for y = minp.y, maxp.y do
                for z = minp.z, maxp.z do
                    for x = minp.x, maxp.x do
                        local ai = area:index(x, y, z)

                        if
                            data[ai] == c_everness_mineral_lava_stone
                            and data[ai + area.ystride] == minetest.CONTENT_AIR
                            and rand:next(0, 100) <= 10
                        then
                            local radius = 7
                            local chance_max = 80

                            for h = -3, 3 do
                                for i = -radius, radius do
                                    for j = -radius, radius do
                                        local idx = ai + i + (area.zstride * j) + (area.ystride * h)
                                        local distance = math.round(vector.distance(area:position(ai), area:position(idx)))
                                        local chance_moss = math.round(chance_max / distance)

                                        if chance_moss > chance_max then
                                            chance_moss = chance_max
                                        end

                                        if
                                            data[idx] == c_everness_mineral_lava_stone
                                            and rand:next(0, 100) < chance_moss
                                        then
                                            data[idx] = c_everness_mineral_lava_stone_with_moss
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        --
        -- Decorations
        --
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                for x = minp.x, maxp.x do
                    local vi = area:index(x, y, z)

                    if
                        data[vi] == minetest.CONTENT_AIR
                        and (
                            data[vi + 1] == c_everness_mineral_cave_stone
                            or data[vi - 1] == c_everness_mineral_cave_stone
                            or data[vi + area.zstride] == c_everness_mineral_cave_stone
                            or data[vi - area.zstride] == c_everness_mineral_cave_stone
                        )
                        and rand:next(0, 100) <= 15
                    then
                        -- Decorate Walls
                        local dir = vector.zero()

                        if data[vi + 1] == c_everness_mineral_cave_stone then
                            dir.x = 1
                        end

                        if data[vi - 1] == c_everness_mineral_cave_stone then
                            dir.x = -1
                        end

                        if data[vi + area.zstride] == c_everness_mineral_cave_stone then
                            dir.z = 1
                        end

                        if data[vi - area.zstride] == c_everness_mineral_cave_stone then
                            dir.z = -1
                        end

                        local rand_wall_vine = wall_vines[rand:next(1, #wall_vines)]
                        data[vi] = rand_wall_vine
                        p2data[vi] = minetest.dir_to_wallmounted(dir)
                    end
                end
            end
        end

        --
        -- Spikes Floor
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_mineral_waters_under_volcanic_spike or '')] or {}) do
            local idx = area:indexp(pos)
            local idx_marker = idx + area.ystride
            local place_on_node_name = minetest.get_name_from_content_id(data[idx])

            if data[idx_marker] == c_everness_marker then
                -- remove marker
                data[idx_marker] = minetest.CONTENT_AIR

                if table.indexof(volcanic_spike_place_on, place_on_node_name) ~= -1 then
                    local min_height = 3
                    local max_height = 8
                    local indexes = Everness.find_content_in_vm_area(
                        vector.new(pos.x, pos.y + 1, pos.z),
                        vector.new(pos.x, pos.y + max_height, pos.z),
                        {
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    -- For smallest spike we need space above at least 3)
                    if #indexes > min_height then
                        local height = rand:next(min_height, #indexes)
                        local start_index = #volcanic_spike_map - height + 1
                        local count = 0

                        for i = start_index, #volcanic_spike_map do
                            data[idx_marker + area.ystride * count] = volcanic_spike_map[i]
                            count = count + 1
                        end
                    end
                end
            end
        end

        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_mineral_waters_under_lava_stone_spike or '')] or {}) do
            local idx = area:indexp(pos)
            local idx_marker = idx + area.ystride
            local place_on_node_name = minetest.get_name_from_content_id(data[idx])

            if data[idx_marker] == c_everness_marker then
                -- remove marker
                data[idx_marker] = minetest.CONTENT_AIR

                if table.indexof(lava_stone_spike_place_on, place_on_node_name) ~= -1 then
                    local min_height = 3
                    local max_height = 8
                    local indexes = Everness.find_content_in_vm_area(
                        vector.new(pos.x, pos.y + 1, pos.z),
                        vector.new(pos.x, pos.y + max_height, pos.z),
                        {
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    -- For smallest spike we need space above at least 3)
                    if #indexes > min_height then
                        local height = rand:next(min_height, #indexes)
                        local start_index = #cave_stone_spike_map - height + 1
                        local count = 0

                        for i = start_index, #cave_stone_spike_map do
                            data[idx_marker + area.ystride * count] = cave_stone_spike_map[i]
                            count = count + 1
                        end
                    end
                end
            end
        end

        --
        -- Spikes Ceiling
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_mineral_waters_under_volcanic_spike_ceiling or '')] or {}) do
            local idx = area:indexp(pos)
            local idx_marker = idx - area.ystride
            local place_on_node_name = minetest.get_name_from_content_id(data[idx])

            if data[idx_marker] == c_everness_marker then
                -- remove marker
                data[idx_marker] = minetest.CONTENT_AIR
                -- data[idx_marker] = minetest.get_content_id('everness:pyrite_lantern')

                if table.indexof(volcanic_spike_ceiling_place_on, place_on_node_name) ~= -1 then
                    local min_height = 3
                    local max_height = 16
                    local indexes = Everness.find_content_in_vm_area(
                        vector.new(pos.x, pos.y - max_height, pos.z),
                        vector.new(pos.x, pos.y - 1, pos.z),
                        {
                            minetest.CONTENT_AIR
                        },
                        data,
                        area
                    )

                    -- For smallest spike we need space above at least 3)
                    if #indexes > min_height then
                        local remainder = 0
                        local height = rand:next(min_height, #indexes)

                        if height > #lava_stone_spike_map then
                            remainder = height - #lava_stone_spike_map
                            height = height - remainder
                        end

                        local start_index = #lava_stone_spike_map - height + 1
                        local count = 0

                        if remainder > 0 then
                            for i = 1, remainder do
                                data[idx_marker - area.ystride * count] = c_everness_mineral_cave_cobblestone
                                count = count + 1
                            end
                        end

                        for i = start_index, #lava_stone_spike_map do
                            data[idx_marker - area.ystride * count] = lava_stone_spike_map[i]
                            count = count + 1
                        end
                    end
                end
            end
        end
    end,
    -- read-only (but cant and should not manipulate) voxelmanip `data`
    -- used for `place_schematic_on_vmanip` which will invalidate `data`
    -- therefore we are doing it after we set the data
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        --
        -- Lava Trees
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_mineral_waters_under_lava_tree or '')] or {}) do
            -- `pos` is position of the 'place_on' node
            local marker_pos = vector.new(pos.x, pos.y + 1, pos.z)
            local marker_node = minetest.get_node(marker_pos)
            local place_on_node = minetest.get_node(pos)

            if marker_node and marker_node.name == 'everness:marker' then
                -- remove marker
                minetest.remove_node(marker_pos)

                if shared_args.rand_version ~= 1
                    and table.indexof(lava_tree_place_on, place_on_node.name) ~= -1
                then
                    -- enough air to place structure ?
                    local positions = minetest.find_nodes_in_area(
                        vector.new(
                            pos.x - lava_tree_size_x,
                            pos.y,
                            pos.z - lava_tree_size_z
                        ),
                        vector.new(
                            pos.x + lava_tree_size_x,
                            pos.y + lava_tree_size.y,
                            pos.z + lava_tree_size_z
                        ),
                        {
                            'air',
                            'everness:lava_tree',
                            'everness:lava_tree_with_lava'
                        },
                        true
                    )

                    local air = positions.air or {}
                    local tree1 = positions['everness:lava_tree'] or {}
                    local tree2 = positions['everness:lava_tree_with_lava'] or {}

                    -- do not overlap another tree
                    if
                        #tree1 == 0
                        and #tree2 == 0
                        and #air > lava_tree_safe_volume
                    then
                        local replacements

                        if rand:next(0, 100) <= 25 then
                            replacements = {
                                ['everness:lava_tree'] = 'everness:lava_tree_with_lava',
                            }
                        end

                        shared_args.lava_tree_positions = shared_args.lava_tree_positions or {}
                        table.insert(shared_args.lava_tree_positions, marker_pos)

                        minetest.place_schematic_on_vmanip(
                            vm,
                            marker_pos,
                            schem_everness_lava_tree,
                            'random',
                            replacements,
                            false,
                            'place_center_x, place_center_z'
                        )
                    end
                end
            end
        end
    end,
    -- Cannot read/write voxelmanip or its data
    -- Used for direct manipulation of the world chunk nodes where the
    -- definitions of nodes are available and node callback can be executed
    -- or e.g. for `minetest.fix_light`
    after_write_to_map = function(shared_args, gennotify, rand)
        local lava_tree_positions = shared_args.lava_tree_positions or {}

        for _, p in ipairs(lava_tree_positions) do
            local grass_positions = minetest.find_nodes_in_area_under_air(
                vector.subtract(p, { x = 3, y = 1, z = 3 }),
                vector.add(p, { x = 3, y = 1, z = 3 }),
                'everness:mineral_lava_stone_with_moss'
            )

            if #grass_positions > 1 then
                for i = 1, rand:next(1, 3) do
                    local rand_p = grass_positions[rand:next(1, #grass_positions)]

                    if not vector.equals(p, rand_p) then
                        minetest.set_node(vector.new(rand_p.x, rand_p.y + 1, rand_p.z), { name = 'everness:mineral_cave_moss_grass' })
                    end
                end
            end
        end
    end
})
