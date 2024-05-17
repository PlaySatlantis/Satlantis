satlantis_sprint = {}
satlantis_sprint.sprinting_players = {}


controls.register_on_hold(function(player, key, length)
    if key == "aux1" then
        local name = player:get_player_name()
        local info = hunger_ng.get_hunger_information(name)

        if info.hunger.enabled then
            def = {
				speed=armor.def[name].speed,
				jump=armor.def[name].jump,
			}
            def.speed = def.speed * 2
            def.jump = def.jump * 1.3
            player:set_physics_override(def)
            satlantis_sprint.sprinting_players[name] = true
        end
    end
end)


controls.register_on_release(function(player, key, length)
    if key == "aux1" then
        local name = player:get_player_name()
        if satlantis_sprint.sprinting_players[name] then
            def = {
                speed=armor.def[name].speed,
                jump=armor.def[name].jump,
            }
            player:set_physics_override(def)
            satlantis_sprint.sprinting_players[name] = nil
        end
    end
end)

local timer = 0
local hunger_counters = {}
local hunger_tick = 5
minetest.register_globalstep(function(dtime)
    -- if not in arena and not sprinting the every 2 seconds reset the physics override
    timer = timer + dtime
    if timer > 3 then
        timer = 0
        for _, player in pairs(minetest.get_connected_players()) do
            local name = player:get_player_name()
            if not satlantis_sprint.sprinting_players[name] and not arena_lib.is_player_in_arena(name) then
                def = {
                    speed=armor.def[name].speed,
                    jump=armor.def[name].jump,
                }
                player:set_physics_override(def)
            end
        end
    end
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        if satlantis_sprint.sprinting_players[name] then
            hunger_counters[name] = (hunger_counters[name] or 0) + dtime
            if hunger_counters[name] > hunger_tick then
                hunger_counters[name] = 0
                hunger_ng.alter_hunger(name, -1, 'sprinting')
            end
        end
    end

            
end)


