-- Localize Hunger NG
local a = hunger_ng.attributes
local c = hunger_ng.configuration
local e = hunger_ng.effects
local f = hunger_ng.functions
local s = hunger_ng.settings
local S = hunger_ng.configuration.translator


-- Localize Minetest
local registered_items = minetest.registered_items


-- Add custom _hunger_ng attribute to items
--
-- Checks if the item already has the attribute. If not, then the provided
-- values are set.
--
-- The data table has to be the following.
--
--     {
--         heals = n,
--         satiates = n,
--         returns = 'id'
--     }
--
-- Where n is a number (can be negative to damage the player or make the
-- player hungry) or a fraction of a number. If `returns` is set to an ID of
-- a registered item this item will be returned when the food is eaten.
--
-- @param id   The ID of the item to be modified.
-- @param data The data table as described
hunger_ng.functions.add_hunger_data = function (id, data)
    if registered_items[id] == nil then return end
    if registered_items[id]._hunger_ng ~= nil then return end
    if registered_items[id].on_use == nil then return end

    local item_data = registered_items[id]
    local info = ''
    local satiates = data.satiates or 0
    local heals = data.heals or 0
    local returns = data.returns or false
    local timeout = data.timeout or s.hunger.timeout

    if satiates > 0 then
        info = info..'\n'..S('Satiates: @1', satiates)
        hunger_ng.food_items.satiating = hunger_ng.food_items.satiating + 1
    elseif satiates < 0 then
        info = info..'\n'..S('Deprives: @1', math.abs(satiates))
        hunger_ng.food_items.starving = hunger_ng.food_items.starving + 1
    end

    if heals > 0 then
        info = info..'\n'..S('Heals: @1', data.heals)
        hunger_ng.food_items.healing = hunger_ng.food_items.healing + 1
    elseif heals < 0 then
        info = info..'\n'..S('Injures: @1', math.abs(heals))
        hunger_ng.food_items.injuring = hunger_ng.food_items.injuring + 1
    end

    if returns and registered_items[returns] then
        local return_name = registered_items[returns].description
        info = info..'\n'..S('Returns: @1', return_name)
    end

    if data.returns and not registered_items[returns] then
        data.returns = nil
    end

    if timeout > 0 then
        info = info..'\n'..S('Eating timeout: @1 seconds', timeout)
    end

    minetest.override_item(id, {
        description = item_data.description..info,
        _hunger_ng = data
    })
end
