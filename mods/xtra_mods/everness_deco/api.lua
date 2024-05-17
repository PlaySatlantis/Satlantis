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

local S = minetest.get_translator(minetest.get_current_modname())
local rand_global = PcgRandom(tonumber(tostring(os.time()):reverse():sub(1, 9)))

--- Base class
---@class Everness
Everness = {
    bamboo = {
        -- based on height
        growth_stages = {
            --height
            [1] = {
                -- next plant
                { name = 'everness:bamboo_1' },
                { name = 'everness:bamboo_2' },
            },
            [2] = {
                { name = 'everness:bamboo_1' },
                { name = 'everness:bamboo_2' },
                { name = 'everness:bamboo_2' },
            },
            [3] = {
                { name = 'everness:bamboo_3' },
                { name = 'everness:bamboo_4' },
                { name = 'everness:bamboo_4' },
                { name = 'everness:bamboo_5' },
            },
            [4] = {
                { name = 'everness:bamboo_3' },
                { name = 'everness:bamboo_3' },
                { name = 'everness:bamboo_4' },
                { name = 'everness:bamboo_5' },
                { name = 'everness:bamboo_5' },
            },
        },
        top_leaves_schem = {
            { name = 'everness:bamboo_4' },
            { name = 'everness:bamboo_5' },
            { name = 'everness:bamboo_5' },
        }
    },
    loot_chest = {
        default = {},
    },
    settings = {
        biomes = {
            everness_coral_forest = {
                enabled = minetest.settings:get_bool('everness_coral_forest', true),
                y_max = tonumber(minetest.settings:get('everness_coral_forest_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_coral_forest_y_min')) or 6,
            },
            everness_coral_forest_dunes = {
                enabled = minetest.settings:get_bool('everness_coral_forest_dunes', true),
                y_max = tonumber(minetest.settings:get('everness_coral_forest_dunes_y_max')) or 5,
                y_min = tonumber(minetest.settings:get('everness_coral_forest_dunes_y_min')) or 4,
            },
            everness_coral_forest_ocean = {
                enabled = minetest.settings:get_bool('everness_coral_forest_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_coral_forest_ocean_y_max')) or 3,
                y_min = tonumber(minetest.settings:get('everness_coral_forest_ocean_y_min')) or -10,
            },
            everness_coral_forest_deep_ocean = {
                enabled = minetest.settings:get_bool('everness_coral_forest_deep_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_coral_forest_deep_ocean_y_max')) or -11,
                y_min = tonumber(minetest.settings:get('everness_coral_forest_deep_ocean_y_min')) or -255,
            },
            everness_coral_forest_under = {
                enabled = minetest.settings:get_bool('everness_coral_forest_under', true),
                y_max = tonumber(minetest.settings:get('everness_coral_forest_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_coral_forest_under_y_min')) or -31000,
            },
            everness_frosted_icesheet = {
                enabled = minetest.settings:get_bool('everness_frosted_icesheet', true),
                y_max = tonumber(minetest.settings:get('everness_frosted_icesheet_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_frosted_icesheet_y_min')) or -8,
            },
            everness_frosted_icesheet_ocean = {
                enabled = minetest.settings:get_bool('everness_frosted_icesheet_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_frosted_icesheet_ocean_y_max')) or -9,
                y_min = tonumber(minetest.settings:get('everness_frosted_icesheet_ocean_y_min')) or -255,
            },
            everness_frosted_icesheet_under = {
                enabled = minetest.settings:get_bool('everness_frosted_icesheet_under', true),
                y_max = tonumber(minetest.settings:get('everness_frosted_icesheet_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_frosted_icesheet_under_y_min')) or -31000,
            },
            everness_cursed_lands = {
                enabled = minetest.settings:get_bool('everness_cursed_lands', true),
                y_max = tonumber(minetest.settings:get('everness_cursed_lands_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_cursed_lands_y_min')) or 6,
            },
            everness_cursed_lands_dunes = {
                enabled = minetest.settings:get_bool('everness_cursed_lands_dunes', true),
                y_max = tonumber(minetest.settings:get('everness_cursed_lands_dunes_y_max')) or 5,
                y_min = tonumber(minetest.settings:get('everness_cursed_lands_dunes_y_min')) or 1,
            },
            everness_cursed_lands_swamp = {
                enabled = minetest.settings:get_bool('everness_cursed_lands_swamp', true),
                y_max = tonumber(minetest.settings:get('everness_cursed_lands_swamp_y_max')) or 0,
                y_min = tonumber(minetest.settings:get('everness_cursed_lands_swamp_y_min')) or -1,
            },
            everness_cursed_lands_ocean = {
                enabled = minetest.settings:get_bool('everness_cursed_lands_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_cursed_lands_ocean_y_max')) or -2,
                y_min = tonumber(minetest.settings:get('everness_cursed_lands_ocean_y_min')) or -10,
            },
            everness_cursed_lands_deep_ocean = {
                enabled = minetest.settings:get_bool('everness_cursed_lands_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_cursed_lands_ocean_y_max')) or -11,
                y_min = tonumber(minetest.settings:get('everness_cursed_lands_ocean_y_min')) or -255,
            },
            everness_cursed_lands_under = {
                enabled = minetest.settings:get_bool('everness_cursed_lands_under', true),
                y_max = tonumber(minetest.settings:get('everness_cursed_lands_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_cursed_lands_under_y_min')) or -31000,
            },
            everness_crystal_forest = {
                enabled = minetest.settings:get_bool('everness_crystal_forest', true),
                y_max = tonumber(minetest.settings:get('everness_crystal_forest_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_crystal_forest_y_min')) or 6,
            },
            everness_crystal_forest_dunes = {
                enabled = minetest.settings:get_bool('everness_crystal_forest_dunes', true),
                y_max = tonumber(minetest.settings:get('everness_crystal_forest_dunes_y_max')) or 5,
                y_min = tonumber(minetest.settings:get('everness_crystal_forest_dunes_y_min')) or 1,
            },
            everness_crystal_forest_shore = {
                enabled = minetest.settings:get_bool('everness_crystal_forest_shore', true),
                y_max = tonumber(minetest.settings:get('everness_crystal_forest_shore_y_max')) or 0,
                y_min = tonumber(minetest.settings:get('everness_crystal_forest_shore_y_min')) or -1,
            },
            everness_crystal_forest_ocean = {
                enabled = minetest.settings:get_bool('everness_crystal_forest_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_crystal_forest_ocean_y_max')) or -2,
                y_min = tonumber(minetest.settings:get('everness_crystal_forest_ocean_y_min')) or -10,
            },
            everness_crystal_forest_deep_ocean = {
                enabled = minetest.settings:get_bool('everness_crystal_forest_deep_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_crystal_forest_deep_ocean_y_max')) or -11,
                y_min = tonumber(minetest.settings:get('everness_crystal_forest_deep_ocean_y_min')) or -255,
            },
            everness_crystal_forest_under = {
                enabled = minetest.settings:get_bool('everness_crystal_forest_under', true),
                y_max = tonumber(minetest.settings:get('everness_crystal_forest_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_crystal_forest_under_y_min')) or -31000,
            },
            everness_bamboo_forest = {
                enabled = minetest.settings:get_bool('everness_bamboo_forest', true),
                y_max = tonumber(minetest.settings:get('everness_bamboo_forest_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_bamboo_forest_y_min')) or 1,
            },
            everness_bamboo_forest_under = {
                enabled = minetest.settings:get_bool('everness_bamboo_forest_under', true),
                y_max = tonumber(minetest.settings:get('everness_bamboo_forest_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_bamboo_forest_under_y_min')) or -31000,
            },
            everness_forsaken_desert = {
                enabled = minetest.settings:get_bool('everness_forsaken_desert', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_desert_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_forsaken_desert_y_min')) or 4,
            },
            everness_forsaken_desert_ocean = {
                enabled = minetest.settings:get_bool('everness_forsaken_desert_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_desert_ocean_y_max')) or 3,
                y_min = tonumber(minetest.settings:get('everness_forsaken_desert_ocean_y_min')) or -8,
            },
            everness_forsaken_desert_under = {
                enabled = minetest.settings:get_bool('everness_forsaken_desert_under', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_desert_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_forsaken_desert_under_y_min')) or -31000,
            },
            everness_baobab_savanna = {
                enabled = minetest.settings:get_bool('everness_baobab_savanna', true),
                y_max = tonumber(minetest.settings:get('everness_baobab_savanna_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_baobab_savanna_y_min')) or 1,
            },
            everness_forsaken_tundra = {
                enabled = minetest.settings:get_bool('everness_forsaken_tundra', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_tundra_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_forsaken_tundra_y_min')) or 2,
            },
            everness_forsaken_tundra_beach = {
                enabled = minetest.settings:get_bool('everness_forsaken_tundra_beach', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_tundra_beach_y_max')) or 1,
                y_min = tonumber(minetest.settings:get('everness_forsaken_tundra_beach_y_min')) or -3,
            },
            everness_forsaken_tundra_ocean = {
                enabled = minetest.settings:get_bool('everness_forsaken_tundra_ocean', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_tundra_ocean_y_max')) or -4,
                y_min = tonumber(minetest.settings:get('everness_forsaken_tundra_ocean_y_min')) or -255,
            },
            everness_forsaken_tundra_under = {
                enabled = minetest.settings:get_bool('everness_forsaken_tundra_under', true),
                y_max = tonumber(minetest.settings:get('everness_forsaken_tundra_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_forsaken_tundra_under_y_min')) or -31000,
            },
            everness_mineral_waters = {
                enabled = minetest.settings:get_bool('everness_mineral_waters', true),
                y_max = tonumber(minetest.settings:get('everness_mineral_waters_y_max')) or 31000,
                y_min = tonumber(minetest.settings:get('everness_mineral_waters_y_min')) or 1,
            },
            everness_mineral_waters_under = {
                enabled = minetest.settings:get_bool('everness_mineral_waters_under', true),
                y_max = tonumber(minetest.settings:get('everness_mineral_waters_under_y_max')) or -256,
                y_min = tonumber(minetest.settings:get('everness_mineral_waters_under_y_min')) or -31000,
            },
        },
        features = {
            everness_feature_sneak_pickup = minetest.settings:get_bool('everness_feature_sneak_pickup', true),
            everness_feature_skybox = minetest.settings:get_bool('everness_feature_skybox', true),
        }
    },
    hammer_cid_data = {},
    colors = {
        brown = '#DEB887',
    },
    registered_nodes = {},
    registered_tools = {},
    registered_abms = {},
    registered_lbms = {},
    registered_craftitems = {},
    registered_biomes = {},
    registered_decorations = {},
    registered_ores = {},
    on_generated_queue = {}
}

function Everness.grow_cactus(self, pos, node, params)
    local node_copy = table.copy(node)

    if node.param2 >= 4 then
        return
    end

    pos.y = pos.y - 1

    if minetest.get_item_group(minetest.get_node(pos).name, 'sand') == 0
        and minetest.get_item_group(minetest.get_node(pos).name, 'everness_sand') == 0
    then
        return
    end

    pos.y = pos.y + 1

    local height = 0

    while (node.name == 'everness:cactus_orange' or node.name == 'everness:cactus_blue') and height < 5 do
        height = height + 1
        pos.y = pos.y + 1
        node = minetest.get_node(pos)
    end

    if height == 5 or node.name ~= 'air' then
        return
    end

    if minetest.get_node_light(pos) < 13 then
        return
    end

    minetest.set_node(pos, { name = node_copy.name })

    return true
end

function Everness.emerge_area(self, blockpos, action, calls_remaining, param)
    if not param.total then
        param.total = calls_remaining + 1
        param.current = 0
    end

    param.current = param.current + 1

    if param.total == param.current then
        param.callback(param.data)
    end
end

-- how often node timers for plants will tick, +/- some random value
function Everness.tick_vine(self, pos)
    minetest.get_node_timer(pos):start(math.random(5, 10))
end

-- how often a growth failure tick is retried (e.g. too dark)
function Everness.tick_vine_again(self, pos)
    minetest.get_node_timer(pos):start(math.random(40, 80))
end

-- how often node timers for plants will tick, +/- some random value
function Everness.tick_sulfur_stone(self, pos)
    minetest.get_node_timer(pos):start(math.random(5, 10))
end

-- how often a growth failure tick is retried (e.g. too dark)
function Everness.tick_sulfur_stone_again(self, pos)
    minetest.get_node_timer(pos):start(math.random(40, 80))
end

-- Grows vines
-- @param pos {vector}
function Everness.grow_vine(self, pos, elapsed, params)
    local node = minetest.get_node(pos)
    local pos_under = vector.new(pos.x, pos.y - 1, pos.z)
    local node_under = minetest.get_node(pos_under)
    local node_names = params.node_names
    local end_node_name = params.end_node_name
    local end_node_param2 = params.end_node_param2

    -- get length
    local length = 0
    local temp_node = node

    while minetest.get_item_group(temp_node.name, 'vine') > 0 and length < 16 do
        length = length + 1
        temp_node = minetest.get_node(vector.new(pos.x, pos.y + length, pos.z))
    end

    -- stop growing - random height between 12 - 16 nodes
    if length > 11 and length < 16 then
        if math.random(1, 3) == 2 then
            return
        end
    end

    if length >= 16 then
        return
    end

    if minetest.get_item_group(node_under.name, 'vine') > 0 then
        -- stop timer for gown vine
        return
    end

    if node_under.name ~= 'air' then
        Everness:tick_vine_again(pos)
        return
    end

    local new_node_name = node_names[math.random(1, #node_names)]

    minetest.set_node(pos, { name = new_node_name, param2 = new_node_name.param2 or 0 })
    -- last hanging vine
    minetest.set_node(pos_under, { name = end_node_name, param2 = end_node_param2 and end_node_param2 or node.param2 })

    Everness:tick_vine(pos_under)
end

--
-- Sounds
--

function Everness.node_sound_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = '', gain = 1.0 }
    table.dug = table.dug or { name = 'everness_stone_hit', gain = 1.0 }
    table.place = table.place or { name = 'everness_stone_dug', gain = 0.6 }
    return table
end

function Everness.node_sound_frosted_snow_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_frosted_snow_footstep', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_frosted_snow_hit', gain = 0.2 }
    table.dug = table.dug or { name = 'everness_frosted_snow_footstep', gain = 0.3 }
    table.place = table.place or { name = 'everness_frosted_snow_place', gain = 0.25 }
    return table
end

function Everness.node_sound_crystal_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_crystal_chime', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_crystal_chime', gain = 0.3 }
    table.dug = table.dug or { name = 'everness_stone_footstep', gain = 0.3 }
    table.place = table.place or { name = 'everness_crystal_chime', gain = 1.0 }
    return table
