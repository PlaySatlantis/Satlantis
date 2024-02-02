skyblock = {}

local storage = minetest.get_mod_storage()

local CEL_SIZE = 256
local CEL_PADDING = 256
local CEL_TOTAL_SIZE = CEL_SIZE + CEL_PADDING

local MAX_WIDTH = 60000
local GRID_WIDTH = math.floor(MAX_WIDTH / CEL_TOTAL_SIZE)
local GRID_VOLUME = GRID_WIDTH * GRID_WIDTH

local MIN_POS = vector.new(-30000, 30000 - CEL_TOTAL_SIZE, -30000)

minetest.register_node("skyblock:wall", {
    drawtype = "airlike",
    -- tiles = {"blank.png^[invert:rgba"},
    pointable = false,
    walkable = true,
    diggable = false,
    paramtype = "light",
    sunlight_propagates = true,
})

local CID_WALL = minetest.get_content_id("skyblock:wall")
local CID_PLATFORM = minetest.get_content_id("default:steelblock")
local PLATFORM_RADIUS = 3

skyblock.get_cel = function(id)
    if id >= GRID_VOLUME then return end

    local grid_x = id % GRID_WIDTH
    local grid_z = math.floor(id / GRID_WIDTH)

    local cel_pos = vector.new(grid_x * CEL_TOTAL_SIZE, 0, grid_z * CEL_TOTAL_SIZE)
    local cel_center = cel_pos + vector.new(CEL_TOTAL_SIZE / 2, CEL_TOTAL_SIZE / 2, CEL_TOTAL_SIZE / 2):floor()
    local cel_padded = cel_pos + vector.new(CEL_PADDING / 2, CEL_PADDING / 2, CEL_PADDING / 2)

    return {
        pos = MIN_POS + cel_pos,
        center = MIN_POS + cel_center,
        bounds = {
            min = MIN_POS + cel_padded,
            max = MIN_POS + cel_padded + vector.new(CEL_SIZE - 1, CEL_SIZE - 1, CEL_SIZE - 1)
        }
    }
end

local function generate_cuboid(pos1, pos2, content_id, vm)
    local data = vm:get_data()

    local va = VoxelArea(vm:get_emerged_area())
    for idx in va:iterp(pos1, pos2) do
        data[idx] = content_id
    end

    vm:set_data(data)

    collectgarbage("collect")
    return vm
end

local function async_generate_cuboid(pos1, pos2, content_id, callback)
    local vmanip = minetest.get_voxel_manip(pos1, pos2)
    minetest.handle_async(generate_cuboid, function(vm)
        vm:write_to_map(true)
        collectgarbage("collect")
        callback()
    end, pos1, pos2, content_id, vmanip)
end

skyblock.generate_cel = function(id, callback)
    local cel = skyblock.get_cel(id)

    local min = cel.bounds.min - vector.new(1, 1, 1)
    local max = cel.bounds.max + vector.new(1, 1, 1)
    local width = CEL_SIZE + 1

    local plat_min = cel.center - vector.new(PLATFORM_RADIUS - 1, 0, PLATFORM_RADIUS - 1)
    local plat_max = cel.center + vector.new(PLATFORM_RADIUS, 0, PLATFORM_RADIUS)

    local steps = {
        {min, min + vector.new(width, width, 0), CID_WALL},
        {min, min + vector.new(0, width, width), CID_WALL},
        {min + vector.new(0, 0, width), max, CID_WALL},
        {min + vector.new(0, width, 0), max, CID_WALL},
        {min + vector.new(width, 0, 0), max, CID_WALL},
        {plat_min, plat_max, CID_PLATFORM},
    }

    local progress = #steps
    for _, step in pairs(steps) do
        async_generate_cuboid(step[1], step[2], step[3], function()
            progress = progress - 1
            if progress == 0 then
                callback(cel)
            end
        end)
    end
end

local cel_cache = {}

skyblock.get_player_cel = function(name)
    if not cel_cache[name] then
        local id = tonumber(storage:get_string(name))
        if id then
            cel_cache[name] = skyblock.get_cel(id)
        end
    end

    return cel_cache[name]
end

skyblock.set_home = function(player, pos)
    player:get_meta():set_string("skyblock:home", minetest.pos_to_string(pos, 2))
end

skyblock.set_default_home = function(player)
    skyblock.set_home(player, skyblock.get_player_cel(player:get_player_name()).center + vector.new(0.5, 1, 0.5))
end

