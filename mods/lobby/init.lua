local storage = minetest.get_mod_storage()
local lobby_pos = minetest.string_to_pos(storage:get("lobby_pos") or "0,0,0")

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

    local inv = player:get_inventory()

    for _, item in ipairs({
        "farming:bread 20",
        "default:pick_steel",
        "default:sword_steel",
        "default:axe_steel",
        "default:shovel_steel",
    }) do
        inv:add_item("main", item)
    end
end)
