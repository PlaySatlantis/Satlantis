-- Callbacks for entities
satlantis.entity_callbacks = {
    on_death = {},
    on_punch = {},
    on_activate = {},
    on_deactivate = {},
}

satlantis.register_on_entity_death = function(callback) table.insert(satlantis.entity_callbacks.on_death, callback) end
satlantis.register_on_entity_punch = function(callback) table.insert(satlantis.entity_callbacks.on_punch, callback) end
satlantis.register_on_entity_activate = function(callback) table.insert(satlantis.entity_callbacks.on_activate, callback) end
satlantis.register_on_entity_deactivate = function(callback) table.insert(satlantis.entity_callbacks.on_deactivate, callback) end

local do_callbacks = function(name)
    return function(...)
        for _, callback in pairs(satlantis.entity_callbacks[name]) do
            callback(...)
        end
    end
end

local nofunc = function() end

local wrap_callback = function(original, wrapper)
    return function(...)
        wrapper(...)
        return (original or nofunc)(...)
    end
end

satlantis.register_entity = function(name, definition)
    definition.on_death = wrap_callback(definition.on_death, do_callbacks("on_death"))
    definition.on_punch = wrap_callback(definition.on_punch, do_callbacks("on_punch"))
    definition.on_activate = wrap_callback(definition.on_activate, do_callbacks("on_activate"))
    definition.on_deactivate = wrap_callback(definition.on_deactivate, do_callbacks("on_deactivate"))

    return minetest.register_entity(":" .. name, definition)
end
