satlantis.datapad = {}
local datapad = satlantis.datapad

--[[

A digital device for various applications and personal functions.
Apps may be registered on the device for various services.
Like a smartphone. It's a smartphone.

]]--

datapad.MODPATH = minetest.get_modpath(minetest.get_current_modname())

-- User data will be stored in a standalone database with the phone as an access point
datapad.storage = minetest.get_mod_storage()

datapad.application_registry = {}

datapad.register_app = function(app)
    datapad.application_registry[app.metadata.id] = setmetatable(app, {
        __index = {}
    })
end

-- Application interface
datapad.os = {
    metadata = {
        name = "Trident OS",
        version = "0.1",
    },
}

datapad.os.window = dofile(datapad.MODPATH .. "/window.lua")

datapad.os.new = function(user)
    return setmetatable({
        _user = user,
        _window = datapad.os.window.new(user),
        _address_stack = {{"datapad:home"}},
    }, {
        __index = datapad.os,
    })
end

datapad.os.app_open = function(self, app_id, address)
    local app = datapad.application_registry[app_id]
    local current = self._address_stack[#self._address_stack]

    self._window._app_id = app_id

    if not (current[1] == app_id and current[2] == address) then
        table.insert(self._address_stack, {app_id, address})
    end

    app.open(address, self._window, self)
end

datapad.os.show = function(self)
    local current = self._address_stack[#self._address_stack]

    self:app_open(current[1], current[2])
end

-- Currently active devices during runtime
datapad.devices = {}

datapad.new_device = function(user)
    datapad.devices[user] = datapad.os.new(user)

    return datapad.devices[user]
end

-- Home app
dofile(datapad.MODPATH .. "/app_home.lua")

minetest.register_on_joinplayer(function(player)
    datapad.new_device(player:get_player_name())
end)

-- Command
minetest.register_chatcommand("dp", {
    func = function(name)
        datapad.devices[name]:show()
    end
})
