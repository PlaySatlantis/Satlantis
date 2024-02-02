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
