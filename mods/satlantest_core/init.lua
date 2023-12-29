assert(not minetest.is_singleplayer(), "\n____________________\n\nMULTIPLAYER ONLY\n____________________\n")

satlantis = {}

satlantis._PATH = minetest.get_worldpath() .. "/satlantis" -- Satlantis data directory
minetest.mkdir(satlantis._PATH)

satlantis._CONFIG_PATH = satlantis._PATH .. "/config" -- Satlantis configuration files
minetest.mkdir(satlantis._CONFIG_PATH)

local metatable_JSONConfig = {
    set = function(self, key, value)
        assert(type(key) == "string" or (type(key) == "number" and key > 0))
        rawget(self, "_data")[key] = value
        return minetest.safe_file_write(self._path, minetest.write_json(self._data, true))
    end,
    get = function(self, key)
        return rawget(self, "_data")[key]
    end,
}

satlantis.JSONConfig = function(name)
    local config = {}
    config._path = satlantis._CONFIG_PATH .. "/" .. name

    local json = "{}"
    local f = io.open(config._path, "r")
    if f then
        local content = f:read("*a")
        f:close()

        if content:len() > 0 then
            json = content
        end
    end

    config._data = minetest.parse_json(json)

    return setmetatable(config, {
        __index = metatable_JSONConfig,
    })
end

satlantis.config = satlantis.JSONConfig("config.json")
