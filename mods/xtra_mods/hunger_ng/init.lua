-- Exit if damage is not enabled and create dummy functions so mods using the
-- API do not crash the server.
if not minetest.is_yes(minetest.settings:get('enable_damage')) then
    local info = 'Hunger NG is disabled because damage is disabled.'

    local call = function (function_name)
        minetest.log('warning', ('+m tried to use +f but +i'):gsub('%+%a+', {
            ['+m'] = minetest.get_current_modname(),
            ['+f'] = 'hunger_ng.'..function_name..'()',
            ['+i'] = info
        }))
    end

    hunger_ng = {
        add_hunger_data = function () call('add_hunger_data') end,
        alter_hunger = function () call('alter_hunger') end,
        configure_hunger = function () call('configure_hunger') end,
        get_hunger_information = function () call('get_hunger_information') end,
        hunger_bar_image = '',
        interoperability = {
            settings = {},
            attributes = {},
            translator = function () call('interoperability.translator') end,
            get_data = function () call('interoperability.get_data') end,
            set_data = function () call('interoperability.set_data') end,
        }
    }

    minetest.log('info', '[hunger_ng] '..info)
    return
end


-- Paths for later use
local modpath = minetest.get_modpath('hunger_ng')..DIR_DELIM
local worldpath = minetest.get_worldpath()..DIR_DELIM
local configpath = worldpath..'_hunger_ng'..DIR_DELIM..'hunger_ng_settings.conf'


-- World-specific configuration interface for use in the get function
local worldconfig = Settings(configpath)


-- Wrapper for getting configuration options
--
-- The function automatically prefixes the given setting with `hunger_ng_` and
-- returns the requested setting from one of the three sources.
--
-- 1. world-specific `./worlds/worldname/_hunger_ng/hunger_ng.conf` file
-- 2. default `minetest.conf` file
-- 3. the given default value
--
-- If 1. is found then it will be returned from there. If 2. is found then it
-- will be returned from there and after that it will be returned using 3.
--
-- @param setting The unprefixed setting name
-- @param default The default value if the setting is not found
-- @return string The value for the requested setting
local get = function (setting, default)
    local parameter = 'hunger_ng_'..setting
    local global_setting =  minetest.settings:get(parameter)
    local world_specific_setting = worldconfig:get(parameter)
    return world_specific_setting or global_setting or default
end


-- Global hunger_ng table that will be used to pass around variables and use
-- them later in the game. The table is not to be used by mods. Mods should
-- only use the interoperability functionality. This table is for internal
-- use only.
hunger_ng = {
    functions = {},
    food_items = {
        satiating = 0,
        starving = 0,
        healing = 0,
        injuring = 0,
    },
    attributes = {
        hunger_bar_id = 'hunger_ng:hunger_bar_id',
        hunger_value = 'hunger_ng:hunger_value',
        eating_timestamp = 'hunger_ng:eating_timestamp',
        hunger_disabled = 'hunger_ng:hunger_disabled',
        effect_heal = 'hunger_ng:effect_heal',
        effect_hunger = 'hunger_ng:effect_hunger',
        effect_starve = 'hunger_ng:effect_starve'
    },
    configuration = {
        debug_mode = minetest.is_yes(get('debug_mode', false)),
        log_prefix = '[hunger_ng] ',
        translator = minetest.get_translator('hunger_ng')
    },
    settings = {
        hunger_bar = {
            image = get('hunger_bar_image', 'hunger_ng_builtin_bread_icon.png'),
            use = minetest.is_yes(get('use_hunger_bar', true)),
            force_builtin_image = get('force_builtin_image', false),
        },
        timers = {
            heal = tonumber(get('timer_heal', 5)),
            starve = tonumber(get('timer_starve', 10)),
            basal_metabolism = tonumber(get('timer_basal_metabolism', 60)),
            movement = tonumber(get('timer_movement', 0.5))
        },
        hunger = {
            timeout = tonumber(get('hunger_timeout', 0)),
            persistent = minetest.is_yes(get('hunger_persistent', true)),
            start_with = tonumber(get('hunger_start_with', 20)),
            maximum = tonumber(get('hunger_maximum', 20))
        }
    },
    effects = {
        heal = {
            above = tonumber(get('heal_above', 16)),
            amount = tonumber(get('heal_amount', 1)),
        },
        starve = {
            below = tonumber(get('starve_below', 1)),
            amount = tonumber(get('starve_amount', 1)),
            die = minetest.is_yes(get('starve_die', false))
        },
        disabled_attribute = 'hunger_ng:hunger_disabled'
    },
    costs = {
        base = tonumber(get('cost_base', 0.1)),
        dig = tonumber(get('cost_dig', 0.005)),
        place = tonumber(get('cost_place', 0.01)),
        movement = tonumber(get('cost_movement', 0.008))
    }
}


-- Load mod parts
dofile(modpath..'system'..DIR_DELIM..'hunger_functions.lua')
dofile(modpath..'system'..DIR_DELIM..'chat_commands.lua')
dofile(modpath..'system'..DIR_DELIM..'timers.lua')
dofile(modpath..'system'..DIR_DELIM..'register_on.lua')
dofile(modpath..'system'..DIR_DELIM..'add_hunger_data.lua')
dofile(modpath..'system'..DIR_DELIM..'interoperability.lua')


-- Log debug mode warning
if hunger_ng.configuration.debug_mode then
    local log_prefix = hunger_ng.configuration.log_prefix
    minetest.log('warning', log_prefix..'Mod loaded with debug mode enabled!')
end


-- Replace the global table used for easy variable access within the mod with
-- an API-like global table for other mods to utilize.
local api_functions = {
    add_hunger_data = hunger_ng.functions.add_hunger_data,
    alter_hunger = hunger_ng.functions.alter_hunger,
    configure_hunger = hunger_ng.functions.configure_hunger,
    set_effect = hunger_ng.set_effect,
    get_hunger_information = hunger_ng.functions.get_hunger_information,
    hunger_bar_image = hunger_ng.settings.hunger_bar.image,
    food_items = hunger_ng.food_items,
    interoperability = {
        settings = hunger_ng.settings,
        attributes = hunger_ng.attributes,
        translator = hunger_ng.configuration.translator,
        get_data = hunger_ng.functions.get_data,
        set_data = hunger_ng.functions.set_data
    }
}


-- Replace the internal global table with the api functions
hunger_ng = api_functions