end

function Everness.node_sound_bamboo_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_bamboo_hit', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_bamboo_hit', gain = 0.3 }
    table.dug = table.dug or { name = 'everness_bamboo_dug', gain = 0.1 }
    table.place = table.place or { name = 'everness_bamboo_hit', gain = 1.0 }
    return table
end

function Everness.node_sound_mud_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_mud_footstep', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_mud_footstep', gain = 0.3 }
    table.dug = table.dug or { name = 'everness_mud_footstep', gain = 0.1 }
    table.place = table.place or { name = 'everness_mud_footstep', gain = 1.0 }
    return table
end

function Everness.node_sound_grass_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_grass_footstep', gain = 0.4 }
    table.dig = table.dig or { name = 'everness_grass_hit', gain = 1.2 }
    table.dug = table.dug or { name = 'everness_dirt_hit', gain = 1.0 }
    table.place = table.place or { name = 'everness_dirt_hit', gain = 1.0 }
    return table
end

function Everness.node_sound_dirt_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_dirt_footstep', gain = 0.15 }
    table.dig = table.dig or { name = 'everness_dirt_hit', gain = 0.4 }
    table.dug = table.dug or { name = 'everness_dirt_hit', gain = 1.0 }
    table.place = table.place or { name = 'everness_dirt_hit', gain = 1.0 }
    return table
end

function Everness.node_sound_ice_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_ice_footstep', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_ice_hit', gain = 0.4 }
    table.dug = table.dug or { name = 'everness_ice_hit', gain = 1.0 }
    table.place = table.place or { name = 'everness_ice_hit', gain = 1.0 }
    return table
end

function Everness.node_sound_stone_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_stone_footstep', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_stone_hit', gain = 1.0 }
    table.dug = table.dug or { name = 'everness_stone_dug', gain = 0.6 }
    table.place = table.place or { name = 'everness_stone_place', gain = 1.0 }
    return table
end

function Everness.node_sound_leaves_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_leaves_footstep', gain = 0.1 }
    table.dig = table.dig or { name = 'everness_leaves_hit', gain = 0.25 }
    table.dug = table.dug or { name = 'everness_leaves_dug', gain = 0.5 }
    table.place = table.place or { name = 'everness_leaves_place', gain = 0.4 }
    return table
end

function Everness.node_sound_wood_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_wood_footstep', gain = 0.15 }
    table.dig = table.dig or { name = 'everness_wood_hit', gain = 0.8 }
    table.dug = table.dug or { name = 'everness_wood_place', gain = 0.1 }
    table.place = table.place or { name = 'everness_wood_place', gain = 0.15 }
    return table
end

