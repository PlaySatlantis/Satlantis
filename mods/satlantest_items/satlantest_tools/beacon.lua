local colors = {
    "red", "darkorange", "yellow", "lime", "green",
    "aqua", "blue", "purple", "pink", "magenta",
    "saddlebrown", "gray", "darkgray", "#222222",
}

satlantis.register_entity("tools:beacon", {
    initial_properties = {
        visual = "mesh",
        mesh = "beacon_beam.obj",
        textures = {"beacon_beam_blue.png"},
        visual_size = vector.new(1 * 10, 256 * 10, 1 * 10),
        automatic_rotate = 2,
        glow = 15,
        physical = false,
        pointable = false,
    },
    _set_color = function(self, colorid)
        colorid = tonumber(colorid)
        if not colorid or colorid == 0 then
            colorid = 0
            self.object:set_properties({textures = {"beacon_beam_blue.png"}})
        else
            local color = colors[colorid]
            self.object:set_properties({textures = {"beacon_beam_blue.png^[multiply:" .. color}})
        end

        self._color = tostring(colorid)
    end,
    on_activate = function(self, colorid)
        self:_set_color(colorid)
    end,
    get_staticdata = function(self)
        return self._color
    end,
})

local function change_beacon_color(pos, direction)
    local meta = minetest.get_meta(pos)
    local current_color = meta:get_string("beam_color")

    for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
        if o:get_luaentity().name == "tools:beacon" then
            local color = (tonumber(current_color) + direction) % (#colors + 1)
            o:get_luaentity():_set_color(color)
            meta:set_string("beam_color", color)

            return
        end
    end

    minetest.add_entity(vector.new(pos.x, pos.y + 0.5, pos.z), "tools:beacon", current_color)
end

satlantis.register_block("tools:beacon", {
    description = "Beacon",
    tiles = {"blank.png^[invert:rgba^[colorize:aqua:255"},
    groups = {cracky = 1, oddly_breakable_by_hand = 1},
    after_place_node = function(pos)
        minetest.add_entity(vector.new(pos.x, pos.y + 0.5, pos.z), "tools:beacon", "0")
        minetest.get_meta(pos):set_string("beam_color", "0")
    end,
    after_dig_node = function(pos)
        for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
            if o:get_luaentity().name == "tools:beacon" then
                o:remove()
            end
        end
    end,
    on_punch = function(pos)
        change_beacon_color(pos, 1)
    end,
    on_rightclick = function(pos)
        change_beacon_color(pos, -1)
    end,
})
