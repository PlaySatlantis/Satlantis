satlantis.beacon = {}
local beacon = satlantis.beacon

beacon.colors = {
    "red", "darkorange", "yellow", "lime", "green",
    "aqua", "blue", "purple", "pink", "magenta",
    "saddlebrown", "gray", "darkgray", "#222222",
}

minetest.register_entity(":beacon:beam", {
    initial_properties = {
        visual = "mesh",
        mesh = "beacon_beam.obj",
        textures = {"beacon_beam.png"},
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
            self.object:set_properties({textures = {"beacon_beam.png"}})
        else
            local color = beacon.colors[colorid]
            self.object:set_properties({textures = {"beacon_beam.png^[multiply:" .. color}})
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

function beacon.set_beacon_color(pos, color)
    for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
        if not o:is_player() and o:get_luaentity().name == "beacon:beam" then
            o:get_luaentity():_set_color(color)
            minetest.get_meta(pos):set_string("beam_color", color)

            return
        end
    end

    minetest.add_entity(vector.new(pos.x, pos.y + 0.5, pos.z), "beacon:beam", color)
end

function beacon.rotate_beacon_color(pos, direction)
    local current_color = tonumber(minetest.get_meta(pos):get_string("beam_color")) or 0
    beacon.set_beacon_color(pos, (current_color + direction) % (#beacon.colors + 1))
end

minetest.register_node(":beacon:beacon", {
    description = "Beacon",
    tiles = {"blank.png^[invert:rgba^[colorize:aqua:255"},
    groups = {cracky = 1, oddly_breakable_by_hand = 1},
    after_place_node = function(pos)
        minetest.add_entity(vector.new(pos.x, pos.y + 0.5, pos.z), "beacon:beam", "0")
        minetest.get_meta(pos):set_string("beam_color", "0")
    end,
    after_dig_node = function(pos)
        for _, o in pairs(minetest.get_objects_inside_radius(pos, 1)) do
            if not o:is_player() and o:get_luaentity().name == "beacon:beam" then
                o:remove()
            end
        end
    end,
    on_punch = function(pos)
        beacon.rotate_beacon_color(pos, 1)
    end,
    on_rightclick = function(pos)
        beacon.rotate_beacon_color(pos, -1)
    end,
})

minetest.register_lbm({
    label = "star beacons",
    name = ":beacon:beam",
    run_at_every_load = true,
    nodenames = {"beacon:beacon"},
    action = function(pos)
        beacon.rotate_beacon_color(pos, 0)
    end,
})
