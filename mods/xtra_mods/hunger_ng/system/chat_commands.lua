-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator


-- Localize Minetest
local chat_send = minetest.chat_send_player
local log = minetest.log
local player_exists = minetest.player_exists


-- Set hunger to given value
--
-- Sets the hunger of the given player to the given value. If the player name
-- is omitted own hunger is set.
--
-- @param name   The name of the target player
-- @param value  The hunger value to set to
-- @param caller The player who invoked the command
-- @return mixed `void` if player exists, otherwise `nil`
local set_hunger = function (name, value, caller)
    local message = ''

    if not minetest.get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.hunger_disabled(name) then
        chat_send(caller, S('Hunger for @1 is disabled', name))
        return
    end

    if value > s.hunger.maximum then value = s.hunger.maximum end
    if value < 0 then value = 0 end

    f.alter_hunger(name, -s.hunger.maximum, 'chat set 0')
    f.alter_hunger(name, value, 'chat set target')

    if name ~= caller then
        chat_send(caller, S('Hunger for @1 set to @2', name, value))
        chat_send(name, S('@1 set your hunger to @2', caller, value))
        message = caller..' sets hunger for '..name..' to '..value
    else
        chat_send(caller, S('Hunger set to @1', value))
        message = caller..' sets own hunger to '..value
    end

    log('action', '[hunger_ng] '..message)
end


-- Change the hunger value
--
-- Changes the hunger value of the given player by the given value. Use
-- negative values to substract hunger. If the player name is omitted the own
-- hunger gets changed.
--
-- @param name   The name of the target player
-- @param value  The hunger value to change by
-- @param caller The player who invoked the command
-- @return mixed `void` if player exists, otherwise `nil`
local change_hunger = function (name, value, caller)
    local message = ''

    if not minetest.get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.hunger_disabled(name) then
        chat_send(caller, S('Hunger for @1 is disabled', name))
        return
    end

    if value > s.hunger.maximum then value = s.hunger.maximum end
    if value < -s.hunger.maximum then value = -s.hunger.maximum end

    f.alter_hunger(name, value, 'chat change')

    if name ~= caller then
        chat_send(caller, S('Hunger for @1 changed by @2', name, value))
        chat_send(name, S('@1 changed your hunger by @2', caller, value))
        message = caller..'changes hunger for '..name..' by '..value
    else
        chat_send(caller, S('Hunger changed by @1', value))
        message = caller..' changes own hunger by '..value
    end

    log('action', '[hunger_ng] '..message)
end


-- Toggle hunger being enabled
--
-- Toggles the hunger for the given player from enabled to disabled.
--
-- @param name   The name of the target player
-- @param caller The player who invoked the command
-- @return mixed `void` if player exists, otherwise `nil`
local toggle_hunger = function (name, value, caller)
    local message = ''
    local action = ''
    local name = name == '' and caller or name

    if not minetest.get_player_by_name(name) then
        chat_send(caller, S('The player @1 is not online', name))
        return
    end

    if f.hunger_disabled(name) then
        hunger_ng.configure_hunger(name, 'enable')
        action = 'enabled'
    else
        hunger_ng.configure_hunger(name, 'disable')
        action = 'disabled'
    end

    if name ~= caller then
        chat_send(caller, S('Hunger for @1 was toggled', name))
        chat_send(name, S('@1 toggled your hunger', caller))
        message = caller..' '..action..' hunger for '..name
    else
        chat_send(caller, S('Own hunger was toggled'))
        message = caller..' '..action..' own hunger'
    end

    log('action', '[hunger_ng] '..message)
end


-- Get the hunger value
--
-- When called without name parameter it gets the hunger values from all
-- currently connected players. If a name is given the hunger value for that
-- player is returned if the player is online
--
-- @param name   The name of the target player
-- @param caller The player who invoked the command
-- @return void
local get_hunger = function(name, caller)
    local message = ''

    if name == '' then name = minetest.get_connected_players()
    else name = { minetest.get_player_by_name(name) } end

    for _,player in pairs(name) do
        if player:is_player() then
            local player_name = player:get_player_name()
            local player_hunger = f.get_data(player_name, a.hunger_value)
            local hunger_disabled = f.hunger_disabled(player_name)

            if not hunger_disabled then
                chat_send(caller, player_name..': '..player_hunger)
            else
                chat_send(caller, player_name..': '..S('Hunger is disabled'))
            end

            if player_name == caller then
                message = caller..' gets own hunger value'
            else
                message = caller..' gets hunger value for '..player_name
            end

            log('action', '[hunger_ng] '..message)
        end
    end

    if #name == 0 then
        chat_send(caller, S('No player matches your criteria'))
    end
end


-- Show the help message
--
-- Shows the help message to the caller
--
-- @param caller The player who invoked the command
-- @return void
local show_help = function (caller)
    chat_send(caller, S('run `/help hunger` to show help'))
end


-- Register privilege for hunger control
minetest.register_privilege('manage_hunger', {
    description = S('Player can view and alter own and others hunger values.')
})


-- Administrative chat command definition
minetest.register_chatcommand('hunger', {
    params = '<set/change/get/toggle> <name> <value>',
    description = S('Modify or get hunger values'),
    privs = { manage_hunger = true },
    func = function (caller, parameters)
        local pt= {}
        for p in parameters:gmatch("%S+") do table.insert(pt, p) end
        local action = pt[1] or ''
        local name = pt[2] or ''
        local value = pt[3] or ''

        -- Name parameter missing
        if not player_exists(name) and tonumber(name) and value == '' then
            value = name
            name = caller
        end

        -- Convert value to number or print error message when trying to set
        -- a value but no proper value was given
        if tonumber(value) then
            value = tonumber(value)
        else
            if action ~= 'get' and action ~= 'toggle' then
                show_help(caller)
                return
            end
        end

        -- Execute the corresponding function for the defined action
        if     action == 'set' then set_hunger(name, value, caller)
        elseif action == 'change' then change_hunger(name, value, caller)
        elseif action == 'get' then get_hunger(name, caller)
        elseif action == 'toggle' then toggle_hunger(name, value, caller)
        else show_help(caller) end
    end
})


-- Personal information chat command
minetest.register_chatcommand('myhunger', {
    params = 'name',
    description = S('Show own hunger value'),
    privs = { interact = true },
    func = function (caller)
        local player_hunger = f.get_data(caller, a.hunger_value)
        local hunger_disabled = f.hunger_disabled(caller)
        if hunger_disabled then
            chat_send(caller, S('Your hunger is disabled'))
        else
            chat_send(caller, S('Your hunger value is @1', player_hunger))
        end
    end
})