function Everness.node_sound_sand_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_sand_footstep', gain = 0.1 }
    table.dig = table.dig or { name = 'everness_sand_hit', gain = 0.5 }
    table.dug = table.dug or { name = 'everness_sand_dug', gain = 0.1 }
    table.place = table.place or { name = 'everness_sand_place', gain = 0.15 }
    return table
end

function Everness.node_sound_metal_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_metal_footstep', gain = 0.1 }
    table.dig = table.dig or { name = 'everness_metal_hit', gain = 0.5 }
    table.dug = table.dug or { name = 'everness_metal_dug', gain = 0.1 }
    table.place = table.place or { name = 'everness_metal_place', gain = 0.15 }
    return table
end

function Everness.node_sound_glass_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_glass_footstep', gain = 0.02 }
    table.dig = table.dig or { name = 'everness_glass_footstep', gain = 0.05 }
    table.dug = table.dug or { name = 'everness_glass_dug', gain = 0.4 }
    table.place = table.place or { name = 'everness_glass_place', gain = 0.2 }
    return table
end

function Everness.node_sound_thin_glass_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_thin_glass_footstep', gain = 0.3 }
    table.dig = table.dig or { name = 'everness_thin_glass_footstep', gain = 0.5 }
    table.dug = table.dug or { name = 'everness_break_thin_glass', gain = 1.0 }
    table.place = table.place or { name = 'everness_glass_place', gain = 0.2 }
    return table
end

function Everness.node_sound_snow_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_snow_footstep', gain = 0.1 }
    table.dig = table.dig or { name = 'everness_snow_hit', gain = 0.2 }
    table.dug = table.dug or { name = 'everness_snow_footstep', gain = 0.2 }
    table.place = table.place or { name = 'everness_snow_place', gain = 0.3 }
    return table
end

function Everness.node_sound_gravel_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_gravel_footstep', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_gravel_hit', gain = 1.0 }
    table.dug = table.dug or { name = 'everness_gravel_dug', gain = 0.6 }
    table.place = table.place or { name = 'everness_gravel_place', gain = 1.0 }
    return table
end

function Everness.node_sound_ceramic_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_ceramic_footstep', gain = 0.2 }
    table.dig = table.dig or { name = 'everness_ceramic_hit', gain = 1.0 }
    table.dug = table.dug or { name = 'everness_ceramic_dug', gain = 1.0 }
    table.place = table.place or { name = 'everness_ceramic_place', gain = 1.0 }
    return table
end

function Everness.node_sound_water_defaults(table)
    table = table or {}
    table.footstep = table.footstep or { name = 'everness_water_footstep', gain = 0.05 }
    Everness.node_sound_defaults(table)
    return table
end

--
-- Forsted Cave Icicles
--

function Everness.stack_icicle_recursive(node, pos_node, incrementer, pos_marker, direction)
    local nb = node
    local pos = pos_node
    local inc = incrementer
    local m_pos = pos_marker

    while nb.name == 'air' or nb.name == 'ignore' do
        if nb.name == 'ignore' then
            Everness.emerge_icicle_area_recursive(pos, inc, m_pos, direction)
            break
        else
            minetest.set_node(pos, { name = 'everness:frosted_cave_ice_illuminating' })
            -- Shift 1 down
            inc = inc + 1
            local y_offset = (direction == 'down') and (m_pos.y - inc) or (m_pos.y + inc)
            pos = vector.new(m_pos.x, y_offset, m_pos.z)
            nb = minetest.get_node(pos)
        end
    end
end

function Everness.emerge_icicle_area_recursive(pos_node, incrementer, pos_marker, direction)
    local y_offset = (direction == 'down') and (pos_node.y - 16) or (pos_node.y + 16)

    minetest.emerge_area(
        vector.new(pos_node.x - 1, pos_node.y, pos_node.z - 1),
        vector.new(pos_node.x + 1, y_offset, pos_node.z + 1),
        function(blockpos, action, calls_remaining, param)
            Everness:emerge_area(blockpos, action, calls_remaining, param)
        end,
        {
            callback = function(data)
                local incrementer_cllbck = data.incrementer
                local pos_node_cllbck = data.pos_node
                local node_cllbck = minetest.get_node(pos_node_cllbck)

                Everness.stack_icicle_recursive(node_cllbck, pos_node_cllbck, incrementer_cllbck, pos_marker, direction)
            end,
            data = {
                incrementer = incrementer,
                pos_node = pos_node
            }
        }
    )
end

function Everness.use_shell_of_underwater_breathing(self, itemstack, user, pointed_thing)
    if not user then
        return
    end

    local pos_player = user:get_pos()

    if pointed_thing.type == 'node' then
        local pos_pt = minetest.get_pointed_thing_position(pointed_thing)

        if not pos_pt then
            return itemstack
        end

        local pointed_node = minetest.get_node(pos_pt)
        local pointed_node_def = minetest.registered_nodes[pointed_node.name]

        if not pointed_node or not pointed_node_def then
            return itemstack
        end

        if pointed_node_def.on_rightclick then
            return pointed_node_def.on_rightclick(pos_pt, pointed_node, user, itemstack, pointed_thing)
        end
    end

    local node_head = minetest.get_node(
        vector.new(
            math.floor(pos_player.x + 0.5),
            math.ceil(pos_player.y + 1),
            math.floor(pos_player.z + 0.5)
        )
    )
    local breath = user:get_breath()

    if minetest.get_item_group(node_head.name, 'water') > 0 and breath < 9 then
        -- Under water
        user:set_breath(9)

        if not minetest.settings:get_bool('creative_mode')
            or not minetest.check_player_privs(user:get_player_name(), { creative = true })
        then
            local wear_to_add = 65535 / 20

            if itemstack:get_wear() + wear_to_add > 65535 then
                local itemstack_def = itemstack:get_definition()

                -- Break tool
                minetest.sound_play(itemstack_def.sound.breaks, {
                    pos = pos_player,
                    gain = 0.5
                }, true)
            end

            itemstack:add_wear(wear_to_add)
        end

        minetest.sound_play('everness_underwater_bubbles', {
            object = user,
            gain = 1.0,
            max_hear_distance = 16
        })

        minetest.add_particlespawner({
            amount = 40,
            time = 0.1,
            pos = {
                min = vector.new(pos_player.x - 0.25, pos_player.y + 1.25, pos_player.z - 0.25),
                max = vector.new(pos_player.x + 0.25, pos_player.y + 1.5, pos_player.z + 0.25)
            },
            vel = {
                min = vector.new(-0.5, 0, -0.5),
                max = vector.new(0.5, 0, 0.5)
            },
            acc = {
                min = vector.new(-0.5, 4, -0.5),
                max = vector.new(0.5, 1, 0.5),
            },
            exptime = {
                min = 1,
                max = 2
            },
            size = {
                min = 0.5,
                max = 2
            },
            texture = {
                name = 'everness_bubble.png',
                alpha_tween = {
                    1, 0,
                    start = 0.75
                }
            }
        })
    end

    return itemstack
end

