-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator


-- Localize Minetest
local get_modpath = minetest.get_modpath
local get_dir_list = minetest.get_dir_list
local log = minetest.log

-- Load needed data
local mod_path = minetest.get_modpath('hunger_ng')
local i14y_path = mod_path..DIR_DELIM..'interoperability'..DIR_DELIM

-- Load interoperability file when the corresponding mod was loaded
minetest.register_on_mods_loaded(function()
    for _,i14y_file in pairs(get_dir_list(i14y_path)) do
        local modname = i14y_file:gsub('%..*', '')
        if get_modpath(modname) and i14y_file ~= 'README.md' then
            dofile(i14y_path..i14y_file)
            log('info', c.log_prefix..'Loaded built-in '..modname..' support')
        end
    end

    if hunger_ng.food_items.satiating == 0 then
        local message = {
            'There are NO satiating food items registered!',
            'Hunger is disabled!',
            'Enable at least one of the supported mods.'
        }
        minetest.log('warning', '[hunger_ng] '..table.concat(message, ' '))
    end
end)
