satlantis.map = {}

satlantis.map.config = {
    spawn = satlantis.config:get("spawn") or vector.new(0, 0, 0)
}

satlantis.require("mapgen.lua")

minetest.register_chatcommand("setspawn", {
    privs = {
        server = true,
    },
    func = function(name, param)
        if param:len() > 0 then
            satlantis.map.config.spawn = minetest.string_to_pos(param)
        else
            satlantis.map.config.spawn = minetest.get_player_by_name(name):get_pos()
        end

        if satlantis.config:set("spawn", satlantis.map.config.spawn) then
            return true, "Spawn set"
        end

        return false, "Updating " .. satlantis.config._path .. " failed"
    end,
})
