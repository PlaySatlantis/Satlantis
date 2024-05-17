--[[
    Everness. Never ending discovery in Everness mapgen.
    Copyright (C) 2024 SaKeL

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

--]]

local function update_sfinv(name)
    minetest.after(0, function()
        local player = minetest.get_player_by_name(name)

        if player then
            if sfinv.get_page(player) == 'everness:encyclopedia' then
                sfinv.set_page(player, sfinv.get_homepage_name(player))
            else
                sfinv.set_player_inventory_formspec(player)
            end
        end
    end)
end

local function update_ui(name)
    minetest.after(0, function()
        local player = minetest.get_player_by_name(name)

        if player then
            if unified_inventory.current_page[name] == 'everness:encyclopedia' then
                unified_inventory.current_page[name] = 'craft'
            end

            unified_inventory.set_inventory_formspec(player, unified_inventory.current_page[name])
        end
    end)
end

minetest.register_privilege('everness_encyclopedia', {
    -- Privilege description
    description = 'Collection of registered items and functions with some information about them. Used for testing not for gameplay. Works only with SFINV!',

    -- Whether to grant the privilege to singleplayer.
    give_to_singleplayer = false,

    -- Whether to grant the privilege to the server admin.
    -- Uses value of 'give_to_singleplayer' by default.
    give_to_admin = false,

    -- Called when given to player 'name' by 'granter_name'.
    -- 'granter_name' will be nil if the priv was granted by a mod.
    on_grant = function(name, granter_name)
        if minetest.get_modpath('sfinv') and sfinv.enabled then
            update_sfinv(name)
        elseif minetest.get_modpath('unified_inventory') then
            update_ui(name)
        else
            minetest.chat_send_player(name, 'Compatible inventory not found. Everness encyclopedia will not be shown.')
        end
    end,

    -- Called when taken from player 'name' by 'revoker_name'.
    -- 'revoker_name' will be nil if the priv was revoked by a mod.

    -- Note that the above two callbacks will be called twice if a player is
    -- responsible, once with the player name, and then with a nil player
    -- name.
    -- Return true in the above callbacks to stop register_on_priv_grant or
    -- revoke being called.
    on_revoke = function(name, revoker_name)
        if minetest.get_modpath('sfinv') and sfinv.enabled then
            update_sfinv(name)
        elseif minetest.get_modpath('unified_inventory') then
            update_ui(name)
        else
            minetest.chat_send_player(name, 'Compatible inventory not found. Everness encyclopedia will not be shown.')
        end
    end,
})
