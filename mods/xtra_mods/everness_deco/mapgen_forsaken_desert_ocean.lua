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

local y_max = Everness.settings.biomes.everness_forsaken_desert_ocean.y_max
local y_min = Everness.settings.biomes.everness_forsaken_desert_ocean.y_min

-- Forsaken Desert Ocean

Everness:register_biome({
    name = 'everness:forsaken_desert_ocean',
    node_top = 'everness:dry_ocean_dirt',
    depth_top = 1,
    node_stone = 'everness:forsaken_desert_stone',
    node_filler = 'everness:dry_ocean_dirt',
    depth_filler = 3,
    node_water_top = 'everness:dry_ocean_dirt',
    depth_water_top = 10,
    node_river_water = 'everness:dry_ocean_dirt',
    node_riverbed = 'everness:dry_ocean_dirt',
    depth_riverbed = 2,
    node_dungeon = 'everness:forsaken_desert_brick',
    node_dungeon_alt = 'everness:forsaken_desert_brick_red',
    node_dungeon_stair = 'stairs:stair_forsaken_desert_brick',
    y_max = y_max,
    y_min = y_min,
    heat_point = 100,
    humidity_point = 30,
})

--
-- On Generated
--

local chance = 20
local disp = 16
local schem = minetest.get_modpath('everness') .. '/schematics/everness_forsaken_desert_temple_3.mts'
local size = { x = 11, y = 13, z = 13 }
local size_x = math.round(size.x / 2)
local size_z = math.round(size.z / 2)
local y_dis = -1

local c_dry_ocean_dirt = minetest.get_content_id('everness:dry_ocean_dirt')

local biome_id_everness_forsaken_desert_ocean = minetest.get_biome_id('everness:forsaken_desert_ocean')

Everness:add_to_queue_on_generated({
    name = 'everness:forsaken_desert_ocean',
    can_run = function(biomemap)
        return table.indexof(biomemap, biome_id_everness_forsaken_desert_ocean) ~= -1
    end,
    after_set_data = function(minp, maxp, vm, area, data, p2data, gennotify, rand, shared_args)
        local sidelength = maxp.x - minp.x + 1
        local x_disp = rand:next(0, disp)
        local z_disp = rand:next(0, disp)
        shared_args.schem_positions = {}

        for y = minp.y, maxp.y do
            local vi = area:index(minp.x + sidelength / 2 + x_disp, y, minp.z + sidelength / 2 + z_disp)

            if data[vi + area.ystride] == minetest.CONTENT_AIR
                and data[vi] == c_dry_ocean_dirt
                and rand:next(0, 100) < chance
            then
                local s_pos = area:position(vi)

                --
                -- Forsaken Desert Temple 3
                --

                local schem_pos = vector.new(s_pos.x, s_pos.y - y_dis, s_pos.z)

                -- find floor big enough
                local positions = minetest.find_nodes_in_area_under_air(
                    vector.new(s_pos.x - size_x, s_pos.y - 1, s_pos.z - size_z),
                    vector.new(s_pos.x + size_x, s_pos.y + 1, s_pos.z + size_z),
                    {
                        'everness:dry_ocean_dirt'
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

                    shared_args.schem_positions.everness_forsaken_desert_temple_3 = shared_args.schem_positions.everness_forsaken_desert_temple_3 or {}

                    table.insert(shared_args.schem_positions.everness_forsaken_desert_temple_3, {
                        pos = schem_pos,
                        minp = vector.new(s_pos.x - size_x, s_pos.y - y_dis, s_pos.z - size_z),
                        maxp = vector.new(s_pos.x + size_x, s_pos.y - y_dis + size.y, s_pos.z + size_z)
                    })

                    minetest.log('action', '[Everness] Forsaken Desert Temple 3 was placed at ' .. schem_pos:to_string())
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
