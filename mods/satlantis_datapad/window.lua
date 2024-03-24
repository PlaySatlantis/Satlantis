local window = {}

window.get_base_form = function()
    local time = minetest.get_timeofday()
    local hr = math.floor(time * 24)
    local min = math.floor(((time * 24) - hr) * 60)

    local os_meta = satlantis.datapad.os.metadata
    local infobar = "label[0.15,0.3;" .. hr .. ":" .. min .. "]" ..
                    "label[75w,0.3;" .. os_meta.name .." " .. os_meta.version .. "]"

    local actionbar = [[
        image_button[calc(20w-0.5),calc(100h-1);1,1;datapad_actionbar_off.png;off;;;false]
        image_button[calc(50w-0.5),calc(100h-1);1,1;datapad_actionbar_home.png;home;;;false]
        image_button[calc(80w-0.5),calc(100h-1);1,1;datapad_actionbar_back.png;back;;;false]
    ]]

    return [[
        formspec_version[7]
        size[8,16]
        no_prepend[]
        bgcolor[#00000000]

        background[-4,0;16,16;datapad_datapad_bg.png]
        container[0,0.4]
        %s
    ]] ..
        infobar ..
        actionbar ..
    [[
        container_end[]
    ]]
end

window.width = 8
window.height = 15.25

window.new = function(user)
    return setmetatable({
        _user = user,
        _app_id = "",
        _id = "",
        _formspec = "",
    }, {__index = window})
end

window._patterns = {
    {
        "([%d.]+)w", function(v)
            return tonumber(v) * 0.01 * window.width
        end,
    },
    {
        "([%d.]+)h", function(v)
            return tonumber(v) * 0.01 * window.height
        end,
    },
    {
        "calc%((.-)%)", function(v)
            return setfenv(loadstring("return " .. v), {})()
        end,
    },
}

window.build = function(form)
    local str = form

    for _, pair in ipairs(window._patterns) do
        str = str:gsub(pair[1], pair[2])
    end

    return str
end

window.set_form = function(self, form)
    self._formspec = form
end

window.get_form = function(self)
    return self._formspec
end

window.set_id = function(self, id)
    self._id = id
end

window.get_id = function(self)
    return self._id
end

window.show = function(self)
    local form = window.build(window.get_base_form():format(self._formspec))

    minetest.show_formspec(self._user, self._app_id .. ":" .. self._id, form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local device = satlantis.datapad.devices[name]

    if fields.off then
        return minetest.close_formspec(name, formname)
    elseif fields.home then
        return device:app_open("datapad:home")
    elseif fields.back then
        if #device._address_stack > 1 then
            device._address_stack[#device._address_stack] = nil

            local current = device._address_stack[#device._address_stack]

            device:app_open(current[1], current[2])
        end

        return
    end

    local parts = formname:split(":")

    if #parts >= 2 then
        local app_id = parts[1] .. ":" .. parts[2]
        local window_id = parts[3]

        satlantis.datapad.application_registry[app_id].on_event(player, fields, window_id, device._window, device)
    end
end)

return window
