satlantis = {}

local MODPATH = minetest.get_modpath(minetest.get_current_modname())

local config_file = io.open(MODPATH .. "/config.json", "r")
local config = minetest.parse_json(config_file:read("*a"))
config_file:close()

local api_file = io.open(MODPATH .. "/api.json", "r")
local backend_api = minetest.parse_json(api_file:read("*a"))
api_file:close()

local http_api = minetest.request_http_api();

if not http_api then
    core.log("error", "HTTP access hasn't been granted to Satlantis. Cannot start")
    return
end

minetest.register_chatcommand("link", {
    description = "Confirm your Discord account by entering token",
    func = function(name, param)
        local payload = "{ \"token\":\"" .. tostring(param) .. "\", \"username\": \"" .. tostring(name) .. "\"}"
        local request = {
            url = backend_api.link,
            timeout = 4,
            method = "POST",
            post_data = payload,
            extra_headers = {
                "Accept-Charset: utf-8",
                "Content-Type: application/json",
                "API-KEY: " .. config.API_KEY
            },
        }
        http_api.fetch(request, function(response)
            if response.succeeded and response.code == 200 then
                minetest.chat_send_player(name, "Discord account successfully linked!")
            elseif response.timeout then
                minetest.chat_send_player(name, "Link failed due to timeout")
            else
                local response_json = core.parse_json(response.data or "")
                local reason = "Unknown"
                if response_json and response_json.status then
                    reason = tostring(response_json.status)
                end
                minetest.chat_send_player(name, "Link failed. " .. reason )
            end
        end)
    end
})

-- Splits a string based on space
local function parse_args(params)
    local arg_list = {}
    local arg_count = 0
    local start_index = 1
    local sep = string.byte(" ")
    local len = params:len()
    local i = 1
    while i <= len do
        if params:byte(i) == sep or i == len then
            local param = params:sub(start_index, i)
            arg_count = arg_count + 1
            arg_list[arg_count] = param
            -- Skip white space
            while i <= len and params:byte(i) == sep do
                i = i + 1
            end
            start_index = i
        end
        i = i + 1
    end
    return arg_list
end

