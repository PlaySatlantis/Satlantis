-- keybinding/init.lua
-- Register callbacks when a key is pressed, holded, or released.
--[[
    Copyright (C) 2023  1F616EMO

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
    USA
]]

keybinding = {}
keybinding.player_data = {}

local ctrl_fields = {
    "up", "down", "left", "right",
    "jump", "aux1", "sneak",
    "dig", "place", "zoom"
}

local function log(lvl, msg)
    return minetest.log(lvl, "[keybinding] " .. msg)
end

local function init_table()
    local rtn = {}
    for _, k in ipairs(ctrl_fields) do
        rtn[k] = {}
    end
    return rtn
end

keybinding.registered_on_press = init_table()
keybinding.register_on_press = function(key, func)
    keybinding.registered_on_press[key][#keybinding.registered_on_press[key] + 1] = func
end

keybinding.registered_hold_steps = init_table()
keybinding.register_hold_step = function(key, func)
    keybinding.registered_hold_steps[key][#keybinding.registered_hold_steps[key] + 1] = func
end

keybinding.registered_on_release = init_table()
keybinding.register_on_release = function(key, func)
    keybinding.registered_on_release[key][#keybinding.registered_on_release[key] + 1] = func
end

keybinding.registered_on_leave_while_holding = init_table()
keybinding.register_on_leave_while_holding = function(key, func)
    keybinding.registered_on_leave_while_holding[key][#keybinding.registered_on_leave_while_holding[key] + 1] = func
end

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    for _, k in ipairs(ctrl_fields) do
        if keybinding.player_data[name][k] then
            for _, func in ipairs(keybinding.registered_on_leave_while_holding[k]) do
                func(player)
            end
        end
    end
    keybinding.player_data[name] = nil
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    keybinding.player_data[name] = {}
    for _, k in ipairs(ctrl_fields) do
        keybinding.player_data[name][k] = false
    end
end)

minetest.register_globalstep(function()
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local ctrl = player:get_player_control()
        for _, k in ipairs(ctrl_fields) do
            if ctrl[k] ~= keybinding.player_data[name][k] then
                if not keybinding.player_data[name][k] then
                    log("verbose", "Player " .. name .. " pressed key " .. k)
                    -- Pressed
                    for _, func in ipairs(keybinding.registered_on_press[k]) do
                        func(player)
                    end
                    -- AND Holded
                    for _, func in ipairs(keybinding.registered_hold_steps[k]) do
                        func(player)
                    end
                else
                    log("verbose", "Player " .. name .. " released key " .. k)
                    -- Released
                    for _, func in ipairs(keybinding.registered_on_release[k]) do
                        func(player)
                    end
                end
                keybinding.player_data[name][k] = ctrl[k]
            elseif ctrl[k] then
                -- Holded
                for _, func in ipairs(keybinding.registered_hold_steps[k]) do
                    func(player)
                end
            end
        end
    end
end)