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

local y_max = Everness.settings.biomes.everness_mineral_waters.y_max
local y_min = Everness.settings.biomes.everness_mineral_waters.y_min

-- Mineral Waters

Everness:register_biome({
    name = 'everness:mineral_waters',
    node_top = 'everness:mineral_sand',
    depth_top = 1,
    node_filler = 'everness:mineral_stone',
    depth_filler = 1,
    node_stone = 'everness:mineral_stone',
    node_riverbed = 'everness:mineral_sand',
    depth_riverbed = 2,
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
-- Register ores
--

-- Scatter ores

-- Coal

Everness:register_ore({
    ore_type = 'scatter',
    ore = 'everness:mineral_stone_with_coal',
    wherein = 'everness:mineral_stone',
    clust_scarcity = 8 * 8 * 8,
    clust_num_ores = 9,
    clust_size = 3,
    y_max = y_max,
    y_min = y_min,
    biomes = { 'everness:mineral_waters' }
})

Everness:register_ore({
    ore_type = 'scatter',
    ore = 'everness:mineral_stone_with_ceramic_sherds',
    wherein = 'everness:mineral_stone',
    clust_scarcity = 14 * 14 * 14,
    clust_num_ores = 5,
    clust_size = 3,
    y_max = y_max,
    y_min = y_min,
    biomes = { 'everness:mineral_waters' }
})

--
-- Register decorations
-- placeholder node `everness:crystal_stone` will be replaced in VM
--

Everness:register_decoration({
    name = 'everness:palm_trees',
    deco_type = 'simple',
    place_on = { 'everness:mineral_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.005,
        spread = { x = 250, y = 250, z = 250 },
        seed = 329,
        octaves = 3,
        persist = 0.6
    },
    biomes = { 'everness:mineral_waters' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:crystal_stone' },
})

Everness:register_decoration({
    name = 'everness:pots',
    deco_type = 'simple',
    place_on = { 'everness:mineral_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.002,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:mineral_waters' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:crystal_stone' },
    _decoration = {
        'everness:ceramic_pot_blank',
        'everness:ceramic_pot_flowers',
        'everness:ceramic_pot_lines',
        'everness:ceramic_pot_tribal'
    }
})

Everness:register_decoration({
    name = 'everness:water_geyser',
    deco_type = 'simple',
    place_on = { 'everness:mineral_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.02,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:mineral_waters' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:crystal_stone' },
    spawn_by = { 'air' },
    num_spawn_by = 16,
    check_offset = 1,
})

Everness:register_decoration({
    name = 'everness:rose_bush',
    deco_type = 'simple',
    place_on = { 'everness:mineral_sand' },
    sidelen = 16,
    noise_params = {
        offset = -0.004,
        scale = 0.01,
        spread = { x = 100, y = 100, z = 100 },
        seed = 137,
        octaves = 3,
        persist = 0.7,
    },
    biomes = { 'everness:mineral_waters' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:crystal_stone' },
    _decoration = { 'everness:rose_bush' },
    spawn_by = { 'air' },
    num_spawn_by = 16,
    check_offset = 1,
})

--
-- On Generated
--

local function find_irecursive(table, c_id)
    local found = false

    for i, v in ipairs(table) do
        if type(v) == 'table' then
            find_irecursive(v, c_id)
        end

        if c_id == v then
            found = true
            break
        end
    end

    return found
end

-- Get the content IDs for the nodes used
local c_everness_mineral_water_source = minetest.get_content_id('everness:mineral_water_source')
local c_everness_mineral_stone = minetest.get_content_id('everness:mineral_stone')
local c_everness_mineral_stone_brick = minetest.get_content_id('everness:mineral_stone_brick')
local c_everness_mineral_stone_brick_with_growth = minetest.get_content_id('everness:mineral_stone_brick_with_growth')
local c_everness_mineral_stone_brick_with_flower_growth = minetest.get_content_id('everness:mineral_stone_brick_with_flower_growth')
local c_everness_mineral_sand = minetest.get_content_id('everness:mineral_sand')
local c_everness_mineral_sandstone = minetest.get_content_id('everness:mineral_sandstone')
local c_everness_mineral_sandstone_block = minetest.get_content_id('everness:mineral_sandstone_block')
local c_everness_chest = minetest.get_content_id('everness:chest')
local c_everness_mineral_stone_with_coal = minetest.get_content_id('everness:mineral_stone_with_coal')
local c_everness_mineral_stone_with_ceramic_sherds = minetest.get_content_id('everness:mineral_stone_with_ceramic_sherds')
local c_everness_lotus_flower_white = minetest.get_content_id('everness:lotus_flower_white')
local c_everness_lotus_flower_purple = minetest.get_content_id('everness:lotus_flower_purple')
local c_everness_lotus_flower_pink = minetest.get_content_id('everness:lotus_flower_pink')
local c_everness_lotus_lotus_leaf = minetest.get_content_id('everness:lotus_leaf')
local c_everness_lotus_lotus_leaf_2 = minetest.get_content_id('everness:lotus_leaf_2')
local c_everness_lotus_lotus_leaf_3 = minetest.get_content_id('everness:lotus_leaf_3')
local c_everness_ceramic_pot_blank = minetest.get_content_id('everness:ceramic_pot_blank')
local c_everness_ceramic_pot_flowers = minetest.get_content_id('everness:ceramic_pot_flowers')
local c_everness_ceramic_pot_lines = minetest.get_content_id('everness:ceramic_pot_lines')
local c_everness_ceramic_pot_tribal = minetest.get_content_id('everness:ceramic_pot_tribal')
local c_everness_mineral_water_weed_1 = minetest.get_content_id('everness:mineral_water_weed_1')
local c_everness_mineral_water_weed_2 = minetest.get_content_id('everness:mineral_water_weed_2')
local c_everness_mineral_water_weed_3 = minetest.get_content_id('everness:mineral_water_weed_3')
-- Biome IDs
local biome_id_everness_mineral_waters = minetest.get_biome_id('everness:mineral_waters')
-- Decoration IDs
local d_everness_palm_trees = minetest.get_decoration_id('everness:palm_trees')
local d_everness_water_geyser = minetest.get_decoration_id('everness:water_geyser')
local d_everness_pots = minetest.get_decoration_id('everness:pots')
local d_rose_bush = minetest.get_decoration_id('everness:rose_bush')

-- Pool building blocks variations
local pool_build_nodes = {
    {
        c_everness_mineral_stone,
        c_everness_mineral_stone_brick,
        c_everness_mineral_stone_brick_with_growth,
        c_everness_mineral_stone_brick_with_flower_growth
    },
    {
        c_everness_mineral_sandstone,
        c_everness_mineral_sandstone_block
    }
}
local c_lotus_flowers = {
    c_everness_lotus_flower_white,
    c_everness_lotus_flower_purple,
    c_everness_lotus_flower_pink
}
local c_lotus_leaves = {
    c_everness_lotus_lotus_leaf,
    c_everness_lotus_lotus_leaf_2,
    c_everness_lotus_lotus_leaf_3
}
local c_pots = {
    c_everness_ceramic_pot_blank,
    c_everness_ceramic_pot_flowers,
    c_everness_ceramic_pot_lines,
    c_everness_ceramic_pot_tribal
}
local c_water_weeds = {
    c_everness_mineral_water_weed_1,
    c_everness_mineral_water_weed_2
}

local chance = 20
local disp = 16
local schem = minetest.get_modpath('everness') .. '/schematics/everness_mineral_waters_tower.mts'
local size = { x = 7, y = 16, z = 9 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)

local function place_decoration(pos, vm, area, data, deco_id, callback)
    local deco_def = minetest.registered_decorations[deco_id]

    if not deco_def then
        return
    end

    -- Position of the 'place_on' node
    local vi = area:indexp(pos)
    local place_on_valid = false
    local data_node_name = minetest.get_name_from_content_id(data[vi])
    local placeholder_node_name = type(deco_def.decoration) == 'string' and deco_def.decoration or deco_def.decoration[1]

    if type(deco_def.place_on) == 'string' then
        if deco_def.place_on == data_node_name and data[vi + area.ystride * 2] == minetest.CONTENT_AIR then
            place_on_valid = true
        end
    else
        for i, v in ipairs(deco_def.place_on) do
            if v == data_node_name and data[vi + area.ystride * 2] == minetest.CONTENT_AIR then
                place_on_valid = true
                break
            end
        end
    end

    local pos_above = vector.new(pos.x, pos.y + 1, pos.z)
    local node_above = vm:get_node_at(pos_above)

    if node_above.name == placeholder_node_name then
        if place_on_valid then
            callback(pos_above, deco_def)
        else
            vm:set_node_at(pos_above, { name = 'air' })
        end
    end
end

minetest.set_gen_notify({ decoration = true }, {
    d_everness_palm_trees,
    d_everness_water_geyser,
    d_everness_pots,
    d_rose_bush
})

Everness:add_to_queue_on_generated({
    name = 'everness:mineral_waters',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_mineral_waters) ~= -1
    end,
    on_data = function(minp, maxp, area, data, p2data, gennotify, rand, shared_args)
        local rand_version = rand:next(1, 2)
        local chest_positions = {}
        local pot_pos = {}

        if rand_version == 1 then
            --
            -- Pools
            --
            for y = minp.y, maxp.y do
                for z = minp.z, maxp.z do
                    local precision_perc = 75

                    for x = minp.x, maxp.x do
                        local ai = area:index(x, y, z)
                        local node_name = minetest.get_name_from_content_id(data[ai])
                        local node_def = minetest.registered_nodes[node_name]

                        if
                            data[ai + area.ystride] == minetest.CONTENT_AIR
                            and node_def
                            and node_def.walkable
                        then
                            local length = 5 + rand:next(0, 10)
                            local width = 5 + rand:next(0, 10)
                            local height = 3 + rand:next(0, 4)
                            local walkable_nodes = 0

                            -- find space for lake (walkable rectangle)
                            for li = 1, length do
                                for wi = 1, width do
                                    local ai_rec = (ai + li) + (area.zstride * wi)
                                    local n_name = minetest.get_name_from_content_id(data[ai_rec])
                                    local n_def = minetest.registered_nodes[n_name]
                                    local b_data = minetest.get_biome_data(area:position(ai_rec))

                                    if not b_data then
                                        return
                                    end

                                    local b_name = minetest.get_biome_name(b_data.biome)

                                    if not b_name then
                                        return
                                    end

                                    if b_name ~= 'everness:mineral_waters'
                                        -- for mese trees, they dont have specific biome
                                        or minetest.get_item_group(n_name, 'tree') > 0
                                        or minetest.get_item_group(n_name, 'leaves') > 0
                                    then
                                        -- bordering with anohter biome, be more precise in placing
                                        precision_perc = 100
                                    end

                                    if n_def
                                        and n_def.walkable
                                        and data[ai_rec + area.ystride] == minetest.CONTENT_AIR
                                    then
                                        walkable_nodes = walkable_nodes + 1
                                    end
                                end
                            end

                            -- build pool (cuboid)
                            local pool_build_nodes_group = pool_build_nodes[rand:next(1, #pool_build_nodes)]

                            if walkable_nodes >= (width * length / 100) * precision_perc then
                                -- offset y so the pools are sticking out / sinking in from the ground vertically
                                local ai_offset_y = ai - (area.ystride * height) + (area.ystride * rand:next(0, math.ceil(height / 2)))

                                for hi = 1, height do
                                    for li = 1, length do
                                        for wi = 1, width do
                                            local mineral_stone = pool_build_nodes_group[rand:next(1, #pool_build_nodes_group)]
                                            local ai_cub = (ai_offset_y + li) + (area.ystride * hi) + (area.zstride * wi)
                                            local current_c_id = data[ai_cub]

                                            -- Check for water and build nodes before replacing, this will make pools connected and will not replace already built walls from another pool near by
                                            if hi == 1
                                                and current_c_id ~= c_everness_mineral_water_source
                                                and not find_irecursive(pool_build_nodes, current_c_id)
                                            then
                                                -- build pool floor
                                                data[ai_cub] = mineral_stone
                                            elseif hi ~= 1
                                                and (wi == 1 or wi == width)
                                                and current_c_id ~= c_everness_mineral_water_source
                                                and not find_irecursive(pool_build_nodes, current_c_id)
                                            then
                                                -- build pool wall
                                                data[ai_cub] = mineral_stone
                                            elseif hi ~= 1
                                                and (li == 1 or li == length)
                                                and (wi ~= 1 or wi ~= width)
                                                and current_c_id ~= c_everness_mineral_water_source
                                                and not find_irecursive(pool_build_nodes, current_c_id)
                                            then
                                                -- build pool wall
                                                data[ai_cub] = mineral_stone
                                            else
                                                -- fill in the pool with water
                                                data[ai_cub] = c_everness_mineral_water_source
                                            end

                                            -- place loot chest in the middle of the pool floor
                                            if hi == 2
                                                and height > 4
                                                and math.ceil(length / 2) == li
                                                and math.ceil(width / 2) == wi
                                                and data[ai_cub - area.ystride] ~= c_everness_mineral_water_source
                                                and rand:next(0, 100) < 3
                                            then
                                                data[ai_cub] = c_everness_chest
                                                table.insert(chest_positions, vector.new(area:position(ai_cub)))
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        elseif rand_version == 2 then
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
                        local c_front = data[ai + (area.zstride * 2)]
                        -- back
                        local c_back = data[ai - (area.zstride * 2)]

                        local keep_going = true
                        local while_count = 1
                        local max_dig_depth = 11

                        if
                            c_current == c_everness_mineral_sand
                            and (
                                c_right == c_everness_mineral_sand
                                or c_right == c_everness_mineral_water_source
                                or c_right == c_everness_mineral_stone
                                or c_right == c_everness_mineral_stone_with_coal
                                or c_right == c_everness_mineral_stone_with_ceramic_sherds
                            )
                            and (
                                c_left == c_everness_mineral_sand
                                or c_left == c_everness_mineral_water_source
                                or c_left == c_everness_mineral_stone
                                or c_left == c_everness_mineral_stone_with_coal
                                or c_left == c_everness_mineral_stone_with_ceramic_sherds
                            )
                            and (
                                c_front == c_everness_mineral_sand
                                or c_front == c_everness_mineral_water_source
                                or c_front == c_everness_mineral_stone
                                or c_front == c_everness_mineral_stone_with_coal
                                or c_front == c_everness_mineral_stone_with_ceramic_sherds
                            )
                            and (
                                c_back == c_everness_mineral_sand
                                or c_back == c_everness_mineral_water_source
                                or c_back == c_everness_mineral_stone
                                or c_back == c_everness_mineral_stone_with_coal
                                or c_back == c_everness_mineral_stone_with_ceramic_sherds
                            )
                        then
                            -- dig below
                            while keep_going and while_count <= max_dig_depth do
                                local while_index = ai - area.ystride * while_count

                                if
                                    -- below
                                    (
                                        data[while_index] == c_everness_mineral_stone
                                        or data[while_index] == c_everness_mineral_stone_with_coal
                                        or data[while_index] == c_everness_mineral_stone_with_ceramic_sherds
                                    )
                                    and (
                                        -- right
                                        data[while_index + 1 + area.ystride] == c_everness_mineral_sand
                                        or data[while_index + 1 + area.ystride] == c_everness_mineral_water_source
                                        or data[while_index + 1 + area.ystride] == c_everness_mineral_stone
                                        or data[while_index + 1 + area.ystride] == c_everness_mineral_stone_with_coal
                                        or data[while_index + 1 + area.ystride] == c_everness_mineral_stone_with_ceramic_sherds
                                    )
                                    and (
                                        -- left
                                        data[while_index - 1 + area.ystride] == c_everness_mineral_sand
                                        or data[while_index - 1 + area.ystride] == c_everness_mineral_water_source
                                        or data[while_index - 1 + area.ystride] == c_everness_mineral_stone
                                        or data[while_index - 1 + area.ystride] == c_everness_mineral_stone_with_coal
                                        or data[while_index - 1 + area.ystride] == c_everness_mineral_stone_with_ceramic_sherds
                                    )
                                    and (
                                        -- front
                                        data[while_index + area.zstride + area.ystride] == c_everness_mineral_sand
                                        or data[while_index + area.zstride + area.ystride] == c_everness_mineral_water_source
                                        or data[while_index + area.zstride + area.ystride] == c_everness_mineral_stone
                                        or data[while_index + area.zstride + area.ystride] == c_everness_mineral_stone_with_coal
                                        or data[while_index + area.zstride + area.ystride] == c_everness_mineral_stone_with_ceramic_sherds
                                    )
                                    and (
                                        -- back
                                        data[while_index - area.zstride + area.ystride] == c_everness_mineral_sand
                                        or data[while_index - area.zstride + area.ystride] == c_everness_mineral_water_source
                                        or data[while_index - area.zstride + area.ystride] == c_everness_mineral_stone
                                        or data[while_index - area.zstride + area.ystride] == c_everness_mineral_stone_with_coal
                                        or data[while_index - area.zstride + area.ystride] == c_everness_mineral_stone_with_ceramic_sherds
                                    )
                                then
                                    data[while_index + area.ystride] = c_everness_mineral_water_source
                                else
                                    keep_going = false
                                end

                                while_count = while_count + 1
                            end
                        end
                    end
                end
            end
        end

        -- Place decorations after generating (2nd pass)
        -- luacheck: ignore 512
        for y = minp.y, maxp.y do
            for z = minp.z, maxp.z do
                for x = minp.x, maxp.x do
                    local ai = area:index(x, y, z)
                    --
                    -- Place Lotus Flowers and Leaves
                    --
                    if
                        data[ai] == c_everness_mineral_water_source
                        -- spawn around water
                        and data[ai + 1 + area.zstride] == c_everness_mineral_water_source
                        and data[ai + 1 - area.zstride] == c_everness_mineral_water_source
                        and data[ai + 1] == c_everness_mineral_water_source
                        and data[ai - 1] == c_everness_mineral_water_source
                        and data[ai - 1 + area.zstride] == c_everness_mineral_water_source
                        and data[ai - 1 - area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.zstride] == c_everness_mineral_water_source
                        and data[ai - area.zstride] == c_everness_mineral_water_source
                        -- make sure there is space above
                        and data[ai + area.ystride] == minetest.CONTENT_AIR
                        -- spawn around air above
                        and data[ai + area.ystride + 1] == minetest.CONTENT_AIR
                        and data[ai + area.ystride + 1 + area.zstride] == minetest.CONTENT_AIR
                        and data[ai + area.ystride + 1 - area.zstride] == minetest.CONTENT_AIR
                        and data[ai + area.ystride - 1] == minetest.CONTENT_AIR
                        and data[ai + area.ystride - 1 + area.zstride] == minetest.CONTENT_AIR
                        and data[ai + area.ystride - 1 - area.zstride] == minetest.CONTENT_AIR
                        and data[ai + area.ystride + area.zstride] == minetest.CONTENT_AIR
                        and data[ai + area.ystride - area.zstride] == minetest.CONTENT_AIR
                    then
                        if rand:next(0, 100) < 2 then
                            data[ai + area.ystride] = c_lotus_flowers[rand:next(1, #c_lotus_flowers)]

                            -- Place Lotus Leaves around Flowers
                            local radius = 3
                            local chance_max = 80

                            for i = -radius, radius do
                                for j = -radius, radius do
                                    local idx = ai + i + (area.zstride * j) + area.ystride
                                    local distance = math.round(vector.distance(area:position(ai), area:position(idx)))
                                    local chance_lotus_leaf = math.round(chance_max / distance)

                                    if chance_lotus_leaf > chance_max then
                                        chance_lotus_leaf = chance_max
                                    end

                                    if
                                        rand:next(0, 100) < chance_lotus_leaf
                                        and data[idx] == minetest.CONTENT_AIR
                                        and data[idx - area.ystride] == c_everness_mineral_water_source
                                    then
                                        data[idx] = c_lotus_leaves[rand:next(1, #c_lotus_leaves)]
                                        p2data[idx] = rand:next(0, 3)
                                    end
                                end
                            end
                        elseif rand:next(0, 100) < 4 then
                            data[ai + area.ystride] = c_lotus_leaves[rand:next(1, #c_lotus_leaves)]
                            p2data[ai + area.ystride] = rand:next(0, 3)

                            -- add some more leaves around the leaf
                            for i = -1, 1 do
                                for j = -1, 1 do
                                    local idx = ai + i + (area.zstride * j) + area.ystride

                                    if
                                        rand:next(0, 100) < 25
                                        and data[idx] == minetest.CONTENT_AIR
                                        and data[idx - area.ystride] == c_everness_mineral_water_source
                                    then
                                        data[idx] = c_lotus_leaves[rand:next(1, #c_lotus_leaves)]
                                        p2data[idx] = rand:next(0, 3)
                                    end
                                end
                            end
                        end
                    end

                    --
                    -- Place Seaweed
                    --
                    if
                        data[ai] == c_everness_mineral_water_source
                        and data[ai + area.ystride] == c_everness_mineral_water_source
                        and rand:next(0, 100) < 33
                    then
                        local c_weed = c_water_weeds[rand:next(1, #c_water_weeds)]

                        if rand:next(0, 100) < 5 then
                            -- Weed with light source with a bit less probability
                            c_weed = c_everness_mineral_water_weed_3
                        end

                        if data[ai + 1] == c_everness_mineral_stone then
                            data[ai + 1] = c_weed
                            data[ai + 1] = c_weed
                            data[ai + 1] = c_weed
                            p2data[ai + 1] = 2
                        elseif data[ai - 1] == c_everness_mineral_stone then
                            data[ai - 1] = c_weed
                            data[ai - 1] = c_weed
                            data[ai - 1] = c_weed
                            p2data[ai - 1] = 3
                        elseif data[ai + area.zstride] == c_everness_mineral_stone then
                            data[ai + area.zstride] = c_weed
                            data[ai + area.zstride] = c_weed
                            data[ai + area.zstride] = c_weed
                            p2data[ai + area.zstride] = 4
                        elseif data[ai - area.zstride] == c_everness_mineral_stone then
                            data[ai - area.zstride] = c_weed
                            data[ai - area.zstride] = c_weed
                            data[ai - area.zstride] = c_weed
                            p2data[ai - area.zstride] = 5
                        elseif data[ai - area.ystride] == c_everness_mineral_stone then
                            data[ai - area.ystride] = c_weed
                            data[ai - area.ystride] = c_weed
                            data[ai - area.ystride] = c_weed
                            p2data[ai - area.ystride] = 1
                        end
                    end

                    --
                    -- Place pots under water
                    --
                    if
                        data[ai] == c_everness_mineral_water_source
                        -- spawn around water
                        and data[ai + 1 + area.zstride] == c_everness_mineral_water_source
                        and data[ai + 1 - area.zstride] == c_everness_mineral_water_source
                        and data[ai + 1] == c_everness_mineral_water_source
                        and data[ai - 1] == c_everness_mineral_water_source
                        and data[ai - 1 + area.zstride] == c_everness_mineral_water_source
                        and data[ai - 1 - area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.zstride] == c_everness_mineral_water_source
                        and data[ai - area.zstride] == c_everness_mineral_water_source
                        -- spawn around water above
                        and data[ai + area.ystride] == c_everness_mineral_water_source
                        and data[ai + area.ystride + 1] == c_everness_mineral_water_source
                        and data[ai + area.ystride + 1 + area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.ystride + 1 - area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.ystride - 1] == c_everness_mineral_water_source
                        and data[ai + area.ystride - 1 + area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.ystride - 1 - area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.ystride + area.zstride] == c_everness_mineral_water_source
                        and data[ai + area.ystride - area.zstride] == c_everness_mineral_water_source
                        -- spawn on solid node below
                        and data[ai - area.ystride] ~= c_everness_mineral_water_source
                    then
                        if rand:next(0, 100) < 1 then
                            table.insert(pot_pos, vector.new(area:position(ai)))
                        end
                    end
                end
            end
        end

        -- Set `shared_args`
        shared_args.chest_positions = chest_positions
        shared_args.pot_pos = pot_pos
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
                    data[vi] == c_everness_mineral_water_source
                    or data[vi] == c_everness_mineral_sand
                )
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Mineral Waters Tower
                --

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:mineral_sand',
                        'everness:mineral_water_source'
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
                        s_pos,
                        schem,
                        'random',
                        nil,
                        true,
                        'place_center_x, place_center_z'
                    )

                    shared_args.schem_positions.everness_mineral_waters_tower = shared_args.schem_positions.everness_mineral_waters_tower or {}

                    table.insert(shared_args.schem_positions.everness_mineral_waters_tower, {
                        pos = s_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Mineral Waters Tower was placed at ' .. s_pos:to_string())
                end
            end
        end

        --
        -- Place Decorations
        --
        local pot_pos = shared_args.pot_pos or {}

        --
        -- Palm Trees
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_palm_trees or '')] or {}) do
            place_decoration(pos, vm, area, data, 'everness:palm_trees', function(p)
                minetest.place_schematic_on_vmanip(
                    vm,
                    p,
                    minetest.get_modpath('everness') .. '/schematics/everness_palm_tree.mts',
                    nil,
                    nil,
                    true,
                    'place_center_x, place_center_z'
                )
            end)
        end

        --
        -- Water Geyser
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_water_geyser or '')] or {}) do
            place_decoration(pos, vm, area, data, 'everness:water_geyser', function(p)
                vm:set_node_at(p, { name = 'everness:water_geyser' })
            end)
        end

        --
        -- Rose Bush
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_rose_bush or '')] or {}) do
            place_decoration(pos, vm, area, data, 'everness:rose_bush', function(p)
                vm:set_node_at(p, { name = 'everness:rose_bush' })
            end)
        end

        --
        -- Pots (above water)
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_pots or '')] or {}) do
            place_decoration(pos, vm, area, data, 'everness:pots', function(p, deco_def)
                if deco_def._decoration then
                    -- Use `minetest.set_node` so we can set inventory on node construct
                    minetest.set_node(p, { name = deco_def._decoration[rand:next(1, #deco_def._decoration)] })

                    -- local inv = minetest.get_inventory({ type = 'node', pos = p })
                    -- local item_def = Everness.loot_chest.default[rand:next(1, #Everness.loot_chest.default)]

                    -- if not minetest.registered_items[item_def.name] then
                    --     return
                    -- end

                    -- if rand:next(0, 100) <= item_def.chance then
                    --     local stack = ItemStack(item_def.name)

                    --     if minetest.registered_tools[item_def.name] then
                    --         stack:set_wear(rand:next(1, 65535))
                    --     else
                    --         stack:set_count(rand:next(1, math.min(item_def.max_count, stack:get_stack_max())))
                    --     end

                    --     inv:set_stack('main', 1, stack)
                    -- end
                end
            end)
        end

        --
        -- Pots (under water)
        --
        for _, v in ipairs(pot_pos) do
            -- Use `minetest.set_node` so we can set inventory on node construct
            minetest.set_node(v, { name = minetest.get_name_from_content_id(c_pots[rand:next(1, #c_pots)]) })

            -- local inv = minetest.get_inventory({ type = 'node', pos = v })
            -- local item_def = Everness.loot_chest.default[rand:next(1, #Everness.loot_chest.default)]

            -- if not minetest.registered_items[item_def.name] then
            --     return
            -- end

            -- if rand:next(0, 100) <= item_def.chance then
            --     local stack = ItemStack(item_def.name)

            --     if minetest.registered_tools[item_def.name] then
            --         stack:set_wear(rand:next(1, 65535))
            --     else
            --         stack:set_count(rand:next(1, math.min(item_def.max_count, stack:get_stack_max())))
            --     end

            --     inv:set_stack('main', 1, stack)
            -- end
        end
    end,
    after_write_to_map = function(shared_args)
        -- Populate loot chest inventory
        local chest_positions = shared_args.chest_positions or {}

        if next(chest_positions) then
            Everness:populate_loot_chests(chest_positions)
        end

        -- Populate loot chest inventory for schematics
        local schem_positions = shared_args.schem_positions or {}

        for name, tbl in pairs(schem_positions) do
            if next(tbl) then
                for i, v in ipairs(tbl) do
                    local chest_positions2 = minetest.find_nodes_in_area(
                        v.minp,
                        v.maxp,
                        { 'everness:chest' }
                    )

                    if #chest_positions2 > 0 then
                        Everness:populate_loot_chests(chest_positions2)
                    end
                end
            end
        end
    end
})
