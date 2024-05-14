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

local y_max = Everness.settings.biomes.everness_frosted_icesheet.y_max
local y_min = Everness.settings.biomes.everness_frosted_icesheet.y_min

-- Frosted Icesheet

Everness:register_biome({
    name = 'everness:frosted_icesheet',
    node_dust = 'everness:frosted_snowblock',
    node_top = 'everness:frosted_snowblock',
    depth_top = 1,
    node_filler = 'everness:frosted_snowblock',
    depth_filler = 3,
    node_stone = 'everness:frosted_cave_ice',
    node_water_top = 'everness:frosted_ice',
    depth_water_top = 2,
    node_river_water = 'everness:frosted_ice',
    node_riverbed = 'everness:gravel',
    depth_riverbed = 2,
    node_dungeon = 'everness:icecobble',
    node_dungeon_alt = 'everness:snowcobble',
    node_dungeon_stair = 'stairs:stair_ice',
    y_max = y_max,
    y_min = y_min,
    heat_point = 0,
    humidity_point = 93,
})

--
-- Register decorations
--

-- Frosted Icesheet

Everness:register_decoration({
    name = 'everness:frosted_icesheet_stalagmite',
    deco_type = 'schematic',
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_frosted_lands_stalagmite.mts',
    place_on = { 'everness:frosted_snowblock' },
    place_offset_y = 1,
    sidelen = 16,
    noise_params = {
        offset = 0.0008,
        scale = 0.0007,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:frosted_icesheet' },
    y_max = y_max,
    y_min = (y_max - y_max) + 4,
    flags = 'place_center_x, place_center_z',
    spawn_by = 'everness:frosted_snowblock',
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:frosted_icesheet_volcanic_rock',
    deco_type = 'schematic',
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_frosted_lands_volcanic_rock.mts',
    place_on = { 'everness:frosted_snowblock' },
    sidelen = 16,
    noise_params = {
        offset = 0.0008,
        scale = 0.0007,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:frosted_icesheet' },
    y_max = y_max,
    y_min = (y_max - y_max) + 2,
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
    spawn_by = 'everness:frosted_snowblock',
    num_spawn_by = 8,
})

Everness:register_decoration({
    name = 'everness:frosted_icesheet_fossils',
    deco_type = 'schematic',
    schematic = minetest.get_modpath('everness') .. '/schematics/everness_frosted_lands_fossils.mts',
    place_on = { 'everness:frosted_snowblock' },
    sidelen = 16,
    place_offset_y = 1,
    noise_params = {
        offset = 0.0008,
        scale = 0.0007,
        spread = { x = 250, y = 250, z = 250 },
        seed = 2,
        octaves = 3,
        persist = 0.66
    },
    biomes = { 'everness:frosted_icesheet' },
    y_max = y_max,
    y_min = (y_max - y_max) + 1,
    flags = 'place_center_x, place_center_z',
    rotation = 'random',
    spawn_by = 'everness:frosted_snowblock',
    num_spawn_by = 8,
})

--
-- On Generated
--

local chance = 20
local disp = 16
local schem = minetest.read_schematic(minetest.get_modpath('everness') .. '/schematics/everness_frosted_icesheet_igloo.mts', {})
local size = { x = 16, y = 13, z = 16 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local y_dis = 8

local c_frosted_snowblock = minetest.get_content_id('everness:frosted_snowblock')
local c_frosted_ice = minetest.get_content_id('everness:frosted_ice')

local biome_id_everness_frosted_icesheet = minetest.get_biome_id('everness:frosted_icesheet')

Everness:add_to_queue_on_generated({
    name = 'everness:frosted_icesheet',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_frosted_icesheet) ~= -1
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
                    data[vi] == c_frosted_snowblock
                    or data[vi] == c_frosted_ice
                )
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Igloo
                --

                -- add Y displacement
                local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis, s_pos.z)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:frosted_snowblock',
                        'everness:frosted_ice'
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

                    shared_args.schem_positions.everness_frosted_icesheet_igloo = shared_args.schem_positions.everness_frosted_icesheet_igloo or {}

                    table.insert(shared_args.schem_positions.everness_frosted_icesheet_igloo, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y - y_dis, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y - y_dis + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Igloo was placed at ' .. schem_pos:to_string())
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