--
-- Sapling 'on place' function to check protection of node and resulting tree volume
-- copy from MTG
--
function Everness.sapling_on_place(self, itemstack, placer, pointed_thing, props)
    if minetest.get_modpath('mcl_util') and minetest.global_exists('mcl_util') then
        local on_place_func = mcl_util.generate_on_place_plant_function(function(pos, node)
            local node_below = minetest.get_node_or_nil({ x = pos.x, y = pos.y - 1, z = pos.z })

            if not node_below then
                return false
            end

            local nn = node_below.name

            return minetest.get_item_group(nn, 'grass_block') == 1
                or (nn == 'everness:mineral_sand' and itemstack:get_name() == 'everness:palm_tree_sapling')
                or nn == 'mcl_core:podzol'
                or nn == 'mcl_core:podzol_snow'
                or nn == 'mcl_core:dirt'
                or nn == 'mcl_core:mycelium'
                or nn == 'mcl_core:coarse_dirt'
        end)

        return on_place_func(itemstack, placer, pointed_thing)
    else
        local _props = props or {}
        local sapling_name = _props.sapling_name
        -- minp, maxp to be checked, relative to sapling pos
        -- minp_relative.y = 1 because sapling pos has been checked
        local minp_relative = _props.minp_relative
        local maxp_relative = _props.maxp_relative
        -- maximum interval of interior volume check
        local interval = _props.interval

        -- Position of sapling
        local pos = pointed_thing.under
        local node = minetest.get_node_or_nil(pos)
        local pdef = node and minetest.registered_nodes[node.name]

        if pdef and node and pdef.on_rightclick
            and not (placer and placer:is_player()
            and placer:get_player_control().sneak)
        then
            return pdef.on_rightclick(pos, node, placer, itemstack, pointed_thing)
        end

        if not pdef or not pdef.buildable_to then
            pos = pointed_thing.above
            node = minetest.get_node_or_nil(pos)
            pdef = node and minetest.registered_nodes[node.name]

            if not pdef or not pdef.buildable_to then
                return itemstack
            end
        end

        local player_name = placer and placer:get_player_name() or ''

        -- Check sapling position for protection
        if minetest.is_protected(pos, player_name) then
            minetest.record_protection_violation(pos, player_name)
            return itemstack
        end

        -- Check tree volume for protection
        if minetest.is_area_protected(
                vector.add(pos, minp_relative),
                vector.add(pos, maxp_relative),
                player_name,
                interval
            )
        then
            minetest.record_protection_violation(pos, player_name)
            minetest.chat_send_player(
                player_name,
                S('@1 will intersect protection on growth.', itemstack:get_definition().description)
            )

            return itemstack
        end

        Everness.log_player_action(placer, 'places node', sapling_name, 'at', pos)

        local take_item = not minetest.is_creative_enabled(player_name)
        local newnode = { name = sapling_name }
        local ndef = minetest.registered_nodes[sapling_name]

        minetest.set_node(pos, newnode)

        -- Run callback
        if ndef and ndef.after_place_node then
            -- Deepcopy place_to and pointed_thing because callback can modify it
            if ndef.after_place_node(table.copy(pos), placer,
                    itemstack, table.copy(pointed_thing)) then
                take_item = false
            end
        end

        -- Run script hook
        for _, callback in ipairs(minetest.registered_on_placenodes or {}) do
            -- Deepcopy pos, node and pointed_thing because callback can modify them
            if callback(table.copy(pos), table.copy(newnode),
                    placer, table.copy(node or {}),
                    itemstack, table.copy(pointed_thing)) then
                take_item = false
            end
        end

        if take_item then
            itemstack:take_item()
        end

        return itemstack
    end
end

--
-- Leafdecay - taken from MTG
--

-- Prevent decay of placed leaves

Everness.after_place_leaves = function(self, pos, placer, itemstack, pointed_thing)
    if placer and placer:is_player() then
        local node = minetest.get_node(pos)
        node.param2 = 1
        minetest.set_node(pos, node)
    end
end

-- Leafdecay
local function leafdecay_after_destruct(pos, oldnode, def)
    for _, v in pairs(minetest.find_nodes_in_area(vector.subtract(pos, def.radius),
        vector.add(pos, def.radius), def.leaves))
    do
        local node = minetest.get_node(v)
        local timer = minetest.get_node_timer(v)
        if node.param2 ~= 1
            and minetest.get_meta(v):get_int('everness_prevent_leafdecay') ~= 1
            and not timer:is_started()
        then
            timer:start(math.random(20, 120) / 10)
        end
    end
end

local movement_gravity = tonumber(minetest.settings:get('movement_gravity')) or 9.81

local function leafdecay_on_timer(pos, def)
    if minetest.find_node_near(pos, def.radius, def.trunks) then
        return false
    end

    local node = minetest.get_node(pos)
    local drops = minetest.get_node_drops(node.name)

    for _, item in ipairs(drops) do
        local is_leaf
        for _, v in pairs(def.leaves) do
            if v == item then
                is_leaf = true
            end
        end
        if minetest.get_item_group(item, 'leafdecay_drop') ~= 0
            or not is_leaf
        then
            minetest.add_item({
                x = pos.x - 0.5 + math.random(),
                y = pos.y - 0.5 + math.random(),
                z = pos.z - 0.5 + math.random(),
            }, item)
        end
    end

    minetest.remove_node(pos)
    minetest.check_for_falling(pos)

    -- spawn a few particles for the removed node
    minetest.add_particlespawner({
        amount = 8,
        time = 0.001,
        minpos = vector.subtract(pos, { x = 0.5, y = 0.5, z = 0.5 }),
        maxpos = vector.add(pos, { x = 0.5, y = 0.5, z = 0.5 }),
        minvel = vector.new(-0.5, -1, -0.5),
        maxvel = vector.new(0.5, 0, 0.5),
        minacc = vector.new(0, -movement_gravity, 0),
        maxacc = vector.new(0, -movement_gravity, 0),
        minsize = 0,
        maxsize = 0,
        node = node,
    })
end

function Everness.register_leafdecay(self, def)
    assert(def.leaves)
    assert(def.trunks)
    assert(def.radius)

    for _, v in pairs(def.trunks) do
        minetest.override_item(v, {
            after_destruct = function(pos, oldnode)
                leafdecay_after_destruct(pos, oldnode, def)
            end,
        })
    end

    for _, v in pairs(def.leaves) do
        minetest.override_item(v, {
            on_timer = function(pos)
                leafdecay_on_timer(pos, def)
            end,
        })
    end
end

function Everness.register_node(self, name, def)
    local _def = table.copy(def)
    local _name = name

    _def.mod_origin = 'everness'

    -- X Farming composter description
    if minetest.get_modpath('x_farming') and minetest.global_exists('x_farming') then
        -- X Farming
        if _def.groups and (_def.groups.compost or 0) > 0 then
            _def.description = _def.description .. '\n' .. S('Compost chance') .. ': ' .. def.groups.compost .. '%'
        end
    end

    self.registered_nodes[_name] = _def
    minetest.register_node(_name, _def)
end

function Everness.register_tool(self, name, def)
    local _def = table.copy(def)
    local _name = name

    _def.mod_origin = 'everness'

    self.registered_tools[_name] = _def
    minetest.register_tool(_name, _def)
end

function Everness.register_abm(self, def)
    local _def = table.copy(def)
    local _name = _def.label

    self.registered_abms[_name] = _def
    minetest.register_abm(_def)
end

function Everness.register_lbm(self, def)
    local _def = table.copy(def)
    local _name = _def.name

    self.registered_lbms[_name] = _def
    minetest.register_lbm(_def)
end

function Everness.register_craftitem(self, name, def)
    local _def = table.copy(def)
    local _name = name

    _def.mod_origin = 'everness'

    self.registered_craftitems[_name] = _def
    minetest.register_craftitem(_name, _def)
end

function Everness.register_biome(self, def)
    local _def = table.copy(def)
    local _name = _def.name

    self.registered_biomes[_name] = _def
    minetest.register_biome(_def)
end

function Everness.register_decoration(self, def)
    local _def = table.copy(def)
    local _name = _def.name

    self.registered_decorations[_name] = _def
    minetest.register_decoration(_def)
end

function Everness.register_ore(self, def)
    local _def = table.copy(def)
    -- @TOTO using `ore` as name here will override the entry when there are multiple ore registrations for the same ore (different noise)
    -- using indexed table would be more appropriate here
    local _name = _def.ore

    self.registered_ores[_name] = _def
    minetest.register_ore(_def)
end

--
-- Log API / helpers - copy from MTG
--

local log_non_player_actions = minetest.settings:get_bool('log_non_player_actions', false)

local is_pos = function(v)
    return type(v) == 'table'
        and type(v.x) == 'number'
        and type(v.y) == 'number'
        and type(v.z) == 'number'
end

function Everness.log_player_action(player, ...)
    local msg = player:get_player_name()
    if player.is_fake_player or not player:is_player() then
        if not log_non_player_actions then
            return
        end

        msg = msg .. '(' .. (type(player.is_fake_player) == 'string'
            and player.is_fake_player or '*') .. ')'
    end
    for _, v in ipairs({ ... }) do
        -- translate pos
        local part = is_pos(v) and minetest.pos_to_string(v) or v
        -- no leading spaces before punctuation marks
        msg = msg .. (string.match(part, '^[;,.]') and '' or ' ') .. part
    end

    minetest.log('action', msg)
end

function Everness.set_inventory_action_loggers(def, name)
    def.on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
        Everness.log_player_action(player, 'moves stuff in', name, 'at', pos)
    end
    def.on_metadata_inventory_put = function(pos, listname, index, stack, player)
        Everness.log_player_action(player, 'moves', stack:get_name(), 'to', name, 'at', pos)
    end
    def.on_metadata_inventory_take = function(pos, listname, index, stack, player)
        Everness.log_player_action(player, 'takes', stack:get_name(), 'from', name, 'at', pos)
    end
end

-- 'can grow' function - copy from MTG

function Everness.can_grow(pos, groups_under)
    local node_under = minetest.get_node_or_nil({ x = pos.x, y = pos.y - 1, z = pos.z })

    if not node_under then
        return false
    end

    local _groups_under = groups_under

    if not groups_under then
        _groups_under = { 'soil' }
    end

    local has_fertile_under = false

    -- Check is one of the `groups_under` are under the sapling
    for i, v in ipairs(_groups_under) do
        if minetest.get_item_group(node_under.name, v) > 0 then
            has_fertile_under = true
            break
        end
    end

    if not has_fertile_under then
        return false
    end

    local light_level = minetest.get_node_light(pos)

    if not light_level or light_level < 13 then
        return false
    end

    return true
