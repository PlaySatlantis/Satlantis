local datapad = satlantis.datapad
local app = {}

app.metadata = {
    id = "datapad:home",
    name = "Home",
    version = "0.1",
    show_on_home = false,
}

-- function(address?, window, device)
app.open = function(_, window, _)
    local form = [[
        image[0,0;100w,100h;datapad_home_bg.png]
    ]]

    local i = 0
    for _, a in pairs(datapad.application_registry) do
        if a.metadata.show_on_home ~= false then
            local gx, gy = i % 4, math.floor(i / 4)
            local x, y = gx * 20, gy * 25

            form = form .. "image_button[calc(5w+" .. x .. "w+7.5w),calc(10h+" .. y .. "w+7.5w);15w,15w;" .. a.metadata.icon .. ";open_" .. a.metadata.id .. ";;;false]"
            form = form .. "hypertext[calc(10w+" .. x .. "w),calc(10h+1.2+" .. y .. "w+7.5w);20w,5h;;<center>" .. a.metadata.name .. "</center>]"

            i = i + 1
        end
    end

    window:set_form(form)

    window:show()
end

app.on_event = function(_, fields, _, _, device)
    for field in pairs(fields) do
        if field:sub(1, 5) == "open_" then
            local app_id = field:sub(6)
            device:app_open(app_id)
        end
    end
end

datapad.register_app(app)
