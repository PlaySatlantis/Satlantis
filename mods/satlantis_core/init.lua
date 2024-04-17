satlantis = {}

minetest.get_server_status = function()
    local connected = {}
    for _, player in pairs(minetest.get_connected_players()) do
        table.insert(connected, player:get_player_name())
    end

    return "Welcome to Satlantis! | Server ver. 5.8.0 | " .. #connected .. " players: " .. table.concat(connected, ", ")
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

local rules_form = [[
    formspec_version[7]
    size[16,10]
    no_prepend[]
    bgcolor[#002b3d]

    image[4,0.5;8,2;satlantis_header.png]

    container[4.5,2.5]
    label[0,0.5;Welcome to the EARLY ACCESS ALPHA version of Satlantis 2!]
    label[0.75,1;Many features are unstable or not yet implemented.]
    label[0.35,1.5;Please be patient while we continue to develop Satlantis!]
    container_end[]

    container[4.5,5]
    label[2.4,0;SERVER RULES]

    container[0.5,0.5]
    label[0,0.0;- Play kind. Treat staff and players with respect.]
    label[0,0.5;- Play fair. Do not grief or use modified clients.]
    label[0,1.0;- Play honest. No scams\, boosting\, alts\, or gambling.]
    label[0,1.5;- Play safe. Only use in-game commands to transfer sats.]
    label[0,2.0;- Do not spam\, advertise\, or paste links in chat.]
    container_end[]

    %s

    label[1.75,4.25;https://satlantis.net/blog/terms]
    container_end[]

    %s
]]

local button_agree = "button[2,3;3,0.8;agree;I AGREE]"
local button_exit = "button_exit[15,0.5;0.5,0.5;close;x]"

local function show_rules_form(name)
    local agreed = minetest.get_player_by_name(name):get_meta():get_int("rules:agreed") == 1
    minetest.show_formspec(name, "setup:rules", rules_form:format(agreed and "" or button_agree, agreed and button_exit or ""))
end

local unverified_players = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "setup:rules" then
        local meta = player:get_meta()
        local name = player:get_player_name()

        if fields.agree then
            meta:set_int("rules:agreed", 1)

            local privs = minetest.get_player_privs(name)
            privs.interact = true
            privs.shout = true
            minetest.set_player_privs(name, privs)

            unverified_players[name] = nil
            minetest.close_formspec(name, formname)
        end
    end
end)

minetest.register_chatcommand("rules", {
    func = function(name)
        show_rules_form(name)
    end
})

minetest.register_on_joinplayer(function(player)
    local meta = player:get_meta()
    if meta:get_int("rules:agreed") ~= 1 then
        local name = player:get_player_name()
        unverified_players[name] = true
        show_rules_form(name)
    end
end)

local interval = 3
local timer = 0

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= interval then
        while timer >= interval do
            timer = timer - interval
        end

        for name in pairs(unverified_players) do
            show_rules_form(name)
        end
    end
end)

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

minetest.register_on_leaveplayer(function(player)
    player:get_meta():set_string("logout:velocity", minetest.pos_to_string(player:get_velocity(), 2))
end)

minetest.register_on_joinplayer(function(player)
    local saved_vel = player:get_meta():get("logout:velocity")
    if saved_vel then
        local velocity = minetest.string_to_pos(saved_vel)
        if velocity.y < -0.2 then
            local overrides = player:get_physics_override()

            local hud_img = player:hud_add({
                hud_elem_type = "image",
                position = {x = 0, y = 0},
                alignment = {x = 1, y = 1},
                text = "blank.png^[invert:a",
                scale = {x = -100, y = -100},
            })
            local hud_text = player:hud_add({
                hud_elem_type = "text",
                position = {x = 0.5, y = 0.5},
                text = "Loading ...",
                number = 0xFFFFFF,
            })

            player:set_physics_override({gravity = 0, speed = 0})

            -- Wait for blocks to load :(
            minetest.after(3, function()
                player:set_physics_override(overrides)
                player:hud_remove(hud_text)
                player:hud_remove(hud_img)
                player:add_velocity(velocity)
            end)
        end
    end
end)

minetest.register_node(":satlantis:header", {
    description = "Header",
    drawtype = "mesh",
    mesh = "satlantis_header.obj",
    tiles = {{name = "satlantis_header.png", backface_culling = false}},
    paramtype2 = "facedir",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    selection_box = {
        type = "fixed",
        fixed = {0.4, -0.5, -0.5, 0.5, 0.5, 0.5}
    },
    light_source = 2,
    groups = {oddly_breakable_by_hand = 1},
})