end

--
-- This method may change in future.
-- Copy from MTG
--

function Everness.can_interact_with_node(player, pos)
    if player and player:is_player() then
        if minetest.check_player_privs(player, 'protection_bypass') then
            return true
        end
    else
        return false
    end

    local meta = minetest.get_meta(pos)
    local owner = meta:get_string('owner')

    if not owner or owner == '' or owner == player:get_player_name() then
        return true
    end

    -- Is player wielding the right key?
    local item = player:get_wielded_item()

    if minetest.get_item_group(item:get_name(), 'key') == 1 then
        local key_meta = item:get_meta()

        if key_meta:get_string('secret') == '' then
            local key_oldmeta = item:get_metadata()

            if key_oldmeta == '' or not minetest.parse_json(key_oldmeta) then
                return false
            end

            key_meta:set_string('secret', minetest.parse_json(key_oldmeta).secret)
            item:set_metadata('')
        end

        return meta:get_string('key_lock_secret') == key_meta:get_string('secret')
    end

    return false
end

--
-- Optimized helper to put all items in an inventory into a drops list
-- copy from MTG
--

function Everness.get_inventory_drops(pos, inventory, drops)
    local inv = minetest.get_meta(pos):get_inventory()
    local n = #drops
    for i = 1, inv:get_size(inventory) do
        local stack = inv:get_stack(inventory, i)
        if stack:get_count() > 0 then
            drops[n + 1] = stack:to_table()
            n = n + 1
        end
    end
end

function Everness.set_loot_chest_items()
    local loot_items = {}

    for name, def in pairs(minetest.registered_items) do
        local craft_recipe = minetest.get_craft_recipe(name)
        local mod_name = name:split(':')[1]

        if def.groups
            and next(def.groups)
            and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
            and (craft_recipe.items or mod_name == 'default')
        then
            table.insert(loot_items, {
                name = name,
                max_count = 10,
                chance = 25
            })
        end
    end

    Everness.loot_chest.default = table.copy(loot_items)
end