skyblock.get_home = function(player)
    local meta = player:get_meta()
    local home = meta:get_string("skyblock:home")
    if home == "" then
        skyblock.set_default_home(player)
        home = meta:get_string("skyblock:home")
    end

    return minetest.string_to_pos(home)
end

skyblock.allocate_cel = function(name, callback)
    local player = minetest.get_player_by_name(name)
    if not player then return end

    local existing = skyblock.get_player_cel(name)
    if existing then return existing end

    local id = storage:get_int("next_cel")
    storage:set_int("next_cel", id + 1)

    print(id)

    skyblock.generate_cel(id, function(cel)
        storage:set_string(name, tostring(id))
        storage:set_string(tostring(id), name)

        skyblock.set_default_home(player)

        callback(cel)
    end)
end

skyblock.current_players = {}

skyblock.is_in_skyblock = function(name)
    return skyblock.current_players[name]
end

skyblock.enter_cel = function(name)
    local player = minetest.get_player_by_name(name)
    if player and skyblock.get_player_cel(name) then
        player:get_meta():set_int("skyblock:in_skyblock", 1)
        player:set_pos(skyblock.get_home(player))
        skyblock.current_players[name] = true
    end
end

skyblock.exit_cel = function(name, pos)
    local player = minetest.get_player_by_name(name)
    if player then
        player:get_meta():set_int("skyblock:in_skyblock", 0)
        player:set_pos(pos)
    end

    skyblock.current_players[name] = nil
end

skyblock.pos_in_bounds = function(pos, min, max)
    if pos.x < min.x or pos.x > max.x or
       pos.y < min.y or pos.y > max.y or
       pos.z < min.z or pos.z > max.z then
        return false
    end

    return true
end

skyblock.handle_bounds = function(player)
    local cel = skyblock.get_player_cel(player:get_player_name())
    if not cel then return end

    local min = cel.bounds.min - vector.new(1, 1.5, 1)
    local max = cel.bounds.max + vector.new(1, -0.5, 1)

    if not skyblock.pos_in_bounds(player:get_pos(), min, max) then
        player:set_pos(skyblock.get_home(player))
    end
end

local old_is_protected = minetest.is_protected

minetest.is_protected = function(pos, name)
    if pos.y >= MIN_POS.y then
        if not minetest.get_player_privs(name).protection_bypass then
            local cel = skyblock.get_player_cel(name)
            if cel and not skyblock.pos_in_bounds(pos, cel.bounds.min, cel.bounds.max) then
                return true
            end
        end
    end

    return old_is_protected(pos, name)
end

local interval = 0.5
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= interval then
        while timer > interval do
            timer = timer - interval
        end

        for name in pairs(skyblock.current_players) do
            local player = minetest.get_player_by_name(name)
            skyblock.handle_bounds(player)
        end
    end
end)

minetest.register_on_joinplayer(function(player)
    if player:get_meta():get_int("skyblock:in_skyblock") > 0 then
        skyblock.current_players[player:get_player_name()] = true
    end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()

    skyblock.current_players[name] = nil
    cel_cache[name] = nil
end)

-- Player commands
minetest.register_chatcommand("skyblock", {
    func = function(name, param)
        if param == "set" then
            if skyblock.current_players[name] then
                local player = minetest.get_player_by_name(name)
                local pos = player:get_pos()
                skyblock.set_home(player, pos)
                return true, "Set orbiter origin to " .. minetest.pos_to_string(pos, 2)
            else
                return false, "Can only set home origin within orbiter area."
            end
        else
            if skyblock.get_player_cel(name) then
                skyblock.enter_cel(name)
                return true, "Transported to orbiter."
            else
                skyblock.allocate_cel(name, function()
                    skyblock.enter_cel(name)
                    minetest.chat_send_player(name, "Transported to orbiter.")
                end)
                return true, "Generating new orbiter..."
            end
        end
    end,
})

minetest.registered_chatcommands["home"] = minetest.registered_chatcommands["skyblock"]
minetest.registered_chatcommands["orbiter"] = minetest.registered_chatcommands["skyblock"]

-- Dev/admin commands
minetest.register_chatcommand("genskyblock", {
    privs = {server = true},
    func = function(name, param)
        local now = minetest.get_us_time()
        skyblock.generate_cel(tonumber(param), function()
            minetest.chat_send_player(name, "Generated orbiter (" .. ((minetest.get_us_time() - now) / 1000000) .. "s)")
        end)

        return true, "Generating orbiter..."
    end,
})

minetest.register_chatcommand("exitskyblock", {
    privs = {server = true},
    func = function(name, param)
        skyblock.exit_cel(name, minetest.string_to_pos(param))
    end,
})
