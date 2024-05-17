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

local y_max = Everness.settings.biomes.everness_bamboo_forest.y_max
local y_min = Everness.settings.biomes.everness_bamboo_forest.y_min

-- Bamboo Forest

Everness:register_biome({
    name = 'everness:bamboo_forest',
    node_top = 'everness:dirt_with_grass_1',
    depth_top = 1,
    node_filler = 'everness:dirt_1',
    depth_filler = 1,
    node_riverbed = 'default:sand',
    depth_riverbed = 2,
    node_dungeon = 'everness:bamboo_wood',
    node_dungeon_alt = 'everness:bamboo_mosaic_wood',
    node_dungeon_stair = 'stairs:stair_bamboo_wood',
    y_max = y_max,
    y_min = y_min,
    heat_point = 80,
    humidity_point = 60,
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:bamboo_forest_small_bamboo',
    deco_type = 'schematic',
    place_on = { 'everness:dirt_with_grass_1' },
    sidelen = 80,
    fill_ratio = 0.1,
    biomes = { 'everness:bamboo_forest' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_small_bamboo.mts',
    flags = 'place_center_x, place_center_z, force_placement',
    rotation = 'random',
})

Everness:register_decoration({
    name = 'everness:bamboo_forest_large_bamboo',
    deco_type = 'schematic',
    place_on = { 'everness:dirt_with_grass_1' },
    sidelen = 80,
    fill_ratio = 0.1,
    biomes = { 'everness:bamboo_forest' },
    y_max = y_max,
    y_min = y_min,
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_large_bamboo.mts',
    flags = 'place_center_x, place_center_z, force_placement',
    rotation = 'random',
})

-- Jungle tree and log

local jungle_tree_schem
local jungle_log_schem

if minetest.get_modpath('default') then
    jungle_tree_schem = minetest.get_modpath('default') .. '/schematics/jungle_tree.mts'
    jungle_log_schem = minetest.get_modpath('default') .. '/schematics/jungle_log.mts'
elseif minetest.get_modpath('mcl_core') then
    jungle_tree_schem = minetest.get_modpath('mcl_core') .. '/schematics/mcl_core_jungle_tree.mts'
    jungle_log_schem = {
        size = { x = 3, y = 3, z = 1 },
        data = {
            { name = 'air', prob = 0 },
            { name = 'air', prob = 0 },
            { name = 'air', prob = 0 },
            { name = 'mcl_core:jungletree', param2 = 12 },
            { name = 'mcl_core:jungletree', param2 = 12 },
            { name = 'mcl_core:jungletree', param2 = 12, prob = 127 },
            { name = 'air', prob = 0 },
            { name = 'mcl_mushrooms:mushroom_brown', prob = 50 },
            { name = 'air', prob = 0 },
        },
    }
end

if jungle_tree_schem then
    Everness:register_decoration({
        name = 'everness:bamboo_forest_jungle_tree',
        deco_type = 'schematic',
        place_on = { 'everness:dirt_with_grass_1' },
        sidelen = 16,
        noise_params = {
            offset = 0.0015,
            scale = 0.0021,
            spread = { x = 250, y = 250, z = 250 },
            seed = 2,
            octaves = 3,
            persist = 0.66
        },
        biomes = { 'everness:bamboo_forest' },
        y_max = y_max,
        y_min = y_min,
        schematic = jungle_tree_schem,
        flags = 'place_center_x, place_center_z',
        rotation = 'random',
    })
end

if jungle_log_schem then
    Everness:register_decoration({
        name = 'everness:bamboo_forest_jungle_log',
        deco_type = 'schematic',
        place_on = { 'everness:dirt_with_grass_1' },
        place_offset_y = 1,
        sidelen = 16,
        noise_params = {
            offset = 0.0015,
            scale = 0.0021,
            spread = { x = 250, y = 250, z = 250 },
            seed = 2,
            octaves = 3,
            persist = 0.66
        },
        biomes = { 'everness:bamboo_forest' },
        y_max = y_max,
        y_min = y_min,
        schematic = jungle_log_schem,
        flags = 'place_center_x',
        rotation = 'random',
        spawn_by = 'everness:dirt_with_grass_1',
        num_spawn_by = 8,
    })
end

-- Bush

if minetest.get_modpath('default') then
    Everness:register_decoration({
        name = 'everness:bamboo_forest_bush',
        deco_type = 'schematic',
        place_on = { 'everness:dirt_with_grass_1' },
        sidelen = 16,
        noise_params = {
            offset = -0.004,
            scale = 0.01,
            spread = { x = 100, y = 100, z = 100 },
            seed = 137,
            octaves = 3,
            persist = 0.7,
        },
        biomes = { 'everness:bamboo_forest' },
        y_max = y_max,
        y_min = y_min,
        schematic = minetest.get_modpath('default') .. '/schematics/bush.mts',
        flags = 'place_center_x, place_center_z',
    })

    -- Blueberry bush

    Everness:register_decoration({
        name = 'everness:bamboo_forest_blueberry_bush',
        deco_type = 'schematic',
        place_on = { 'everness:dirt_with_grass_1' },
        sidelen = 16,
        noise_params = {
            offset = -0.004,
            scale = 0.01,
            spread = { x = 100, y = 100, z = 100 },
            seed = 697,
            octaves = 3,
            persist = 0.7,
        },
        biomes = { 'everness:bamboo_forest' },
        y_max = y_max,
        y_min = y_min,
        place_offset_y = 1,
        schematic = minetest.get_modpath('default') .. '/schematics/blueberry_bush.mts',
        flags = 'place_center_x, place_center_z',
    })
end

-- Flowers
local function register_flower_decoration(offset, scale, length)
    Everness:register_decoration({
        name = 'everness:bamboo_forest_flowers_' .. length,
        deco_type = 'simple',
        place_on = { 'everness:dirt_with_grass_1' },
        sidelen = 16,
        noise_params = {
            offset = offset,
            scale = scale,
            spread = { x = 200, y = 200, z = 200 },
            seed = 329,
            octaves = 3,
            persist = 0.6
        },
        biomes = { 'everness:bamboo_forest' },
        y_max = y_max,
        y_min = y_min,
        decoration = 'everness:flowers_' .. length,
    })
end

register_flower_decoration(-0.03, 0.09, 4)
register_flower_decoration(-0.015, 0.075, 3)
register_flower_decoration(0, 0.06, 2)
register_flower_decoration(0.015, 0.045, 1)

local function register_flower_magenta_decoration(offset, scale, length)
    Everness:register_decoration({
        name = 'everness:bamboo_forest_flowers_magenta' .. length,
        deco_type = 'simple',
        place_on = { 'everness:dirt_with_grass_1' },
        sidelen = 16,
        noise_params = {
            offset = offset,
            scale = scale,
            spread = { x = 200, y = 200, z = 200 },
            seed = 329,
            octaves = 3,
            persist = 0.6
        },
        biomes = { 'everness:bamboo_forest' },
        y_max = y_max,
        y_min = y_min,
        decoration = 'everness:flowers_magenta_' .. length,
    })
end

register_flower_magenta_decoration(-0.03, 0.09, 4)
register_flower_magenta_decoration(-0.015, 0.075, 3)
register_flower_magenta_decoration(0, 0.06, 2)
register_flower_magenta_decoration(0.015, 0.045, 1)

--
-- On Generated
--

local disp = 16
local chance = 20
local schem = minetest.get_modpath('everness') .. '/schematics/everness_japanese_shrine.mts'

local c_everness_bamboo_1 = minetest.get_content_id('everness:bamboo_1')
local c_everness_bamboo_3 = minetest.get_content_id('everness:bamboo_3')
local c_everness_bamboo_4 = minetest.get_content_id('everness:bamboo_4')
local c_everness_bamboo_5 = minetest.get_content_id('everness:bamboo_5')
local c_dirt_with_grass_1 = minetest.get_content_id('everness:dirt_with_grass_1')
local c_dirt_with_grass_extras_1 = minetest.get_content_id('everness:dirt_with_grass_extras_1')
local c_dirt_with_grass_extras_2 = minetest.get_content_id('everness:dirt_with_grass_extras_2')

local biome_id_bamboo_forest = minetest.get_biome_id('everness:bamboo_forest')

local d_everness_bamboo_forest_large_bamboo = minetest.get_decoration_id('everness:bamboo_forest_large_bamboo')

minetest.set_gen_notify({ decoration = true }, { d_everness_bamboo_forest_large_bamboo })

Everness:add_to_queue_on_generated({
    name = 'everness:bamboo_forest',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_bamboo_forest) ~= -1
    end,
    on_data = function(minp, maxp, area, data, p2data, gennotify, rand, shared_args)
        --
        -- Bamboo
        --
        for _, pos in ipairs(gennotify['decoration#' .. (d_everness_bamboo_forest_large_bamboo or '')] or {}) do
            -- For bamboo large this is position of the 'place_on' node, e.g. 'everness:dirt_with_grass_extras_2'
            local vi = area:indexp(pos)
            local while_counter = 1
            local bamboo_height = 0
            local last_vi = vi + area.ystride * while_counter

            -- Get bamboo height
            while data[last_vi] == c_everness_bamboo_3 do
                last_vi = vi + area.ystride * while_counter
                bamboo_height = bamboo_height + 1
                while_counter = while_counter + 1
            end

            -- Back up the last from `while_counter`
            last_vi = last_vi - area.ystride

            -- Add top bamboo nodes with leaves based on their generated height
            if bamboo_height > 4 then
                for i = 1, 3 do
                    if data[last_vi + area.ystride * i] == minetest.CONTENT_AIR then
                        if i == 1 then
                            data[last_vi + area.ystride * i] = c_everness_bamboo_4
                        else
                            data[last_vi + area.ystride * i] = c_everness_bamboo_5
                        end

                        p2data[last_vi + area.ystride * i] = p2data[vi + area.ystride]
                    end
                end
            else
                for i = 1, 2 do
                    if data[last_vi + area.ystride * i] == minetest.CONTENT_AIR then
                        if i == 1 then
                            data[last_vi + area.ystride * i] = c_everness_bamboo_4
                        else
                            data[last_vi + area.ystride * i] = c_everness_bamboo_5
                        end

                        p2data[last_vi + area.ystride * i] = p2data[vi + area.ystride]
                    end
                end
            end
        end
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if
                (
                    data[vi + area.ystride] == minetest.CONTENT_AIR
                    or data[vi + area.ystride] == c_everness_bamboo_1
                    or data[vi + area.ystride] == c_everness_bamboo_3
                )
                and (
                    data[vi] == c_dirt_with_grass_1
                    or data[vi] == c_dirt_with_grass_extras_1
                    or data[vi] == c_dirt_with_grass_extras_2
                )
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Japanese Shrine
                --

                local size = { x = 11, y = 19, z = 15 }
                local size_x = math.round(size.x / 2)
                local size_z = math.round(size.z / 2)
                local schem_pos = vector.new(s_pos)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:dirt_with_grass_1'
                    }
                )
                -- Can force over these blocks
                local force_positions = minetest.find_nodes_in_area(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:dirt_with_grass_extras_1',
                        'everness:dirt_with_grass_extras_2',
                        'group:bamboo',
                        'group:flower',
                        'group:leaves'
                    }
                )

                if #positions + #force_positions < size.x * size.z then
                    -- not enough space
                    return
                end

                -- enough air to place structure ?
                local air_positions = minetest.find_nodes_in_area(
                    vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z),
                    {
                        'air',
                        'group:bamboo',
                        'group:flower',
                        'group:leaves'
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

                    shared_args.schem_positions.everness_japanese_shrine = shared_args.schem_positions.everness_japanese_shrine or {}

                    table.insert(shared_args.schem_positions.everness_japanese_shrine, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Japanese Shrine was placed at ' .. schem_pos:to_string())
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
