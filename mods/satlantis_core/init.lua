satlantis = {}

local ie = minetest.request_insecure_environment()

if not ie or not ie.require then
    core.log("error", "satlantis_core hasn't been given access to insecure environment. "
                   .. "Please add it to `secure.trusted_mods` in minetest.conf")
    return
end

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

if not minetest.has_feature({dynamic_add_media_table = true}) then
    core.log("error", "Missing required feature: dynamic_add_media")
    return
end

function satlantis.sleep(seconds)
    ie.os.execute("sleep " .. tostring(seconds))
end

local function sleep(seconds)
    satlantis.sleep(seconds)
end

function satlantis.give_player_joules(player, amount, callback)
    local payload = "{ \"user\":\"" .. tostring(player) .. "\", \"amount\": \"" .. tostring(amount) .. "\"}"
    local request = {
        url = backend_api.add_joules,
        timeout = 4,
        method = "PUT",
        data = payload,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            callback(true, "Success")
        elseif response.timeout then
            callback(false, "Timed out")
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason)
        end
    end)
end

function satlantis.create_asic(player, hashrate, kind, callback)
    if kind == nil then
        kind = "REGULAR"
    end
    local payload = "{ \"user\":\"" .. tostring(player) .. "\", \"hashrate\": \"" .. tostring(hashrate) .. "\", \"type\": \"" .. tostring(kind) .. "\"}"
    local request = {
        url = backend_api.create_asic,
        method = "POST",
        data = payload,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_json = core.parse_json(response.data or "")
            callback(true, "Success", response_json)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

function satlantis.get_user_data(player, callback)
    local request = {
        url = backend_api.get_user .. player,
        method = "GET",
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_json = core.parse_json(response.data or "")
            callback(true, "Success", response_json.data)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

function satlantis.withdraw_sats(player, percent, callback)
    if percent > 100 or percent <= 0.0 then
        core.log("error", "Invalid percentage value to withdraw: " .. tostring(percent))
        return
    end
    local request = {
        url = backend_api.withdraw_sats,
        method = "POST",
        data = " ",
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_json = core.parse_json(response.data or "")
            callback(true, "Success", response_json)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

function satlantis.get_asics(player, callback)
    local request = {
        url = backend_api.get_asics .. player,
        method = "GET",
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_json = core.parse_json(response.data or "")
            callback(true, "Success", response_json.data)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

function satlantis.add_balance(player, amount, callback)
    local payload = "{ \"user\":\"" .. tostring(player) .. "\", \"amount\": \"" .. tostring(amount) .. "\"}"
    local request = {
        url = backend_api.change_balance,
        method = "PUT",
        data = payload,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_data = core.parse_json(response.data or "")
            local user_balance = {
                previous = response_data.data.balance_before,
                current = response_data.data.balance_after
            }
            callback(true, "Success", user_balance)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

function satlantis.make_purchase(player, amount, callback)
    local payload = "{ \"user\":\"" .. tostring(player) .. "\", \"amount\": \"" .. tostring(amount) .. "\"}"
    local request = {
        url = backend_api.make_purchase,
        method = "POST",
        data = payload,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_data = core.parse_json(response.data or "")
            local updated_record = {
                amount = response_data.data.amount,
                added_to_prize_pool = response_data.data.added_to_prize_pool,
                new_balance = response_data.data.new_balance,
                old_balance = response_data.data.old_balance
            }
            callback(true, "Success", updated_record)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

function satlantis.transfer_sats(player_src, player_dst, amount, callback)
    local payload = "{ \"from\":\"" .. tostring(player_src) .. "\", \"to\": \"" .. tostring(player_dst) .. "\", \"amount\": \"" .. tostring(amount) .. "\"}"
    local request = {
        url = backend_api.transfer_sats,
        method = "POST",
        data = payload,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_json = core.parse_json(response.data or "")
            callback(true, "Success", response_json)
        elseif response.timeout then
            callback(false, "Timed out", nil)
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, reason, nil)
        end
    end)
end

minetest.register_chatcommand("link", {
    description = "Confirm your Discord account by entering token",
    func = function(name, param)
        local payload = "{ \"token\":\"" .. tostring(param) .. "\", \"username\": \"" .. tostring(name) .. "\"}"
        local request = {
            url = backend_api.link,
            timeout = 4,
            method = "POST",
            data = payload,
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

local deposit_qr_formspec = [[
    formspec_version[7]
    size[16,10]
    no_prepend[]
    bgcolor[#002b3d]
    style_type[label;font_size=*2.2]
    label[2,0.8;Use the following QR code to make a deposit]
    image[5,1.5;6,6;%s]
    style_type[label;font_size=*2]
    textarea[1,8.0;14,2;;%s;]
    button_exit[14,9;1.5,0.8;;Close]
]]

function satlantis.request_deposit_code(player_name, callback)
    local payload = "{\"user\":\"" .. tostring(player_name) .. "\"}"
    local request = {
        url = backend_api.deposit,
        timeout = 4,
        method = "POST",
        data = payload,
        extra_headers = {
            "Accept-Charset: utf-8",
            "Content-Type: application/json",
            "API-KEY: " .. config.API_KEY
        },
    }
    http_api.fetch(request, function(response)
        if response.succeeded and response.code == 200 then
            local response_json = core.parse_json(response.data or "")
            if response_json and response_json.status then
                if response_json.status == "success" then
                    local request_code = response_json.data.request
                    local qr_image = response_json.data.qr_image
                    if request_code and qr_image then
                        local inner_request = {
                            url = qr_image,
                            timeout = 4,
                            method = "GET",
                            extra_headers = {
                                "Accept-Charset: utf-8",
                                "Content-Type: image/png",
                                "API-KEY: " .. config.API_KEY
                            },
                        }
                        http_api.fetch(inner_request, function(inner_response)
                            if inner_response.succeeded then
                                local qr_image_file_path = MODPATH .. "/textures/" .. tostring(player_name) .. "_qr_image.png"
                                local qr_image_file = ie.io.open(qr_image_file_path, "w+")
                                qr_image_file:write(inner_response.data)
                                qr_image_file:flush()
                                qr_image_file:close()
                                local media_options = {
                                    filepath = qr_image_file_path,
                                    to_player = player_name,
                                    ephemeral = false
                                }
                                if not minetest.dynamic_add_media(media_options, function(player_name)
                                    callback(true, qr_image_file_path, request_code, nil)
                                end) then
                                    core.log("error: Failed to add QR code to clients dynamic media")
                                end
                            else
                                callback(false, nil, nil)
                            end
                        end)
                    else
                        callback(false, nil, nil)
                    end
                else
                    callback(false, nil, nil)
                end
            end
        elseif response.timeout then
            callback(false, nil, nil, "Timed out")
        else
            local response_json = core.parse_json(response.data or "")
            local reason = "Unknown"
            if response_json and response_json.status then
                reason = tostring(response_json.status)
            end
            callback(false, nil, nil, reason)
        end
    end)
end

minetest.register_chatcommand("deposit", {
    description = "Request QR link for making deposit",
    func = function(name, param)
        local payload = "{\"user\":\"" .. tostring(name) .. "\"}"
        local request = {
            url = backend_api.deposit,
            timeout = 4,
            method = "POST",
            data = payload,
            extra_headers = {
                "Accept-Charset: utf-8",
                "Content-Type: application/json",
                "API-KEY: " .. config.API_KEY
            },
        }
        http_api.fetch(request, function(response)
            if response.succeeded and response.code == 200 then
                local response_json = core.parse_json(response.data or "")
                if response_json and response_json.status then
                    if response_json.status == "success" then
                        local request_code = response_json.data.request
                        local qr_image = response_json.data.qr_image
                        if request_code and qr_image then
                            local inner_request = {
                                url = qr_image,
                                timeout = 4,
                                method = "GET",
                                extra_headers = {
                                    "Accept-Charset: utf-8",
                                    "Content-Type: image/png",
                                    "API-KEY: " .. config.API_KEY
                                },
                            }
                            http_api.fetch(inner_request, function(inner_response)
                                if inner_response.succeeded then
                                    local qr_image_file_path = MODPATH .. "/textures/qr_image.png"
                                    local qr_image_file = ie.io.open(qr_image_file_path, "w")
                                    qr_image_file:write(inner_response.data)
                                    qr_image_file:close()
                                    -- Seems like there's a race condition here, where the formspec fails to load the
                                    -- image without this delay
                                    sleep(0.1)
                                    local formspec = deposit_qr_formspec:format("qr_image.png", request_code);
                                    minetest.show_formspec(name, "Deposit", formspec)
                                end
                            end)
                        end
                    else
                        minetest.chat_send_player(name, "Error: " .. tostring(response_json.status))
                    end
                end
            elseif response.timeout then
                minetest.chat_send_player(name, "Failed to generate deposit details due to timeout. Please try again")
            else
                local response_json = core.parse_json(response.data or "")
                local reason = "Unknown"
                if response_json and response_json.status then
                    reason = tostring(response_json.status)
                end
                minetest.chat_send_player(name, "Failed to generate deposit details. Reason: " .. reason )
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
                data = payload,
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
                data = payload,
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

minetest.register_chatcommand("send_sats", {
    description = "Send sats to another player",
    func = function(name, params)
        local args = parse_args(params)
        if #args == 2 then
            local player = args[1]
            local amount = tonumber(args[2])
            if amount and player then
                satlantis.transfer_sats(name, player, amount, function(succeeded, message, updated_record)
                    if succeeded then
                        minetest.chat_send_player(name, "Successfully transferred " .. tostring(amount) .. " sats to " .. player)
                        minetest.chat_send_player(name, "Remaining balance: " .. tostring(updated_record.amount))
                    else
                        minetest.chat_send_player(name, "Failed make transfer. Reason: " .. tostring(message))
                    end
                end)
            else
                minetest.chat_send_player(name, "Invalid command arguments `send_sats <username> <amount>`")
            end
        else
            minetest.chat_send_player(name, "send_sats expects 2 argument. Found " .. tostring(#args))
        end
    end
})

local function user_is_connected(username)
    for _, connected_player in pairs(minetest.get_connected_players()) do
        if connected_player:get_player_name() == username then
            return true
        end
    end
    return false
end

local time_since_update = 0
local update_table = {}
local update_table_next_free = nil

minetest.register_globalstep(function(dtime)
    time_since_update = time_since_update + dtime
    local update_interval = 2
    if time_since_update >= update_interval then
        time_since_update = 0
        update_table_next_free = nil
        --
        -- First let's process what's in `update_table`
        --
        for i, update in ipairs(update_table) do
            if update.processed == false then
                if item.type and item.type == "USER_DEPOSIT_SUCCESS" then
                    local user = item.user
                    local amount = item.amount
                    if user and amount then
                        if user_is_connected(user) then
                            minetest.chat_send_player(username, "Deposit of " .. tostring(amount) .. " sats was successful")
                            update.processed = true
                        end
                    else
                        core.log("error", "Corrupted USER_DEPOSIT_SUCCESS found in `update_table`")
                    end
                else
                    core.log("error", "Update with invalid type " .. tostring(item.type) .. " found in `update_table`")
                end
            else
                if not update_table_next_free then
                    -- Keep track of the first entry in the table that is free
                    -- to be overwritten so we don't have to shift around elements
                    update_table_next_free = i
                end
            end
        end
        --
        -- Next we load updates from the backend. Some will be processed straight away, while
        -- those that can't will be put into `update_table` for later on
        --
        local request = {
            url = backend_api.get_updates,
            method = "GET",
            extra_headers = {
                "Accept-Charset: utf-8",
                "Content-Type: application/json",
                "API-KEY: " .. config.API_KEY
            },
        }
        http_api.fetch(request, function(response)
            if response.succeeded and response.code == 200 then
                local response_json = {}
                if response.data then
                    response_json = core.parse_json(response.data)
                end
                for i, item in ipairs(response_json) do
                    if item.type and item.type == "USER_DEPOSIT_SUCCESS" then
                        if item.data then
                            local username = item.data.user
                            local amount = item.data.amount
                            if username and amount then
                                if user_is_connected(username) then
                                    minetest.chat_send_player(username, "Deposit of " .. tostring(amount) .. " sats was successful")
                                else
                                    -- We have an update for a user that isn't connected to the server atm
                                    -- Store it in `update_table`
                                    local table_record = {
                                        kind = "USER_DEPOSIT_SUCCESS",
                                        user = username,
                                        amount = amount,
                                        created_ts = ie.os.time(),
                                        processed = false
                                    }
                                    if update_table_next_free then
                                        assert(update_table[update_table_next_free].processed)
                                        update_table[update_table_next_free] = table_record
                                    else
                                        table.insert(update_table, table_record)
                                    end
                                    -- core.log("info", "Added entry to `update_table`. " .. dump(table_record))
                                end
                            else
                                core.log("error", "Invalid payload from backend for `USER_DEPOSIT_SUCCESS`. `user` and/or `player` field null")
                            end
                        else
                            core.log("error", "Invalid payload from backend for `USER_DEPOSIT_SUCCESS`. No data found")
                        end
                    else
                        core.log("warning", "Update with invalid type " .. tostring(item.type) .. " will be ignored")
                    end
                end
            elseif response.timeout then
                core.log("warning", "Update request to backend timed out.")
            else
                local response_json = nil
                if response.data and #response.data > 2 then
                    response_json = core.parse_json(response.data)
                end
                local reason = "Unknown"
                if response_json and response_json.status then
                    reason = tostring(response_json.status)
                end
                core.log("warning", "Update request to backend failed. Reason: " .. reason)
            end
        end)
    end
end)

minetest.get_server_status = function()
    local connected = {}
    for _, player in pairs(minetest.get_connected_players()) do
        table.insert(connected, player:get_player_name())
    end

    return "Welcome to Satlantis! | Server ver. 5.8.0 | " .. #connected .. " players: " .. table.concat(connected, ", ")
end

minetest.register_on_joinplayer(function(player, last_joined)

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
                    data = " ",
                    extra_headers = {
                        "Accept-Charset: utf-8",
                        "Content-Type: application/json",
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
                core.log("warning", "Record doesn't exist in backend for exising user: " .. player_name)
                local inner_request = {
                    url = backend_api.create_user .. player_name,
                    method = "POST",
                    -- Without this dummy post data, request will get permentently stuck in queue
                    -- (On Ubuntu)
                    data = " ",
                    timeout = 10,
                    extra_headers = {
                        "Accept-Charset: utf-8",
                        "Content-Type: application/json",
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

--
-- Below are definitions for chat_commands that can be used to test the API
--

--
-- Can be used to test `satlantis.get_user_data`
--

-- minetest.register_chatcommand("get_user", {
--     description = "Get account information for user",
--     func = function(name, params)
--         satlantis.get_user_data(name, function(succeeded, message, json_data)
--             if succeeded then
--                 core.log("error", "User data: " .. dump(json_data))
--             else
--                 core.log("error", "Failed to get user data for user. Reason: " .. tostring(message))
--             end
--         end)
--     end
-- })

--
-- Can be used to test `satlantis.get_asics`
--

-- minetest.register_chatcommand("get_asics", {
--     description = "Get ASICs for user",
--     func = function(name, params)
--         satlantis.get_asics(name, function(succeeded, message, json_data)
--             if succeeded then
--                 core.log("error", "ASICs: " .. dump(json_data))
--             else
--                 core.log("error", "Failed to create ASIC for user. Reason: " .. tostring(message))
--             end
--         end)
--     end
-- })

--
-- Can be used to test `satlantis.create_asic`
--

-- minetest.register_chatcommand("create_asic", {
--     description = "Add ASIC",
--     func = function(name, params)
--         local args = parse_args(params)
--         local hashrate = args[1]
--         local kind = #args >= 2 and args[2] or nil
--         satlantis.create_asic(name, hashrate, kind, function(succeeded, message, json_data)
--             if succeeded then
--                 core.log("error", "Successfully created ASIC for user")
--                 core.log("error", "Json: " .. dump(json_data))
--             else
--                 core.log("error", "Failed to create ASiC for user. Reason: " .. tostring(message))
--             end
--         end)
--     end
-- })

--
-- Can be used to test `satlantis.give_player_joules`
--

-- minetest.register_chatcommand("add_joules", {
--     description = "Add Joules",
--     func = function(name, params)
--         local amount = 44
--         satlantis.give_player_joules(name, amount, function(succeeded, message)
--             if succeeded then
--                 core.log("error", "Successfully added joules to user")
--             else
--                 core.log("error", "Failed to add joules to user. Reason: " .. tostring(message))
--             end
--         end)
--     end
-- })

--
-- Can be used to test `satlantis.add_balance`
--

-- minetest.register_chatcommand("add_balance", {
--     description = "Add balance",
--     func = function(name, params)
--         local args = parse_args(params)
--         if #args == 1 then
--             local amount = tonumber(args[1])
--             if amount then
--                 satlantis.add_balance(name, amount, function(succeeded, message, user_balance)
--                     if succeeded then
--                         minetest.chat_send_player(name, "Successfully added " .. tostring(amount) .. " to account. Current balance: " .. tostring(user_balance.current))
--                     else
--                         minetest.chat_send_player(name, "Failed add balance. Reason: " .. tostring(message))
--                     end
--                 end)
--             else
--                 minetest.chat_send_player(name, "Invalid amount. Please enter a valid numeric value")
--             end
--         else
--             minetest.chat_send_player(name, "add_balance expects 1 argument. Found " .. tostring(#args))
--         end
--     end
-- })

--
-- Can be used to test `satlantis.make_purchase`
--

-- minetest.register_chatcommand("make_purchase", {
--     description = "Make a purchase",
--     func = function(name, params)
--         local args = parse_args(params)
--         if #args == 1 then
--             local amount = tonumber(args[1])
--             if amount then
--                 satlantis.make_purchase(name, amount, function(succeeded, message, updated_record)
--                     if succeeded then
--                         minetest.chat_send_player(name, "Successfully made purchase of " .. tostring(updated_record.amount) .. ". Current balance: " .. tostring(updated_record.new_balance))
--                         minetest.chat_send_player(name, tostring(updated_record.added_to_prize_pool) .. " was added to the prize pool")
--                     else
--                         minetest.chat_send_player(name, "Failed to make purchase. Reason: " .. tostring(message))
--                     end
--                 end)
--             else
--                 minetest.chat_send_player(name, "Invalid amount. Please enter a valid numeric value")
--             end
--         else
--             minetest.chat_send_player(name, "make_purchase expects 1 argument. Found " .. tostring(#args))
--         end
--     end
-- })