minetest.register_chatcommand("set_email", {
    description = "Set email for account. This will cause a confirmation email to get sent",
    func = function(name, param)
        local args = parse_args(param)
        if #args == 1 then
            local email = args[1]
            local payload = "{ \"user\":\"" .. tostring(name) .. "\", \"email\": \"" .. tostring(email) .. "\"}"
            local request = {
                url = backend_api.send_email_confirmation,
                timeout = 10,
                method = "POST",
                post_data = payload,
                extra_headers = {
                    "Accept-Charset: utf-8",
                    "Content-Type: application/json",
                    "API-KEY: " .. config.API_KEY
                },
            }
            http_api.fetch(request, function(response)
                if response.succeeded and response.code == 200 then
                    minetest.chat_send_player(name, "Success. Check your email inbox for the confirmation email")
                elseif response.timeout then
                    minetest.chat_send_player(name, "Couldn't send email confirmation due to timeout. Please try again")
                else
                    local response_json = core.parse_json(response.data or "")
                    local reason = "Unknown"
                    if response_json and response_json.status then
                        reason = tostring(response_json.status)
                    end
                    minetest.chat_send_player(name, "Failed to send email comfirmation. " .. reason )
                end
            end)
        else
            minetest.chat_send_player(name, "set_email command only takes a single argument. Found " .. tostring(#args))
        end
    end
})

minetest.register_chatcommand("verify_code", {
    description = "Verify code previously sent to email address",
    func = function(name, param)
        local args = parse_args(param)
        if #args == 1 then
            local code = args[1]
            local payload = "{ \"user\":\"" .. tostring(name) .. "\", \"code\": \"" .. tostring(code) .. "\"}"
            local request = {
                url = backend_api.verify_code,
                timeout = 4,
                method = "POST",
                post_data = payload,
                extra_headers = {
                    "Accept-Charset: utf-8",
                    "Content-Type: application/json",
                    "API-KEY: " .. config.API_KEY
                },
            }
            http_api.fetch(request, function(response)
                if response.succeeded and response.code == 200 then
                    minetest.chat_send_player(name, "Email successfully verified!")
                elseif response.timeout then
                    minetest.chat_send_player(name, "Couldn't verify code due to timeout. Please try again")
                else
                    local response_json = core.parse_json(response.data or "")
                    local reason = "Unknown"
                    if response_json and response_json.status then
                        reason = tostring(response_json.status)
                    end
                    minetest.chat_send_player(name, "Failed to verify email with code. " .. reason )
                end
            end)
        else
            minetest.chat_send_player(name, "verify_code command only takes a single argument. Found " .. tostring(#args))
        end
    end
})

minetest.get_server_status = function()
    local connected = {}
    for _, player in pairs(minetest.get_connected_players()) do
        table.insert(connected, player:get_player_name())
    end

    return "Welcome to Satlantis! | Server ver. 5.8.0 | " .. #connected .. " players: " .. table.concat(connected, ", ")
end

minetest.register_on_joinplayer(function(player, last_joined)

    core.log("error", "register_on_joinplayer")
    player:hud_set_flags({
        basic_debug = false,
    })

    player:set_minimap_modes({{type = "off", label = " "}}, 0)

    local player_name = player:get_player_name()
    if not player_name then
        core.log("error", "Player name is nil")
        return
    end

    -- The player is joining for the first time. We need to create a record
    -- for them in the backend
    if not last_joined then
        core.log("info", "Creating record in backend for " .. player_name)
        local request = {
            url = backend_api.get_user .. player_name,
            method = "GET",
            extra_headers = {
                "Accept-Charset: utf-8",
                "Content-Type: application/json",
                "API-KEY: " .. config.API_KEY
            },
        }
        -- First, check to see whether a record already exists for this user
        -- Since this user just joined the server, we're expecting that one should *NOT* exist
        http_api.fetch(request, function(response)
            if response.succeeded and response.code == 200 then
                core.log("error", "Record in backend already exists for " .. player_name)
            elseif response.code == 400 then
                --
                -- No record found for this user, this is what we want. Next we'll
                -- go ahead and create a new one
                --
                local inner_request = {
                    url = backend_api.create_user .. player_name,
                    method = "POST",
                    extra_headers = {
                        "Accept-Charset: utf-8",
                        "API-KEY: " .. config.API_KEY
                    },
                }
                http_api.fetch(inner_request, function(inner_response)
                    if inner_response.succeeded and inner_response.code == 200 then
                        core.log("info", "Record in backend successfully created for: " .. player_name)
                        --
                        -- Success: New player got created in the backend
                        --
                    else
                        core.log("error", "Failed to create user " .. player_name .. " in the backend. Response: " .. inner_response.data)
                    end
                end)
            elseif response.timeout then
                core.log("error", "Failed to create record for \"" .. player_name .. "\" due to timeout")
            else
                local response_json = core.parse_json(response.data or "")
                local reason = "Unknown"
                if response_json and response_json.status then
                    reason = tostring(response_json.status)
                end
                minetest.chat_send_player(name, "Failed to create record for \"" .. player_name .. "\". Reason: " .. reason)
            end
        end)
    else
        --
        -- Player already exists on the server, in this case we expect to find a record
        -- for them in the backend
        --
        local request = {
            url = backend_api.get_user .. player_name,
            method = "GET",
            extra_headers = {
                "Accept-Charset: utf-8",
                "Content-Type: application/json",
                "API-KEY: " .. config.API_KEY
            },
        }
        http_api.fetch(request, function(response)
            if response.succeeded and response.code == 200 then
                --
                -- Success: Record for existing player found in backend
                --
            elseif response.code == 400 then
                core.log("error", "Record doesn't exist in backend for exising user: " .. player_name)
            elseif response.timeout then
                core.log("error", "Failed to validate record in backend due to timeout. Username: " .. player_name)
            else
                core.log("error", "Failed to validate record in backend due to unknown error. Username: " .. player_name)
            end
        end)
    end
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
