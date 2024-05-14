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

local y_max = Everness.settings.biomes.everness_forsaken_desert_under.y_max
local y_min = Everness.settings.biomes.everness_forsaken_desert_under.y_min

-- Forsaken Desert Under

Everness:register_biome({
    name = 'everness:forsaken_desert_under',
    node_cave_liquid = { 'mapgen_water_source', 'mapgen_lava_source' },
    node_dungeon = 'default:cobble',
    node_dungeon_alt = 'default:mossycobble',
    node_dungeon_stair = 'stairs:stair_cobble',
    y_max = y_max,
    y_min = y_min,
    heat_point = 100,
    humidity_point = 30,
})

--
-- Register decorations
--

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_floors',
    deco_type = 'simple',
    place_on = { 'default:stone' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 10,
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_floors, force_placement',
    decoration = {
        'everness:forsaken_desert_sand'
    },
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_floors_chiseled',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    place_offset_y = -1,
    fill_ratio = 0.2,
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = {
        'everness:forsaken_desert_chiseled_stone',
        'everness:forsaken_desert_brick',
        'everness:forsaken_desert_brick_red',
        'everness:forsaken_desert_engraved_stone',
        'everness:forsaken_desert_cobble_red',
        'everness:forsaken_desert_cobble',
    },
    flags = 'all_floors, force_placement'
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_ceilings',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    fill_ratio = 0.4,
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    decoration = {
        'everness:moss_block'
    },
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_cactus_blue',
    deco_type = 'simple',
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
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max - 500 > y_min and y_max - 500 or y_max,
    y_min = y_min,
    decoration = 'everness:cactus_blue',
    height = 2,
    height_max = 6,
    flags = 'all_floors'
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_cave_barrel_cactus',
    deco_type = 'simple',
    place_on = {
        'everness:forsaken_desert_sand',
        'everness:forsaken_desert_chiseled_stone',
        'everness:forsaken_desert_brick',
        'everness:forsaken_desert_engraved_stone'
    },
    sidelen = 16,
    fill_ratio = 0.005,
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max - 250 > y_min and y_max - 250 or y_max,
    y_min = y_min,
    decoration = {
        'everness:cave_barrel_cactus',
        'everness:venus_trap'
    },
    flags = 'all_floors',
    param2_max = 3
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_cave_illumi_root',
    deco_type = 'simple',
    place_on = {
        'everness:forsaken_desert_sand',
        'everness:forsaken_desert_chiseled_stone',
        'everness:forsaken_desert_brick',
        'everness:forsaken_desert_engraved_stone'
    },
    sidelen = 16,
    fill_ratio = 0.005,
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = { 'everness:illumi_root' },
    flags = 'all_floors'
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_vines',
    deco_type = 'simple',
    place_on = { 'everness:moss_block' },
    sidelen = 16,
    fill_ratio = 0.09,
    biomes = { 'everness:forsaken_desert_under' },
    param2 = 8,
    decoration = {
        'everness:dense_vine_1',
        'everness:dense_vine_2'
    },
    y_max = y_max,
    y_min = y_min,
    flags = 'all_ceilings',
    spawn_by = 'air',
    num_spawn_by = 8
})

Everness:register_decoration({
    name = 'everness:forsaken_desert_under_hollow_tree',
    deco_type = 'simple',
    place_on = { 'everness:forsaken_desert_sand' },
    sidelen = 16,
    noise_params = {
        offset = 0,
        scale = 0.006,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:forsaken_desert_under' },
    y_max = y_max,
    y_min = y_min,
    decoration = 'everness:hollow_tree',
    height = 3,
    height_max = 7,
    flags = 'all_floors'
})

--
-- On Generated
--

local disp = 16
local chance = 20
local schem = minetest.get_modpath('everness') .. '/schematics/everness_forsaken_desert_temple_2.mts'
local size = { x = 16, y = 17, z = 15 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)

local c_forsaken_desert_sand = minetest.get_content_id('everness:forsaken_desert_sand')
local c_forsaken_desert_chiseled_stone = minetest.get_content_id('everness:forsaken_desert_chiseled_stone')
local c_forsaken_desert_brick = minetest.get_content_id('everness:forsaken_desert_brick')
local c_forsaken_desert_engraved_stone = minetest.get_content_id('everness:forsaken_desert_engraved_stone')

local biome_id_everness_forsaken_desert_under = minetest.get_biome_id('everness:forsaken_desert_under')

Everness:add_to_queue_on_generated({
    name = 'everness:forsaken_desert_under',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_forsaken_desert_under) ~= -1
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
                    data[vi] == c_forsaken_desert_sand
                    or data[vi] == c_forsaken_desert_chiseled_stone
                    or data[vi] == c_forsaken_desert_brick
                    or data[vi] == c_forsaken_desert_engraved_stone
                )
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Forsaken Desert Temple 2
                --

                local schem_pos = vector.new(s_pos.x, s_pos.y, s_pos.z)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:forsaken_desert_sand',
                        'everness:forsaken_desert_chiseled_stone',
                        'everness:forsaken_desert_brick',
                        'everness:forsaken_desert_engraved_stone',
                        'group:stone',
                        'group:sand',
                        'group:everness_sand',
                        'default:gravel',
                        'default:stone_with_coal',
                        'default:stone_with_iron',
                        'default:stone_with_tin',
                        'default:stone_with_gold',
                        'default:stone_with_mese',
                        'default:stone_with_diamond',
                        'everness:cave_barrel_cactus',
                        'everness:venus_trap',
                        'group:flora',
                        'everness:quartz_ore',
                        'everness:stone_with_pyrite',
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

                    shared_args.schem_positions.everness_forsaken_desert_temple_2 = shared_args.schem_positions.everness_forsaken_desert_temple_2 or {}

                    table.insert(shared_args.schem_positions.everness_forsaken_desert_temple_2, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Forsaken Desert Temple 2 was placed at ' .. schem_pos:to_string())
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
