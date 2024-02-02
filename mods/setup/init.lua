minetest.get_server_status = function()
    local connected = {}
    for _, player in pairs(minetest.get_connected_players()) do
        table.insert(connected, player:get_player_name())
    end

    return "Welcome to Satlantis! | Server ver. 5.8.0 | Connected players: " .. table.concat(connected, ", ")
end

minetest.register_on_joinplayer(function(player)
    player:hud_set_flags({
        basic_debug = false,
    })

    player:set_minimap_modes({{type = "off", label = " "}}, 0)
end)


minetest.send_join_message = function(name)
    minetest.chat_send_all(">>> " .. name .. " joined.")
end

minetest.send_leave_message = function(name, timed_out)
    minetest.chat_send_all("<<< " .. name .. " left" .. (timed_out and " (timed out)." or "."))
end

minetest.register_on_newplayer(function(player)
    local inv = player:get_inventory()

    for _, item in ipairs({
        "farming:bread 20",
        "default:pick_steel",
        "default:sword_steel",
        "default:axe_steel",
        "default:shovel_steel",
        "3d_armor:chestplate_steel",
        "3d_armor:leggings_steel",
        "3d_armor:boots_steel",
    }) do
        inv:add_item("main", item)
    end
end)
