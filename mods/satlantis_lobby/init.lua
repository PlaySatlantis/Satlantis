local storage = minetest.get_mod_storage()
local lobby_pos = minetest.string_to_pos(storage:get("lobby_pos") or "0,0,0")
local skyblock, space = satlantis.skyblock, satlantis.space


local is_player_in_lobby = function(p_name)
    local player = minetest.get_player_by_name(p_name)
    if player then
        local pos = player:get_pos()
        local in_lobby = pos.y > 8100 and pos.y < 240000

        return in_lobby
    end
    return false
end

minetest.register_chatcommand("lobby", {
    func = function(name, param)
        local player = minetest.get_player_by_name(name)

        -- disable while in arenas
        if minetest.global_exists("arena_lib") then
            if arena_lib.is_player_in_arena(name) then
                return false, "Cannot teleport while inside arena!"
            end
            if arena_lib.is_player_in_queue(name) then
                return false, "Cannot teleport while inside arena queue!"
            end
        end


        if param ~= "" and minetest.get_player_privs(name).server then
            if minetest.get_modpath("satlantis_skyblock") then
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
            if minetest.get_modpath("satlantis_skyblock") then
                if skyblock.is_in_skyblock(name) then
                    skyblock.exit_cel(name, lobby_pos)
                    player:set_sun()
                    player:set_moon()
                    player:set_stars()
                    player:set_sky()
                    return true, "Transporting to lobby..."
                end
            end

            player:set_sun()
            player:set_moon()
            player:set_stars()
            player:set_sky()
            player:set_pos(lobby_pos)

            return true, "Transporting to lobby..."
        end
    end,
})

minetest.registered_chatcommands["spawn"] = minetest.registered_chatcommands["lobby"]

local old_is_protected = minetest.is_protected

minetest.is_protected = function(pos, name)
    if is_player_in_lobby(name) and (minetest.global_exists("arena_lib") and not(arena_lib.is_player_in_arena(name))) then
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

        local in_skyblock = minetest.get_modpath("satlantis_skyblock") and skyblock.is_in_skyblock(name)
        local in_lobby = is_player_in_lobby(name)

        if in_lobby and minetest.global_exists("arena_lib") then
            if arena_lib.is_player_in_arena(name) then
                return false, "Cannot transport to overworld while in Minigame arena!"
            end
            if arena_lib.is_player_in_queue(name) then
                return false, "Cannot transport to overworld while in Minigame queue!"
            end
        end

        if in_skyblock or in_lobby then
            if space then
                space.set_player_space(name, false)
            end

            invincible[name] = true

            -- Try to set player velocity to zero
            player:add_player_velocity(-player:get_velocity())

            -- Put player back where they were, if a save pos is available
            local opos 
            local save = player:get_meta():get_string("overworld:save_pos")
            if save ~= "" then
                opos = minetest.string_to_pos(player:get_meta():get_string("overworld:save_pos"))
            end

            if not opos then opos = get_overworld_pos() end

            if not opos then
                return false, "Couldn't find suitable position. Please try again."
            end

            if in_skyblock then
                skyblock.exit_cel(name, opos)
                player:set_sun()
                player:set_moon()
                player:set_stars()
                player:set_sky()
            else
                player:set_pos(opos)
                player:set_sun()
                player:set_moon()
                player:set_stars()
                player:set_sky()
            end

            minetest.after(3, function()
                invincible[name] = false
            end)

            return true, "Transporting to overworld..."
        end

        return false, "You can only transport to the overworld from the lobby or orbiter!"
    end
})

-- update players' save positions
local savetimer = 0
minetest.register_globalstep(function(dtime)
    savetimer = savetimer + dtime
    if savetimer >= 10 then
        for _, player in pairs(minetest.get_connected_players()) do
            
            local name = player:get_player_name()
            local in_skyblock = minetest.get_modpath("satlantis_skyblock") and skyblock.is_in_skyblock(name)
            local pos = player:get_pos()
            local in_lobby = is_player_in_lobby(name)

            if not(in_skyblock) and not(in_lobby) then
                -- save the position if the player is on solid ground and standing in air
                local below_n_pos = vector.add(player:get_pos(), vector.new(0,-.9,0))
                local below_n_name = minetest.get_node(below_n_pos).name
                local below_walkable = minetest.registered_nodes[below_n_name] and minetest.registered_nodes[below_n_name].walkable or false

                local above_n_pos = vector.add(player:get_pos(), vector.new(0,1.1,0))
                local above_n_name = minetest.get_node(above_n_pos).name
                local above_is_air = above_n_name == "air"

                if below_walkable and above_is_air then
                    player:get_meta():set_string("overworld:save_pos", minetest.pos_to_string(player:get_pos(), 1))
                end
            end
        end
        savetimer = 0
    end
end)



minetest.registered_chatcommands["world"] = minetest.registered_chatcommands["overworld"]
minetest.registered_chatcommands["resourceworld"] = minetest.registered_chatcommands["overworld"]

local enable_bed_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_bed_respawn == nil then
	enable_bed_respawn = true
end

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local cel = skyblock.get_player_cel(name)
    local is_player_in_arena = minetest.get_modpath("arena_lib") and arena_lib.is_player_in_arena(name)
    local is_player_in_queue = minetest.get_modpath("arena_lib") and arena_lib.is_player_in_queue(name)
    local in_lobby = is_player_in_lobby(name)

    if is_player_in_arena then return false end

    if in_lobby then
        player:set_pos(lobby_pos)
	elseif beds and enable_bed_respawn and beds.spawn[name] then
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



-- arena_lib checks: if arena_lib exists, then if the player joins and is found
-- inside an arena area, then move the player to the lobby

minetest.register_on_mods_loaded(function() 
    if arena_lib then
        minetest.register_on_joinplayer(function(player)
            -- iterate through all arena
            for modname, arenamod in pairs(arena_lib.mods) do
                for arenaid, arena in pairs(arenamod.arenas) do
                    if arena_lib.is_player_in_region(arena, player:get_player_name()) and not(arena_lib.is_player_in_arena(player:get_player_name())) then
                        player:set_pos(lobby_pos)
                    end
                end
            end
        end)
    end
end)