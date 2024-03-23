local storage = minetest.get_mod_storage()
local lobby_pos = minetest.string_to_pos(storage:get("lobby_pos") or "0,0,0")
local skyblock, space = satlantis.skyblock, satlantis.space

minetest.register_chatcommand("lobby", {
    func = function(name, param)
        local player = minetest.get_player_by_name(name)

        if param ~= "" and minetest.get_player_privs(name).server then
            if minetest.global_exists("skyblock") then
                if skyblock.is_in_skyblock(name) then
                    return false, "Cannot set spawn inside orbiter"
                end
            end

            local params = param:split(" ", nil, 1)
            if params[1] == "set" then
                local pos
                if params[2] == "here" then
                    pos = player:get_pos()
                else
                    pos = minetest.string_to_pos(params[2])
                end

                if pos then
                    lobby_pos = pos

                    local str_pos = minetest.pos_to_string(pos, 2)
                    storage:set_string("lobby_pos", str_pos)

                    return true, "Set lobby spawn position to " .. str_pos
                else
                    return false, "Failed to parse position"
                end
            end
        else
            if minetest.global_exists("skyblock") then
                if skyblock.is_in_skyblock(name) then
                    skyblock.exit_cel(name, lobby_pos)
                    return true, "Transporting to lobby..."
                end
            end

            player:set_pos(lobby_pos)
            return true, "Transporting to lobby..."
        end
    end,
})

minetest.registered_chatcommands["spawn"] = minetest.registered_chatcommands["lobby"]

local old_is_protected = minetest.is_protected

minetest.is_protected = function(pos, name)
    if pos.y >= 20000 and pos.y <= 25000 then
        if not minetest.get_player_privs(name).protection_bypass then
            return true
        end
    end

    return old_is_protected(pos, name)
end

minetest.register_on_newplayer(function(player)
    player:set_pos(lobby_pos)
end)

local MIN_RADIUS = 500
local MAX_RADIUS = 1500
local TRIES = 20

local function get_random_pos()
    local dist, angle = math.random(MIN_RADIUS, MAX_RADIUS), math.random() * math.pi * 2
    local x, z =  math.cos(angle) * dist, math.sin(angle) * dist
    local y = minetest.get_spawn_level(x, z)

    if not y then return end -- No available position
    return vector.new(x, y, z)
end

local function get_overworld_pos()
    for _ = 1, TRIES do
        local pos = get_random_pos()
        if pos then
            return pos
        end
    end
end

local invincible = {}

minetest.register_on_player_hpchange(function(player, hp_change)
    if invincible[player:get_player_name()] then
        return 0
    end

    return hp_change
end, true)

minetest.register_chatcommand("overworld", {
    func = function(name)
        local player = minetest.get_player_by_name(name)
        local pos = player:get_pos()

        local in_skyblock = minetest.global_exists("skyblock") and skyblock.is_in_skyblock(name)
        local in_lobby = pos.y > 20000 and pos.y < 250000

        if in_skyblock or in_lobby then
            if space then
                space.set_player_space(name, false)
            end

            invincible[name] = true

            -- Try to set player velocity to zero
            player:add_player_velocity(-player:get_velocity())

            local opos = get_overworld_pos()
            if not opos then
                return false, "Couldn't find suitable position. Please try again."
            end

            if in_skyblock then
                skyblock.exit_cel(name, opos)
            else
                player:set_pos(opos)
            end

            minetest.after(3, function()
                invincible[name] = false
            end)

            return true, "Transporting to overworld..."
        end

        return false, "You can only transport to the overworld from the main ship or orbiter!"
    end
})

local enable_bed_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_bed_respawn == nil then
	enable_bed_respawn = true
end

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local cel = skyblock.get_player_cel(name)

	if beds and enable_bed_respawn and beds.spawn[name] then
        local pos = beds.spawn[name]
        if cel and skyblock.pos_in_bounds(pos, cel.bounds.min, cel.bounds.max) then
            skyblock.enter_cel(name, pos)
        else
            player:set_pos(pos)
        end
	elseif cel then
        skyblock.enter_cel(name)
        return true
    else
        player:set_pos(lobby_pos)
    end

    return true
end)