function Everness.populate_loot_chests(self, positions, params)
    -- local _params = params or {}
    -- local _loot_chest_items_group = _params.loot_chest_items_group or 'default'

    -- -- Get inventories
    -- local string_positions = '';
    -- local inventories = {}

    -- for i, pos in ipairs(positions) do
    --     local inv = minetest.get_inventory({ type = 'node', pos = pos })

    --     if not inv then
    --         local chest_def = minetest.registered_nodes['everness:chest']
    --         chest_def.on_construct(pos)
    --         inv = minetest.get_inventory({ type = 'node', pos = pos })
    --     end

    --     if inv then
    --         table.insert(inventories, inv)
    --         string_positions = string_positions .. ' ' .. pos:to_string()
    --     else
    --         minetest.log('warning', '[Everness] FAILED to populate loot chests inventory at ' .. pos:to_string())
    --     end
    -- end

    -- if #inventories > 0 then
    --     for index, value in ipairs(inventories[1]:get_list('main')) do
    --         local rand_idx = rand_global:next(1, #self.loot_chest[_loot_chest_items_group])
    --         local item_def = self.loot_chest[_loot_chest_items_group][rand_idx]

    --         if not minetest.registered_items[item_def.name] then
    --             return
    --         end

    --         if rand_global:next(0, 100) <= item_def.chance then
    --             local stack = ItemStack(item_def.name)

    --             if minetest.registered_tools[item_def.name] then
    --                 stack:set_wear(rand_global:next(1, 65535))
    --             else
    --                 stack:set_count(rand_global:next(1, math.min(item_def.max_count, stack:get_stack_max())))
    --             end

    --             local rand_inv = inventories[rand_global:next(1, #inventories)]
    --             rand_inv:set_stack('main', index, stack)
    --         end
    --     end

    --     minetest.log('action', '[Everness] Loot chests inventory populated at ' .. string_positions)
    -- end
end

--
-- Hammer
-- Modified version of default:tnt from MT
-- @license MIT

local function rand_pos(center, pos, radius)
    local def
    local reg_nodes = minetest.registered_nodes
    local i = 0

    repeat
        -- Give up and use the center if this takes too long
        if i > 4 then
            pos.x, pos.z = center.x, center.z
            break
        end

        pos.x = center.x + math.random(-radius, radius)
        pos.z = center.z + math.random(-radius, radius)
        def = reg_nodes[minetest.get_node(pos).name]
        i = i + 1
    until def and not def.walkable
end

local function eject_drops(drops, pos, radius)
    local drop_pos = vector.new(pos)

    for _, item in pairs(drops) do
        local count = math.min(item:get_count(), item:get_stack_max())

        while count > 0 do
            local take = math.max(
                1,
                math.min(
                    radius * radius,
                    count,
                    item:get_stack_max()
                )
            )

            -- `drop_pos` is being randomized here
            rand_pos(pos, drop_pos, radius)

            local dropitem = ItemStack(item)

            dropitem:set_count(take)

            local obj = minetest.add_item(drop_pos, dropitem)

            if obj then
                obj:get_luaentity().collect = true
                obj:set_acceleration({ x = 0, y = -10, z = 0 })
                obj:set_velocity({
                    x = math.random(-2, 2),
                    y = math.random(0, 2),
                    z = math.random(-2, 2)
                })
            end

            count = count - take
        end
    end
end

-- Populate `drops` table
local function add_drop(drops, item)
    item = ItemStack(item)

    local name = item:get_name()
    local drop = drops[name]

    if drop == nil then
        drops[name] = item
    else
        drop:set_count(drop:get_count() + item:get_count())
    end
end

local function destroy(drops, npos, cid, c_air, can_dig, owner)
    if minetest.is_protected(npos, owner) then
        return cid
    end

    local def = Everness.hammer_cid_data[cid]

    if not def then
        return cid
    elseif def.can_dig and not def.can_dig(npos, minetest.get_player_by_name(owner)) then
        return cid
    else
        local node_drops = minetest.get_node_drops(def.name, '')

        for _, item in pairs(node_drops) do
            add_drop(drops, item)
        end

        return c_air
    end
end

-- Draw wear bar texture overlay
function Everness.draw_wear_bar(itemstack, wear)
    local itemstack_meta = itemstack:get_meta()
    local px_width = 14
    local px_one = 65535 / px_width
    local px_color = px_width - math.floor(wear / px_one)

    local inventory_overlay = '[combine:16x16'

    for i = 1, px_width do
        if i > px_color then
            inventory_overlay = inventory_overlay .. ':' .. i .. ',14=[combine\\:1x1\\^[noalpha\\^[colorize\\:#000000\\:255'
        else
            local color

            if px_color < px_width / 4 then
                -- below 25%
                color = '#FF0000'
            elseif px_color < (px_width / 4) * 2 then
                -- below 50%
                color = '#FFA500'
            elseif px_color < (px_width / 4) * 3 then
                -- below 75%
                color = '#FFFF00'
            else
                -- above 75%
                color = '#00FF00'
            end

            inventory_overlay = inventory_overlay .. ':' .. i .. ',14=[combine\\:1x1\\^[noalpha\\^[colorize\\:' .. color .. '\\:255'
        end
    end

    itemstack_meta:set_string('inventory_overlay', inventory_overlay)
end

function Everness.hammer_after_dig_node(pos, node, metadata, digger, can_dig)
    if not digger then
        return
    end

    local wielditem = digger:get_wielded_item()

    if not (wielditem:get_name() == 'everness:hammer' or wielditem:get_name() == 'everness:hammer_sharp') then
        return
    end

    local radius = 1
    local look_dir = vector.round(digger:get_look_dir())
    local look_dir_multi = vector.round(vector.multiply(look_dir, radius / 2))
    pos = vector.round(vector.add(pos, look_dir_multi))
    local c_air = minetest.CONTENT_AIR
    local c_ignore = minetest.CONTENT_IGNORE
    local vm = VoxelManip()
    local pr = PseudoRandom(os.time())
    local p1 = vector.subtract(pos, radius)
    local p2 = vector.add(pos, radius)
    local minp, maxp = vm:read_from_map(p1, p2)
    local voxel_area = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
    local data = vm:get_data()
    -- `drops` are being populated in `add_drop` method, called from `destroy` method
    local drops = {}
    local p_name = digger:get_player_name()

    if not minetest.settings:get_bool('creative_mode') then
        local wielditem_meta = wielditem:get_meta()
        local wielditem_wear = wielditem_meta:get_int('everness_wear')
        local node_def = minetest.registered_nodes[node.name]
        local wielditem_def = wielditem:get_definition()
        local dig_params = minetest.get_dig_params(node_def and node_def.groups, wielditem_def and wielditem_def.tool_capabilities, wielditem:get_wear())
        local new_wear = wielditem_wear + dig_params.wear

        -- Add wear
        wielditem_meta:set_int('everness_wear', new_wear)

        -- Draw wear bar texture overlay
        Everness.draw_wear_bar(wielditem, new_wear)

        if wielditem_wear > 65535 then
            -- Break tool
            minetest.sound_play(wielditem_def.sound.breaks, {
                pos = pos,
                gain = 0.5
            }, true)

            if wielditem:get_name() == 'everness:hammer'
                or wielditem:get_name() == 'everness:hammer_sharp'
            then
                digger:set_wielded_item(ItemStack(''))
            end
        elseif wielditem:get_name() == 'everness:hammer'
            or wielditem:get_name() == 'everness:hammer_sharp'
        then
            -- Save wear
            digger:set_wielded_item(wielditem)
        end
    end

    -- Digging blast
    for z = -radius, radius do
        for y = -radius, radius do
            local vi = voxel_area:index(pos.x + (-radius), pos.y + y, pos.z + z)

            for x = -radius, radius do
                local r = vector.length(vector.new(x, y, z))

                if wielditem:get_name() == 'everness:hammer' then
                    if (radius * radius) / (r * r) >= (pr:next(30, 60) / 100) then
                        local cid = data[vi]
                        local p = vector.new(pos.x + x, pos.y + y, pos.z + z)

                        if cid ~= c_air and cid ~= c_ignore then
                            data[vi] = destroy(drops, p, cid, c_air, can_dig, p_name)
                        end
                    end
                else
                    local cid = data[vi]
                    local p = vector.new(pos.x + x, pos.y + y, pos.z + z)

                    if cid ~= c_air and cid ~= c_ignore then
                        data[vi] = destroy(drops, p, cid, c_air, can_dig, p_name)
                    end
                end

                vi = vi + 1
            end
        end
    end

    vm:set_data(data)
    vm:write_to_map()
    vm:update_map()
    vm:update_liquids()

    -- Call `check_single_for_falling` for everything within 1.5x blast radius
    for y = math.round(-radius * 1.5), math.round(radius * 1.5) do
        for z = math.round(-radius * 1.5), math.round(radius * 1.5) do
            for x = math.round(-radius * 1.5), math.round(radius * 1.5) do
                local rad = vector.new(x, y, z)
                local s = vector.add(pos, rad)

                minetest.check_single_for_falling(s)
            end
        end
    end

    eject_drops(drops, pos, radius)

    -- Get texture for particles from majority of the dug nodes
    local node_for_particles
    local most = 0

    for name, stack in pairs(drops) do
        local count = stack:get_count()

        if count > most then
            most = count
            local def = minetest.registered_nodes[name]

            if def then
                node_for_particles = { name = name }
            end

            -- Play sounds
            if def and def.sounds and def.sounds.dug then
                for i = 1, math.random(2, 5) do
                    local drop_pos = vector.new(pos)

                    -- `drop_pos` is being randomized here
                    rand_pos(pos, drop_pos, radius)

                    minetest.after(
                        math.random(2, 8) / 10,
                        function()
                            minetest.sound_play(def.sounds.dug, {
                                pos = drop_pos,
                                pitch = math.random(1, 10) / 10
                            }, true)
                        end
                    )
                end
            end
        end
    end

    if node_for_particles then
        minetest.add_particlespawner({
            amount = 64,
            time = 0.1,
            minpos = vector.subtract(pos, radius / 2),
            maxpos = vector.add(pos, radius / 2),
            minvel = {x = -2, y = 0, z = -2},
            maxvel = {x = 2, y = 5,  z = 2},
            minacc = {x = 0, y = -10, z = 0},
            maxacc = {x = 0, y = -10, z = 0},
            minexptime = 0.8,
            maxexptime = 2.0,
            minsize = radius * 0.33,
            maxsize = radius,
            node = node_for_particles,
            collisiondetection = true,
        })
    end
end

-- Function triggered for each qualifying node.
-- `dtime_s` is the in-game time (in seconds) elapsed since the block
-- was last active
function Everness.cool_lava(pos, node, dtime_s, prev_cool_lava_action)
    -- Variant Obsidian
    if
        node.name == 'default:lava_source'
        or node.name == 'mcl_core:lava_source'
        or node.name == 'everness:lava_source'
    then
        if math.random(1, 10) == 1 then
            local obi_nodes = {
                { name = 'everness:blue_crying_obsidian', color = '#2978A6'},
                { name = 'everness:blue_weeping_obsidian', color = '#25B8FF'},
                { name = 'everness:weeping_obsidian', color = '#C90FFF'},
            }
            local rand_node = obi_nodes[math.random(1, #obi_nodes)]

            minetest.set_node(pos, {
                name = rand_node.name
            })

            minetest.sound_play('everness_cool_lava',
                {
                    pos = pos,
                    max_hear_distance = 16,
                    gain = 0.2
                },
                true
            )

            if minetest.has_feature({ dynamic_add_media_table = true, particlespawner_tweenable = true }) then
                -- new syntax, after v5.6.0
                minetest.add_particlespawner({
                    amount = 80,
                    time = 1,
                    size = {
                        min = 0.5,
                        max = 1,
                    },
                    exptime = 1,
                    pos = pos,
                    glow = 7,
                    attract = {
                        kind = 'point',
                        strength = 0.5,
                        origin = pos,
                        die_on_contact = true
                    },
                    radius = 3,
                    texture = {
                        name = 'everness_particle.png^[colorize:' .. rand_node.color .. ':255',
                        alpha_tween = {
                            0, 1,
                            style = 'fwd',
                            reps = 1
                        },
                        scale_tween = {
                            0.25, 1,
                            style = 'fwd',
                            reps = 1
                        }
                    }
                })
            end
        elseif node.name == 'everness:lava_source' then
            -- Lava flowing
            minetest.set_node(pos, {name = 'default:obsidian'})
        elseif node.name == 'everness:lava_flowing' then
            -- Lava flowing
            minetest.set_node(pos, {name = 'default:stone'})
        else
            prev_cool_lava_action(pos, node, dtime_s)
        end
    else
        prev_cool_lava_action(pos, node, dtime_s)
    end
end
function Everness.get_pot_formspec(pos, label, model_texture)
    local spos = pos.x .. ',' .. pos.y .. ',' .. pos.z
    local hotbar_bg = ''
    local list_bg = ''

    for i = 0, 7, 1 do
        hotbar_bg = hotbar_bg .. 'image[' .. 0 + i .. ', ' .. 4.85 .. ';1,1;everness_chest_ui_bg_hb_slot.png]'
    end

    for row = 0, 2, 1 do
        for i = 0, 7, 1 do
            list_bg = list_bg .. 'image[' .. 0 + i .. ',' .. 6.08 + row .. ';1,1;everness_chest_ui_bg_slot.png]'
        end
    end

    local model = 'model[0,0.5;2.5,2.5;everness_ceramic_pot;everness_ceramic_pot.obj;' .. model_texture .. ';0,0;true;false;]'

    local formspec = {
        'size[8,9]',
        'listcolors[#FFFFFF00;#FFFFFF1A;#5E5957]',
        'background[5,5;1,1;everness_chest_ui_bg.png;true]',
        'list[nodemeta:' .. spos .. ';main;0.5,3;1,1;]',
        'list[current_player;main;0,4.85;8,1;]',
        'list[current_player;main;0,6.08;8,3;8]',
        'listring[nodemeta:' .. spos .. ';main]',
        'listring[current_player;main]',
        list_bg,
        hotbar_bg,
        'image[0.5,3;1,1;everness_chest_ui_bg_hb_slot.png]',
        'label[2.5,0.5;' .. minetest.formspec_escape(label) .. ']',
        model
    }

    formspec = table.concat(formspec, '')

    return formspec
end

--
-- Encyclopedia
--

local ency_data = {
    nodes = {},
    tools = {},
    abms = {},
    lbms = {},
    craftitems = {},
    biomes = {},
    decorations = {},
    ores = {},
}

--
-- Encyclopedia Helpers
--

local function tchelper(first, rest)
    return first:upper()..rest:lower()
end

local function capitalize(str)
    -- Add extra characters to the pattern if you need to. _ and ' are
    --  found in the middle of identifiers and English words.
    -- We must also put %w_' into [%w_'] to make it handle normal stuff
    -- and extra stuff the same.
    -- This also turns hex numbers into, eg. 0Xa7d4
    return str:gsub("(%a)([%w_']*)", tchelper)
end

local function tech_name_to_pretty_name(tech_name)
    local short_name = tech_name:split(':')[2]
    short_name = short_name:gsub('_', ' ')
    short_name = capitalize(short_name)

    return short_name
end

local function get_model_texture_from_tile_definition(tile_def)
    -- Assumptions its a string
    local texture = ''

    for i, v in ipairs(tile_def) do
        local temp = tile_def[i]

        if type(temp) == 'table' then
            if temp.name then
                temp = temp.name
            else
                temp = temp[i]
            end
        end

        texture = texture .. (i == 1 and '' or ',') .. temp
    end

    return texture
end

local function get_unordered_list(tbl, pos, formspec, lvl)
    local _formspec = formspec or {}
    local _lvl = lvl or 1

    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            -- Label
            pos.y = pos.y + 0.25
            _formspec[#_formspec + 1] = ('label[%f,%f;%s]'):format(pos.x + 0.25 * _lvl, pos.y, k .. ':')
            get_unordered_list(v, pos, _formspec, _lvl + 1)
        else
            if minetest.registered_items[v] then
                pos.y = pos.y + 0.25
                -- Label
                _formspec[#_formspec + 1] = ('label[%f,%f;%s]'):format(pos.x + 0.25 * _lvl, pos.y, k .. ':')
                pos.y = pos.y + 0.25
                -- Item image
                _formspec[#_formspec + 1] = ('item_image[%f,%f;1,1;%s]'):format(pos.x + 0.25 * _lvl, pos.y, v)
                -- Tooltip for description
                _formspec[#_formspec + 1] = ('tooltip[%f,%f;1,1;%s]'):format(pos.x + 0.25 * _lvl, pos.y, minetest.formspec_escape(v))
                pos.y = pos.y + 1
            else
                pos.y = pos.y + 0.25
                -- List "bullet"
                _formspec[#_formspec + 1] = ('label[%f,%f;%s]'):format(pos.x + 0.25 * _lvl, pos.y, k .. ': ' .. v)
            end
        end
    end

    _formspec = table.concat(_formspec, '')

    return _formspec
end

--
-- Encyclopedia API
--

function Everness.encyclopedia_init(self)
    -- Nodes
    for name, def in pairs(self.registered_nodes) do
        if def.groups
            and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
        then
            table.insert(ency_data.nodes, name)
        end
    end

    -- Tools
    for name, def in pairs(self.registered_tools) do
        if def.groups
            and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
        then
            table.insert(ency_data.tools, name)
        end
    end

    -- ABMs
    for name, def in pairs(self.registered_abms) do
        table.insert(ency_data.abms, name)
    end

    -- LBMs
    for name, def in pairs(self.registered_lbms) do
        table.insert(ency_data.lbms, name)
    end

    -- Craftitems
    for name, def in pairs(self.registered_craftitems) do
        if def.groups
            and (not def.groups.not_in_creative_inventory or def.groups.not_in_creative_inventory == 0)
        then
            table.insert(ency_data.craftitems, name)
        end
    end

    -- Biomes
    for name, def in pairs(self.registered_biomes) do
        table.insert(ency_data.biomes, name)
    end

    -- Decorations
    for name, def in pairs(self.registered_decorations) do
        table.insert(ency_data.decorations, name)
    end

    -- Ores
    for name, def in pairs(self.registered_ores) do
        table.insert(ency_data.ores, name)
    end

    -- Sort alphabetically
    table.sort(ency_data.nodes, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.tools, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.abms, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.lbms, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.craftitems, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.biomes, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.decorations, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    table.sort(ency_data.ores, function(a ,b)
        return tech_name_to_pretty_name(a) < tech_name_to_pretty_name(b)
    end)

    if minetest.get_modpath('unified_inventory') then
        self:encyclopedia_ui_register_page()
    elseif minetest.get_modpath('i3') then
        self:encyclopedia_i3_register_page()
    elseif minetest.get_modpath('sfinv') and sfinv.enabled then
        self:encyclopedia_sfinv_register_page()
    end
end

function Everness.encyclopedia_get_formspec(self, context)
    local pos_primary = vector.new()
    local pos_secondary = vector.new()
    local pos_secondary_container = vector.new()
    local primary_selected_idx = context.everness_ency_primary_selected_idx or 1
    local dropdown_idx = context.everness_ency_dropdown_idx or 1

    context.everness_ency_primary_selected_idx = primary_selected_idx
    context.everness_ency_dropdown_idx = dropdown_idx

    -- Get dropdown items
    local ency_dropdown_items = {}

    for k, v in pairs(ency_data) do
        table.insert(ency_dropdown_items, k)
    end

    table.sort(ency_dropdown_items)

    -- Dropdown string value (main category)
    local dropdown_value = ency_dropdown_items[dropdown_idx]
    -- Data to show in secondary container (corresponding to selected index in primary item list)
    local primary_list_data = ency_data[dropdown_value]
    -- Get primary list items (list on the left)
    local primary_list_items = {}

    for k, v in ipairs(primary_list_data) do
        table.insert(primary_list_items, tech_name_to_pretty_name(v))
    end

    -- Primary list selected item value (item technical name, e.g. 'everness:palm_tree_wood')
    local primary_list_selected_value = primary_list_data[primary_selected_idx]
    local def = self['registered_' .. dropdown_value][primary_list_selected_value]

    pos_primary.x = pos_primary.x + 0.25
    pos_primary.y = pos_primary.y + 0.5

    local formspec = {
        -- Title
        'real_coordinates[true]',
        ('label[%f,%f;%s]'):format(pos_primary.x, pos_primary.y, minetest.formspec_escape(S('Everness Encyclopedia'))),
    }

    -- Dropdown (main categories)
    pos_primary.y = pos_primary.y + 0.4
    formspec[#formspec + 1] = ('dropdown[%f,%f;4,0.4;everness_ency_dropdown;%s;%d;true]'):format(pos_primary.x, pos_primary.y, table.concat(ency_dropdown_items, ','), dropdown_idx)
    -- Primary list
    pos_primary.y = pos_primary.y + 0.6
    formspec[#formspec + 1] = ('textlist[%f,%f;4,9;everness_ency_main_list;%s;%d;false]'):format(pos_primary.x, pos_primary.y, table.concat(primary_list_items, ','), primary_selected_idx)
    -- Secondary (details on the right)
    pos_secondary.x = pos_secondary.x + 4.5
    pos_secondary.y = pos_secondary.y + 1.4
    formspec[#formspec + 1] = ('scroll_container[%f,%f;5.5,9;everness_ency_detail_view_scrollbar;vertical;0.1]'):format(pos_secondary.x, pos_secondary.y)
    -- Secondary title
    pos_secondary_container.y = pos_secondary_container.y + 0.25
    formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, primary_list_selected_value)
    -- Margin
    pos_secondary_container.y = pos_secondary_container.y + 0.5

    if minetest['registered_' .. dropdown_value][primary_list_selected_value]
        and dropdown_value ~= 'biomes'
        and dropdown_value ~= 'decorations'
        and dropdown_value ~= 'ores'
    then
        if def.mesh then
            -- Item model
            formspec[#formspec + 1] = ('model[%f,%f;2,2;%s;%s;%s;-30,0;true;true;]'):format(pos_secondary_container.x, pos_secondary_container.y, primary_list_selected_value, def.mesh, get_model_texture_from_tile_definition(def.tiles))
        else
            -- Item image
            formspec[#formspec + 1] = ('item_image[%f,%f;2,2;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, primary_list_selected_value)
        end

        if def.description then
            -- Tooltip for description
            formspec[#formspec + 1] = ('tooltip[%f,%f;2,2;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, minetest.formspec_escape(def.description))
        end

        pos_secondary_container.y = pos_secondary_container.y + 2
    elseif def and def.description then
        -- Label description
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, minetest.formspec_escape(def.description))
    end

    if def and def.label then
        pos_secondary_container.y = pos_secondary_container.y + 0.25
        -- Label description
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, minetest.formspec_escape(def.label))
    end

    -- Groups
    if def and def.groups and next(def.groups) then
        pos_secondary_container.y = pos_secondary_container.y + 0.5
        -- Title
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, 'Groups:')
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list((def.groups or {}), pos_secondary_container)
    end

    -- Tool capabilities
    if def and def.tool_capabilities and next(def.tool_capabilities) then
        pos_secondary_container.y = pos_secondary_container.y + 0.5
        -- Title
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, 'Tool Capabilities:')
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list((def.tool_capabilities or {}), pos_secondary_container)
    end

    -- ABM/LBM nodenames
    if def and def.nodenames then
        pos_secondary_container.y = pos_secondary_container.y + 0.5
        -- Title
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, 'Apply "action" function to these nodes:')
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list((def.nodenames or {}), pos_secondary_container)
    end

    -- ABM neighbors
    if def and def.neighbors and next(def.neighbors) then
        pos_secondary_container.y = pos_secondary_container.y + 0.5
        -- Title
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, 'Only apply "action" to nodes that have one of, or any combination of, these neighbors:')
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list((def.neighbors or {}), pos_secondary_container)
    end

    if def and def.run_at_every_load then
        pos_secondary_container.y = pos_secondary_container.y + 0.5
        formspec[#formspec + 1] = ('label[%f,%f;%s]'):format(pos_secondary_container.x, pos_secondary_container.y, 'Run at every load: ' .. (def.run_at_every_load and 'yes' or 'no'))
    end

    -- Biomes
    if def and dropdown_value == 'biomes' then
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list(def, pos_secondary_container)
    end

    -- Decorations
    if def and dropdown_value == 'decorations' then
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list(def, pos_secondary_container)
    end

    -- Ores
    if def and dropdown_value == 'ores' then
        -- Unordered list
        formspec[#formspec + 1] = get_unordered_list(def, pos_secondary_container)
    end

    -- Close secondary container
    formspec[#formspec + 1] = 'scroll_container_end[]'
    -- Add scrollbar to secondary container
    formspec[#formspec + 1] = ('scrollbaroptions[min=0;max=%d;smallstep=10;largestep=100;thumbsize=10;arrows=default]'):format(math.ceil(pos_secondary_container.y * 10))
    formspec[#formspec + 1] = ('scrollbar[%f,%f;0.15,9;vertical;everness_ency_detail_view_scrollbar;]'):format(pos_secondary.x + 5.5 + 0.15, pos_secondary.y)

    return formspec
end

function Everness.encyclopedia_i3_register_page(self)
    i3.new_tab('everness_encyclopedia', {
        description = 'Everness',
        image = 'everness_logo.png',
        slots = false,
        formspec = function(player, data, fs)
            local context = data or {}
            local formspec = self:encyclopedia_get_formspec(context)
            formspec = table.concat(formspec, '')
            fs(formspec)
        end,
        fields = function(player, data, fields)
            if fields.everness_ency_main_list then
                local main_list_event = minetest.explode_textlist_event(fields.everness_ency_main_list)

                -- Set context data
                if main_list_event.type == 'CHG' then
                    data.everness_ency_primary_selected_idx = main_list_event.index
                end
            elseif fields.everness_ency_dropdown then
                local prev_everness_ency_dropdown_idx = data.everness_ency_dropdown_idx
                local new_everness_ency_dropdown_idx = tonumber(fields.everness_ency_dropdown)
                data.everness_ency_dropdown_idx = new_everness_ency_dropdown_idx

                -- Change to 1st primary list item index only when changing dropdown
                if prev_everness_ency_dropdown_idx ~= new_everness_ency_dropdown_idx then
                    data.everness_ency_primary_selected_idx = 1
                end
            end
        end,
        access = function(player, data)
            return minetest.check_player_privs(player:get_player_name(), 'everness_encyclopedia')
        end,
    })
end

function Everness.encyclopedia_ui_register_page(self)
    unified_inventory.register_page('everness:encyclopedia', {
        get_formspec = function(player)
            local context = unified_inventory.everness_context[player:get_player_name()]
            local formspec = self:encyclopedia_get_formspec(context)

            return {
                formspec = table.concat(formspec, ''),
                draw_inventory = false,
                draw_item_list = false
            }
        end
    })

    minetest.register_on_joinplayer(function(player)
        local pname = player:get_player_name()

        unified_inventory.everness_context = {}
        unified_inventory.everness_context[pname] = {
            everness_ency_dropdown_idx = 1,
            everness_ency_primary_selected_idx = 1,
        }
    end)

    minetest.register_on_player_receive_fields(function(player, formname, fields)
        if formname ~= '' then
            return
        end

        local pname = player:get_player_name()

        if fields.everness_ency_main_list then
            local main_list_event = minetest.explode_textlist_event(fields.everness_ency_main_list)

            -- Set context data
            if main_list_event.type == 'CHG' then
                unified_inventory.everness_context[pname].everness_ency_primary_selected_idx = main_list_event.index
                unified_inventory.set_inventory_formspec(player, unified_inventory.current_page[pname])
            end
        elseif fields.everness_ency_dropdown then
            local prev_everness_ency_dropdown_idx = unified_inventory.everness_context[pname].everness_ency_dropdown_idx
            local new_everness_ency_dropdown_idx = tonumber(fields.everness_ency_dropdown)
            unified_inventory.everness_context[pname].everness_ency_dropdown_idx = new_everness_ency_dropdown_idx

            -- Change to 1st primary list item index only when changing dropdown
            if prev_everness_ency_dropdown_idx ~= new_everness_ency_dropdown_idx then
                unified_inventory.everness_context[pname].everness_ency_primary_selected_idx = 1
            end

            unified_inventory.set_inventory_formspec(player, unified_inventory.current_page[pname])
        end
    end)

    unified_inventory.register_button('everness:encyclopedia', {
        type = 'image',
        image = 'everness_logo.png',
        tooltip = 'Everness Encyclopedia',
        condition = function(player)
            return minetest.check_player_privs(player:get_player_name(), 'everness_encyclopedia')
        end,
        action = function(player)
            local pname = player:get_player_name()

            if not minetest.check_player_privs(pname, 'everness_encyclopedia') then
                minetest.chat_send_player(pname, S('You need "everness_encyclopedia" privilige to access this button.'))
                unified_inventory.set_inventory_formspec(player, unified_inventory.current_page[pname])
                return
            end

            unified_inventory.current_page[pname] = 'everness:encyclopedia'
            unified_inventory.set_inventory_formspec(player, unified_inventory.current_page[pname])
        end,
    })
end

function Everness.encyclopedia_sfinv_register_page(self)
    sfinv.register_page('everness:encyclopedia', {
        title = 'Everness',
        is_in_nav = function(_self, player, context)
            return minetest.check_player_privs(player:get_player_name(), 'everness_encyclopedia')
        end,
        get = function(_self, player, context)
            local formspec = self:encyclopedia_get_formspec(context)
            return sfinv.make_formspec(player, context, table.concat(formspec, ''))
        end,
        on_player_receive_fields = function (_self, player, context, fields)
            if fields.everness_ency_main_list then
                local main_list_event = minetest.explode_textlist_event(fields.everness_ency_main_list)

                -- Set context data
                if main_list_event.type == 'CHG' then
                    context.everness_ency_primary_selected_idx = main_list_event.index
                    sfinv.set_player_inventory_formspec(player)
                end
            end

            if fields.everness_ency_dropdown then
                local prev_everness_ency_dropdown_idx = context.everness_ency_dropdown_idx
                local new_everness_ency_dropdown_idx = tonumber(fields.everness_ency_dropdown)
                context.everness_ency_dropdown_idx = new_everness_ency_dropdown_idx

                -- Change to 1st primary list item index only when changing dropdown
                if prev_everness_ency_dropdown_idx ~= new_everness_ency_dropdown_idx then
                    context.everness_ency_primary_selected_idx = 1
                end

                sfinv.set_player_inventory_formspec(player)
            end
        end
    })
end

function Everness.find_content_in_vm_area(minp, maxp, contentIds, data, area)
    local indexes = {}
    local id_count = {}

    for y = minp.y, maxp.y do
        for z = minp.z, maxp.z do
            for x = minp.x, maxp.x do
                local ai = area:index(x, y, z)

                if table.indexof(contentIds, data[ai]) ~= -1 then
                    id_count[data[ai]] = (id_count[data[ai]] or 0) + 1
                    table.insert(indexes, ai)
                end
            end
        end
    end

    return indexes, id_count
end

function Everness.find_content_under_air_in_vm_area(minp, maxp, contentIds, data, area)
    local indexes = {}
    local id_count = {}

    for y = minp.y, maxp.y do
        for z = minp.z, maxp.z do
            for x = minp.x, maxp.x do
                local ai = area:index(x, y, z)

                if table.indexof(contentIds, data[ai]) ~= -1
                    and data[ai + area.ystride] == minetest.CONTENT_AIR
                then
                    id_count[data[ai]] = (id_count[data[ai]] or 0) + 1
                    table.insert(indexes, ai)
                end
            end
        end
    end

    return indexes, id_count
end


function Everness.add_to_queue_on_generated(self, def)
    if type(def) ~= 'table' then
        minetest.log('warning', '[add_to_queue_on_generated] Callback definition is not a table, not adding to queue! It was type of ' .. type(def))
        return
    end

    table.insert(self.on_generated_queue, def)
end

---Merge two tables with key/value pair
---@param t1 table
---@param t2 table
---@return table
function Everness.mergeTables(t1, t2)
    for k, v in pairs(t2) do t1[k] = v end
    return t1
end
